//! Batched, topologically ordered insertion engine.
//!
//! Runs the whole `feint up` inside a single transaction: any failure
//! (including a CHECK-constraint violation Postgres itself rejects) rolls
//! everything back, so a completed run is by-construction free of FK/PK/
//! unique/NOT NULL/type violations — the `✓ All constraints valid` UX line
//! is just a successful `COMMIT`, not a separate validation pass.

use std::collections::{HashMap, HashSet};

use postgres_types::ToSql;
use rand::Rng;
use tokio_postgres::Transaction;

use crate::config::FeintConfig;
use crate::error::{FeintError, Result};
use crate::generate::{derive_rng, generate_value, SeedKey};
use crate::graph::{FkRef, InsertGroup, InsertPlan};
use crate::introspect::{Column, Schema, Table, TableId};
use crate::value::PgValue;

const MAX_BIND_PARAMS: usize = 65_000;
const MAX_BATCH_ROWS: usize = 500;

pub enum ProgressEvent<'a> {
    TableStarted { table: &'a str, planned_rows: u32 },
    TableFinished { table: &'a str, rows: u64 },
}

pub struct RunSummary {
    pub rows_by_table: Vec<(String, u64)>,
    pub total_rows: u64,
}

/// Sampled reference pool keyed by `(table, referenced-column-set)` so
/// composite FKs sample a whole tuple that actually co-occurred in a
/// generated row, and a table referenced through more than one unique
/// constraint keeps a separate pool per constraint.
#[derive(Default)]
pub(crate) struct RefPool {
    pools: HashMap<(TableId, Vec<String>), Vec<Vec<PgValue>>>,
}

impl RefPool {
    /// `pub(crate)`: also called directly from `clone.rs` to register a
    /// hybrid run's already-known real (masked) primary keys, which need
    /// no `RETURNING` round trip the way GENERATE mode's server-assigned
    /// keys do.
    pub(crate) fn register(&mut self, table: &TableId, columns: &[String], tuple: Vec<PgValue>) {
        if tuple.iter().any(PgValue::is_null) {
            // A NULL participant can't satisfy MATCH SIMPLE FK lookups
            // reliably as a sampled target; skip registering it.
            return;
        }
        self.pools
            .entry((table.clone(), columns.to_vec()))
            .or_default()
            .push(tuple);
    }

    fn sample(
        &self,
        table: &TableId,
        columns: &[String],
        rng: &mut rand_chacha::ChaCha8Rng,
    ) -> Option<Vec<PgValue>> {
        let key = (table.clone(), columns.to_vec());
        let pool = self.pools.get(&key)?;
        if pool.is_empty() {
            return None;
        }
        let idx = rng.gen_range(0..pool.len());
        Some(pool[idx].clone())
    }
}

pub async fn run(
    txn: &Transaction<'_>,
    schema: &Schema,
    plan: &InsertPlan,
    config: &FeintConfig,
    mut progress: impl FnMut(ProgressEvent),
) -> Result<RunSummary> {
    txn.batch_execute("SET CONSTRAINTS ALL DEFERRED").await?;

    // Every table at least one foreign key points at, schema-wide. A
    // `Simple` table outside this set can never be sampled from — a
    // `Backfill`/`Deferred` table is always in it by construction (that's
    // what makes it part of a cycle) — so it can skip `RETURNING` and
    // `ref_pool` registration entirely and take the faster `COPY` path
    // instead of chunked `INSERT`. See `copy.rs`.
    let referenced_tables: HashSet<TableId> = schema
        .tables
        .iter()
        .flat_map(|t| t.foreign_keys.iter().map(|fk| fk.ref_table.clone()))
        .collect();

    let mut ref_pool = RefPool::default();
    let mut rows_by_table = Vec::new();
    let mut total_rows = 0u64;

    for group in &plan.groups {
        match group {
            InsertGroup::Simple(table_id) => {
                let table = schema.table(table_id).expect("table exists in schema");
                let planned_rows = rows_for(config, table_id);
                progress(ProgressEvent::TableStarted {
                    table: &table_id.qualified(),
                    planned_rows,
                });
                let n = insert_plain_table(
                    txn,
                    table,
                    planned_rows,
                    config,
                    &HashSet::new(),
                    &mut ref_pool,
                    referenced_tables.contains(table_id),
                )
                .await?;
                progress(ProgressEvent::TableFinished {
                    table: &table_id.qualified(),
                    rows: n,
                });
                rows_by_table.push((table_id.qualified(), n));
                total_rows += n;
            }
            InsertGroup::Deferred(tables) => {
                let n = insert_deferred_group(
                    txn,
                    schema,
                    tables,
                    config,
                    &mut ref_pool,
                    &mut progress,
                )
                .await?;
                for (t, c) in n {
                    total_rows += c;
                    rows_by_table.push((t, c));
                }
            }
            InsertGroup::Backfill {
                tables,
                null_then_backfill,
            } => {
                let n = insert_backfill_group(
                    txn,
                    schema,
                    tables,
                    null_then_backfill,
                    config,
                    &mut ref_pool,
                    &mut progress,
                )
                .await?;
                for (t, c) in n {
                    total_rows += c;
                    rows_by_table.push((t, c));
                }
            }
        }
    }

    Ok(RunSummary {
        rows_by_table,
        total_rows,
    })
}

pub(crate) fn rows_for(config: &FeintConfig, table_id: &TableId) -> u32 {
    config
        .table_config(&table_id.qualified())
        .map(|t| t.rows)
        .unwrap_or(crate::config::DEFAULT_ROWS)
}

fn supplied_columns(table: &Table) -> Vec<&Column> {
    table
        .columns
        .iter()
        .filter(|c| !c.is_server_assigned())
        .collect()
}

/// Union of every column that participates in some unique constraint
/// (including the primary key) — the only columns any FK could ever
/// target, so it's exactly what needs to come back via `RETURNING` to
/// populate every possible reference pool for this table.
fn returning_columns(table: &Table) -> Vec<String> {
    let mut seen = HashSet::new();
    let mut cols = Vec::new();
    for uc in &table.unique_constraints {
        for c in &uc.columns {
            if seen.insert(c.clone()) {
                cols.push(c.clone());
            }
        }
    }
    cols
}

/// Generate one row's values for `supplied_columns`, in order.
/// `skip_fk_columns` names FK columns to leave NULL (Backfill first pass);
/// pass `&HashSet::new()` for a plain insert.
#[allow(clippy::too_many_arguments)]
fn generate_row(
    table: &Table,
    supplied: &[&Column],
    row_identity: &str,
    global_seed: &str,
    overrides: &std::collections::BTreeMap<String, crate::config::ColumnConfig>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &RefPool,
) -> Result<Vec<PgValue>> {
    let table_name = table.id.qualified();
    let mut values: HashMap<String, PgValue> = HashMap::new();

    for fk in &table.foreign_keys {
        if fk.columns.iter().any(|c| skip_fk_columns.contains(c)) {
            for c in &fk.columns {
                values.insert(c.clone(), PgValue::Null);
            }
            continue;
        }
        if !fk
            .columns
            .iter()
            .any(|c| supplied.iter().any(|s| &s.name == c))
        {
            continue;
        }
        let mut rng = derive_rng(
            global_seed,
            &SeedKey {
                table: &table_name,
                column: &fk.name,
                row_identity,
            },
        );
        match ref_pool.sample(&fk.ref_table, &fk.ref_columns, &mut rng) {
            Some(tuple) => {
                for (col, val) in fk.columns.iter().zip(tuple) {
                    values.insert(col.clone(), val);
                }
            }
            None => {
                let all_nullable = fk
                    .columns
                    .iter()
                    .all(|c| table.column(c).map(|cc| cc.nullable).unwrap_or(false));
                if all_nullable {
                    for c in &fk.columns {
                        values.insert(c.clone(), PgValue::Null);
                    }
                } else {
                    return Err(FeintError::Config(format!(
                        "table `{}` needs at least one row in `{}` to satisfy foreign key `{}`, but none exist \
                         (increase its `rows:` in feint.yaml, or configure this table after it)",
                        table.id.qualified(),
                        fk.ref_table.qualified(),
                        fk.name
                    )));
                }
            }
        }
    }

    for col in supplied {
        if values.contains_key(&col.name) {
            continue;
        }
        let override_generator = overrides
            .get(&col.name)
            .and_then(|c| c.generator.as_deref());
        let mut rng = derive_rng(
            global_seed,
            &SeedKey {
                table: &table_name,
                column: &col.name,
                row_identity,
            },
        );
        let value = generate_value(col, override_generator, &mut rng)?;
        values.insert(col.name.clone(), value);
    }

    Ok(supplied
        .iter()
        .map(|c| values.remove(&c.name).unwrap_or(PgValue::Null))
        .collect())
}

pub(crate) fn sql_cast_type(column: &Column) -> String {
    match &column.type_kind {
        crate::introspect::TypeKind::Array { elem_type } => format!("\"{elem_type}\"[]"),
        _ => format!("\"{}\"", column.type_name),
    }
}

pub(crate) async fn execute_batched_insert(
    txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    rows: &[Vec<PgValue>],
    returning: &[String],
    overriding_system_value: bool,
) -> Result<Vec<Vec<PgValue>>> {
    if rows.is_empty() || columns.is_empty() {
        return Ok(Vec::new());
    }
    let batch_rows = (MAX_BIND_PARAMS / columns.len()).clamp(1, MAX_BATCH_ROWS);
    let mut returned = Vec::with_capacity(rows.len());

    for chunk in rows.chunks(batch_rows) {
        let sql = build_insert_sql(
            table,
            columns,
            chunk.len(),
            returning,
            overriding_system_value,
        );
        let params: Vec<&(dyn ToSql + Sync)> = chunk
            .iter()
            .flat_map(|row| row.iter().map(|v| v as &(dyn ToSql + Sync)))
            .collect();
        let result_rows = txn.query(&sql, &params).await?;
        for row in result_rows {
            let mut tuple = Vec::with_capacity(returning.len());
            for i in 0..returning.len() {
                tuple.push(row.get::<_, PgValue>(i));
            }
            returned.push(tuple);
        }
    }

    Ok(returned)
}

pub(crate) fn build_insert_sql(
    table: &Table,
    columns: &[&Column],
    row_count: usize,
    returning: &[String],
    overriding_system_value: bool,
) -> String {
    let col_list = columns
        .iter()
        .map(|c| format!("\"{}\"", c.name))
        .collect::<Vec<_>>()
        .join(", ");

    let mut param_idx = 1;
    let mut value_groups = Vec::with_capacity(row_count);
    for _ in 0..row_count {
        let placeholders = columns
            .iter()
            .map(|c| {
                let p = format!("${}::{}", param_idx, sql_cast_type(c));
                param_idx += 1;
                p
            })
            .collect::<Vec<_>>()
            .join(", ");
        value_groups.push(format!("({placeholders})"));
    }

    let returning_clause = if returning.is_empty() {
        String::new()
    } else {
        format!(
            " RETURNING {}",
            returning
                .iter()
                .map(|c| format!("\"{c}\""))
                .collect::<Vec<_>>()
                .join(", ")
        )
    };

    let overriding_clause = if overriding_system_value {
        " OVERRIDING SYSTEM VALUE"
    } else {
        ""
    };

    format!(
        "INSERT INTO \"{}\".\"{}\" ({col_list}){overriding_clause} VALUES {}{returning_clause}",
        table.id.schema,
        table.id.name,
        value_groups.join(", ")
    )
}

fn register_returned(
    ref_pool: &mut RefPool,
    table: &Table,
    returning: &[String],
    rows: &[Vec<PgValue>],
) {
    for uc in &table.unique_constraints {
        let indices: Option<Vec<usize>> = uc
            .columns
            .iter()
            .map(|c| returning.iter().position(|r| r == c))
            .collect();
        let Some(indices) = indices else { continue };
        for row in rows {
            let tuple: Vec<PgValue> = indices.iter().map(|&i| row[i].clone()).collect();
            ref_pool.register(&table.id, &uc.columns, tuple);
        }
    }
}

/// `is_referenced` should be true if any table's foreign key points at
/// this one, anywhere in the schema. When it's false, nothing will ever
/// sample this table's rows from the `ref_pool`, so there's no need to
/// pay for `RETURNING` and registration at all — this table takes the
/// `COPY` path instead of chunked `INSERT`, which is the whole point:
/// this is exactly the case a high-volume padding/leaf table (events,
/// logs, line items) hits in practice.
pub(crate) async fn insert_plain_table(
    txn: &Transaction<'_>,
    table: &Table,
    planned_rows: u32,
    config: &FeintConfig,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &mut RefPool,
    is_referenced: bool,
) -> Result<u64> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);

    let columns = supplied_columns(table);
    let mut rows = Vec::with_capacity(planned_rows as usize);
    for i in 0..planned_rows {
        let row_identity = i.to_string();
        rows.push(generate_row(
            table,
            &columns,
            &row_identity,
            &config.seed,
            overrides,
            skip_fk_columns,
            ref_pool,
        )?);
    }

    if is_referenced {
        let returning = returning_columns(table);
        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);
    } else {
        crate::copy::copy_rows(txn, table, &columns, &rows).await?;
    }
    Ok(rows.len() as u64)
}

pub(crate) async fn insert_backfill_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    null_then_backfill: &[FkRef],
    config: &FeintConfig,
    ref_pool: &mut RefPool,
    progress: &mut impl FnMut(ProgressEvent),
) -> Result<Vec<(String, u64)>> {
    let mut skip_by_table: HashMap<TableId, HashSet<String>> = HashMap::new();
    for r in null_then_backfill {
        skip_by_table
            .entry(r.table.clone())
            .or_default()
            .extend(r.fk.columns.iter().cloned());
    }

    let mut results = Vec::new();
    // Track the primary key values captured per table+row so the backfill
    // UPDATE can target each row precisely.
    let mut captured_pks: HashMap<TableId, Vec<Vec<PgValue>>> = HashMap::new();

    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id);
        progress(ProgressEvent::TableStarted {
            table: &table_id.qualified(),
            planned_rows,
        });

        let empty = std::collections::BTreeMap::new();
        let overrides = config
            .table_config(&table_id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);
        let skip = skip_by_table.get(table_id).cloned().unwrap_or_default();
        let columns = supplied_columns(table);

        let mut rows = Vec::with_capacity(planned_rows as usize);
        for i in 0..planned_rows {
            rows.push(generate_row(
                table,
                &columns,
                &i.to_string(),
                &config.seed,
                overrides,
                &skip,
                ref_pool,
            )?);
        }

        let pk_cols = table
            .primary_key
            .clone()
            .ok_or_else(|| FeintError::Config(format!(
                "table `{}` is part of a foreign-key cycle resolved by null+backfill, but has no primary key to target the backfill UPDATE",
                table_id.qualified()
            )))?;

        let mut returning = returning_columns(table);
        for c in &pk_cols {
            if !returning.contains(c) {
                returning.push(c.clone());
            }
        }

        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);

        let pk_indices: Vec<usize> = pk_cols
            .iter()
            .map(|c| returning.iter().position(|r| r == c).unwrap())
            .collect();
        let pks: Vec<Vec<PgValue>> = returned
            .iter()
            .map(|row| pk_indices.iter().map(|&i| row[i].clone()).collect())
            .collect();
        captured_pks.insert(table_id.clone(), pks);

        progress(ProgressEvent::TableFinished {
            table: &table_id.qualified(),
            rows: rows.len() as u64,
        });
        results.push((table_id.qualified(), rows.len() as u64));
    }

    // Backfill: for each cyclic FK, and each row of its owning table,
    // sample a now-populated reference and UPDATE it in.
    for r in null_then_backfill {
        let table = schema.table(&r.table).expect("table exists");
        let pk_cols = table.primary_key.clone().expect("checked above");
        let pks = captured_pks.get(&r.table).cloned().unwrap_or_default();
        let table_name = r.table.qualified();

        for (row_idx, pk) in pks.iter().enumerate() {
            let mut rng = derive_rng(
                &config.seed,
                &SeedKey {
                    table: &table_name,
                    column: &r.fk.name,
                    row_identity: &row_idx.to_string(),
                },
            );
            let Some(tuple) = ref_pool.sample(&r.fk.ref_table, &r.fk.ref_columns, &mut rng) else {
                continue; // pool empty (e.g. 0 rows configured upstream) — leave NULL
            };

            let set_clause =
                r.fk.columns
                    .iter()
                    .enumerate()
                    .map(|(i, c)| {
                        format!(
                            "\"{c}\" = ${}::{}",
                            i + 1,
                            sql_cast_type(table.column(c).unwrap())
                        )
                    })
                    .collect::<Vec<_>>()
                    .join(", ");
            let where_offset = r.fk.columns.len();
            let where_clause = pk_cols
                .iter()
                .enumerate()
                .map(|(i, c)| {
                    format!(
                        "\"{c}\" = ${}::{}",
                        where_offset + i + 1,
                        sql_cast_type(table.column(c).unwrap())
                    )
                })
                .collect::<Vec<_>>()
                .join(" AND ");

            let sql = format!(
                "UPDATE \"{}\".\"{}\" SET {set_clause} WHERE {where_clause}",
                r.table.schema, r.table.name
            );
            let mut params: Vec<&(dyn ToSql + Sync)> =
                tuple.iter().map(|v| v as &(dyn ToSql + Sync)).collect();
            params.extend(pk.iter().map(|v| v as &(dyn ToSql + Sync)));
            txn.execute(&sql, &params).await?;
        }
    }

    Ok(results)
}

pub(crate) async fn insert_deferred_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    config: &FeintConfig,
    ref_pool: &mut RefPool,
    progress: &mut impl FnMut(ProgressEvent),
) -> Result<Vec<(String, u64)>> {
    // Deferred constraints let us insert rows before the row(s) they
    // reference exist in the DB (Postgres only checks at COMMIT), but
    // feint still has to know the *value* to write at insert time. That's
    // only possible when every table's referenced key in the cycle is
    // client-generated (e.g. a UUID default) rather than server-assigned
    // (serial/identity) — those aren't known until the DB assigns them.
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        for fk in &table.foreign_keys {
            if !tables.contains(&fk.ref_table) {
                continue;
            }
            let ref_table = schema.table(&fk.ref_table).expect("table exists");
            for c in &fk.ref_columns {
                if let Some(col) = ref_table.column(c) {
                    if col.is_server_assigned() {
                        return Err(FeintError::Config(format!(
                            "table `{}` has a deferrable foreign-key cycle through `{}`, but `{}`.`{}` is a \
                             server-assigned (serial/identity) column feint can't pre-generate a value for. \
                             Make the referencing column nullable instead, or use a client-generated key \
                             (e.g. a UUID default) for `{}`.",
                            table_id.qualified(),
                            fk.ref_table.qualified(),
                            fk.ref_table.qualified(),
                            c,
                            fk.ref_table.qualified()
                        )));
                    }
                }
            }
        }
    }

    // Pass 1: generate every non-cyclic column for every row of every
    // table in the group, and register unique-constraint tuples as soon
    // as they're fully known so cyclic FKs (resolved in pass 2) can
    // sample them regardless of which table in the group comes "first".
    let mut cyclic_columns: HashMap<TableId, HashSet<String>> = HashMap::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let mut cols = HashSet::new();
        for fk in &table.foreign_keys {
            if tables.contains(&fk.ref_table) {
                cols.extend(fk.columns.iter().cloned());
            }
        }
        cyclic_columns.insert(table_id.clone(), cols);
    }

    let mut partial_rows: HashMap<TableId, Vec<Vec<PgValue>>> = HashMap::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id);
        let empty = std::collections::BTreeMap::new();
        let overrides = config
            .table_config(&table_id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);
        let columns = supplied_columns(table);
        let skip = cyclic_columns.get(table_id).cloned().unwrap_or_default();

        let mut rows = Vec::with_capacity(planned_rows as usize);
        for i in 0..planned_rows {
            rows.push(generate_row(
                table,
                &columns,
                &i.to_string(),
                &config.seed,
                overrides,
                &skip,
                ref_pool,
            )?);
        }

        // Register unique-constraint tuples that don't touch a cyclic
        // column — almost always the primary key.
        for uc in &table.unique_constraints {
            if uc.columns.iter().any(|c| skip.contains(c)) {
                continue;
            }
            let indices: Vec<usize> = uc
                .columns
                .iter()
                .map(|c| columns.iter().position(|s| &s.name == c).unwrap())
                .collect();
            for row in &rows {
                let tuple: Vec<PgValue> = indices.iter().map(|&i| row[i].clone()).collect();
                ref_pool.register(table_id, &uc.columns, tuple);
            }
        }

        partial_rows.insert(table_id.clone(), rows);
    }

    // Pass 2: resolve the cyclic columns now that every table's
    // non-cyclic (usually PK) values are registered.
    let mut results = Vec::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id);
        progress(ProgressEvent::TableStarted {
            table: &table_id.qualified(),
            planned_rows,
        });

        let columns = supplied_columns(table);
        let mut rows = partial_rows.remove(table_id).unwrap_or_default();
        let skip = cyclic_columns.get(table_id).cloned().unwrap_or_default();
        let table_name = table_id.qualified();

        for (row_idx, row) in rows.iter_mut().enumerate() {
            for fk in &table.foreign_keys {
                if !fk.columns.iter().any(|c| skip.contains(c)) {
                    continue;
                }
                let mut rng = derive_rng(
                    &config.seed,
                    &SeedKey {
                        table: &table_name,
                        column: &fk.name,
                        row_identity: &row_idx.to_string(),
                    },
                );
                let tuple = ref_pool.sample(&fk.ref_table, &fk.ref_columns, &mut rng);
                if let Some(tuple) = tuple {
                    for (col_name, val) in fk.columns.iter().zip(tuple) {
                        if let Some(pos) = columns.iter().position(|c| &c.name == col_name) {
                            row[pos] = val;
                        }
                    }
                }
            }
        }

        let returning = returning_columns(table);
        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);

        progress(ProgressEvent::TableFinished {
            table: &table_id.qualified(),
            rows: rows.len() as u64,
        });
        results.push((table_id.qualified(), rows.len() as u64));
    }

    Ok(results)
}
