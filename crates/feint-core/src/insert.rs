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

    /// Every tuple registered for `(table, columns)`, in registration
    /// order. Used for profile-driven cardinality generation, which needs
    /// to visit each parent row exactly once (to decide its own number of
    /// children) rather than sampling one at random.
    pub(crate) fn all(&self, table: &TableId, columns: &[String]) -> &[Vec<PgValue>] {
        let key = (table.clone(), columns.to_vec());
        self.pools.get(&key).map(Vec::as_slice).unwrap_or(&[])
    }
}

pub async fn run(
    txn: &Transaction<'_>,
    schema: &Schema,
    plan: &InsertPlan,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
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
                progress(ProgressEvent::TableStarted {
                    table: &table_id.qualified(),
                    planned_rows: rows_for(config, table_id, profile),
                });
                let n = match cardinality_driving_fk(table, profile) {
                    Some((fk, cardinality)) => {
                        insert_plain_table_with_cardinality(
                            txn,
                            table,
                            fk,
                            cardinality,
                            config,
                            profile,
                            &mut ref_pool,
                            referenced_tables.contains(table_id),
                        )
                        .await?
                    }
                    None => {
                        insert_plain_table(
                            txn,
                            table,
                            rows_for(config, table_id, profile),
                            config,
                            profile,
                            &HashSet::new(),
                            &mut ref_pool,
                            referenced_tables.contains(table_id),
                        )
                        .await?
                    }
                };
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
                    profile,
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
                    profile,
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

/// `rows:` from `feint.yaml` wins when a table is explicitly configured.
/// Otherwise, a loaded profile's captured `row_count` (see `profile.rs`)
/// is a better default than the fixed fallback — it's what the real
/// database this profile came from actually had.
pub(crate) fn rows_for(
    config: &FeintConfig,
    table_id: &TableId,
    profile: Option<&crate::profile::ProfileFile>,
) -> u32 {
    if let Some(t) = config.table_config(&table_id.qualified()) {
        return t.rows;
    }
    if let Some(row_count) = profile.and_then(|p| p.table(&table_id.qualified())) {
        if row_count.row_count > 0 {
            return row_count.row_count.min(u32::MAX as u64) as u32;
        }
    }
    crate::config::DEFAULT_ROWS
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

/// Finds the first foreign key on `table` that a loaded profile has a
/// captured cardinality histogram for. That FK's parent row count drives
/// how many rows of `table` get generated and how they're distributed —
/// see `insert_plain_table_with_cardinality`. Any other FK on the same
/// table still gets a per-row uniform sample from the `RefPool`, same as
/// without a profile at all.
fn cardinality_driving_fk<'a>(
    table: &'a Table,
    profile: Option<&'a crate::profile::ProfileFile>,
) -> Option<(
    &'a crate::introspect::ForeignKey,
    &'a crate::profile::CardinalityProfile,
)> {
    let table_profile = profile?.table(&table.id.qualified())?;
    table
        .foreign_keys
        .iter()
        .find_map(|fk| table_profile.cardinality.get(&fk.name).map(|c| (fk, c)))
}

/// Weighted-random pick of a `children_count` from a cardinality
/// histogram. Falls back to 0 if the histogram is somehow empty or every
/// weight is zero — never panics, never fabricates a count the profile
/// didn't actually observe.
fn sample_cardinality(histogram: &[(u32, u64)], rng: &mut rand_chacha::ChaCha8Rng) -> u32 {
    let total: u64 = histogram.iter().map(|(_, weight)| *weight).sum();
    if total == 0 {
        return 0;
    }
    let mut roll = rng.gen_range(0..total);
    for (count, weight) in histogram {
        if roll < *weight {
            return *count;
        }
        roll -= *weight;
    }
    histogram.last().map(|(count, _)| *count).unwrap_or(0)
}

/// Generate one row's values for `supplied_columns`, in order.
/// `skip_fk_columns` names FK columns to leave NULL (Backfill first pass);
/// pass `&HashSet::new()` for a plain insert. `profile`, if loaded, rolls
/// a deterministic weighted coin for any nullable column with a captured
/// null fraction, instead of `generate_value`'s normal never-null default.
#[allow(clippy::too_many_arguments)]
fn generate_row(
    table: &Table,
    supplied: &[&Column],
    row_identity: &str,
    global_seed: &str,
    overrides: &std::collections::BTreeMap<String, crate::config::ColumnConfig>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &RefPool,
    profile: Option<&crate::profile::ProfileFile>,
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

    let null_fractions = profile
        .and_then(|p| p.table(&table_name))
        .map(|t| &t.null_fractions);

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
        let null_fraction = if col.nullable {
            null_fractions
                .and_then(|f| f.get(&col.name))
                .copied()
                .unwrap_or(0.0)
        } else {
            0.0
        };
        // Rolled from the same RNG stream, before generating the value —
        // keeps the whole row deterministic per seed without a second
        // `derive_rng` call, and a 0.0 fraction (the overwhelming common
        // case: no profile, or a column the profile never saw NULL) never
        // touches the RNG differently than before this feature existed.
        let value = if null_fraction > 0.0 && rng.gen::<f64>() < null_fraction {
            PgValue::Null
        } else {
            generate_value(col, override_generator, &mut rng)?
        };
        values.insert(col.name.clone(), value);
    }

    Ok(supplied
        .iter()
        .map(|c| values.remove(&c.name).unwrap_or(PgValue::Null))
        .collect())
}

/// How many times a single row is regenerated before giving up on avoiding
/// a collision with one of the table's own UNIQUE constraints — well above
/// what any real FK-pool-exhaustion case should need, but finite so a
/// genuinely-too-small parent pool fails with a clear error instead of
/// looping forever.
const MAX_UNIQUE_RETRY_ATTEMPTS: u32 = 50;

/// Index sets (into `columns`) for each of `table`'s UNIQUE constraints —
/// including the primary key — skipping any constraint whose columns
/// aren't all in `columns` (e.g. a server-assigned PK, which Postgres's own
/// sequence already keeps unique without feint's help).
fn unique_key_index_sets(table: &Table, columns: &[&Column]) -> Vec<Vec<usize>> {
    table
        .unique_constraints
        .iter()
        .filter_map(|uc| {
            uc.columns
                .iter()
                .map(|c| columns.iter().position(|col| &col.name == c))
                .collect::<Option<Vec<usize>>>()
        })
        .collect()
}

/// Generate one row, retrying with a different derived seed if it collides
/// with an already-generated row of the same batch on any of `table`'s
/// UNIQUE constraints. Plain per-row-independent `RefPool` sampling has no
/// way to know about sibling rows in the same batch, so a composite or
/// single-column UNIQUE foreign key — Miniflux's `integrations.user_id` (a
/// 1:1 PK-as-FK), Listmonk's `roles` table's `UNIQUE (parent_id, list_id)`
/// — can otherwise collide at random and crash the whole batch on a
/// duplicate-key error. NULLs are never considered a collision, matching
/// Postgres's own default (non-`NULLS NOT DISTINCT`) unique semantics.
#[allow(clippy::too_many_arguments)]
fn generate_unique_row(
    table: &Table,
    columns: &[&Column],
    row_index: u64,
    global_seed: &str,
    overrides: &std::collections::BTreeMap<String, crate::config::ColumnConfig>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &RefPool,
    profile: Option<&crate::profile::ProfileFile>,
    key_sets: &[Vec<usize>],
    seen: &mut [Vec<Vec<PgValue>>],
) -> Result<Vec<PgValue>> {
    for attempt in 0..=MAX_UNIQUE_RETRY_ATTEMPTS {
        let row_identity = if attempt == 0 {
            row_index.to_string()
        } else {
            format!("{row_index}#retry{attempt}")
        };
        let row = generate_row(
            table,
            columns,
            &row_identity,
            global_seed,
            overrides,
            skip_fk_columns,
            ref_pool,
            profile,
        )?;

        let tuples: Vec<Option<Vec<PgValue>>> = key_sets
            .iter()
            .map(|key| {
                let tuple: Vec<PgValue> = key.iter().map(|&i| row[i].clone()).collect();
                if tuple.iter().any(PgValue::is_null) {
                    None
                } else {
                    Some(tuple)
                }
            })
            .collect();
        let collides = tuples
            .iter()
            .zip(seen.iter())
            .any(|(tuple, seen_rows)| matches!(tuple, Some(t) if seen_rows.contains(t)));
        if !collides {
            for (tuple, seen_rows) in tuples.into_iter().zip(seen.iter_mut()) {
                if let Some(t) = tuple {
                    seen_rows.push(t);
                }
            }
            return Ok(row);
        }
    }
    Err(FeintError::Config(format!(
        "table `{}` couldn't generate row {} without violating one of its own UNIQUE \
         constraints after {MAX_UNIQUE_RETRY_ATTEMPTS} attempts — the referenced table(s) \
         likely don't have enough distinct rows to fill it uniquely (increase their `rows:` \
         in feint.yaml)",
        table.id.qualified(),
        row_index + 1,
    )))
}

pub(crate) fn sql_cast_type(column: &Column) -> String {
    match &column.type_kind {
        crate::introspect::TypeKind::Array { elem_type, .. } => format!("\"{elem_type}\"[]"),
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
    if rows.is_empty() {
        return Ok(Vec::new());
    }

    if columns.is_empty() {
        // PostgreSQL has no multi-row `DEFAULT VALUES` form. This case is
        // rare (a table made entirely of serial/identity/stored-generated
        // columns), so issue one statement per planned row. Unlike the old
        // early return, this both creates the real rows and captures any
        // server-assigned keys needed by downstream foreign keys.
        let sql = build_default_insert_sql(table, returning, overriding_system_value);
        let mut returned = Vec::with_capacity(rows.len());
        for _ in rows {
            let result_rows = txn.query(&sql, &[]).await?;
            for row in result_rows {
                let mut tuple = Vec::with_capacity(returning.len());
                for i in 0..returning.len() {
                    tuple.push(row.get::<_, PgValue>(i));
                }
                returned.push(tuple);
            }
        }
        return Ok(returned);
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

fn build_default_insert_sql(
    table: &Table,
    returning: &[String],
    overriding_system_value: bool,
) -> String {
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
        "INSERT INTO \"{}\".\"{}\"{overriding_clause} DEFAULT VALUES{returning_clause}",
        table.id.schema, table.id.name
    )
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
#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_plain_table(
    txn: &Transaction<'_>,
    table: &Table,
    planned_rows: u32,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
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
    let key_sets = unique_key_index_sets(table, &columns);
    let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];
    let mut rows = Vec::with_capacity(planned_rows as usize);
    for i in 0..planned_rows {
        rows.push(generate_unique_row(
            table,
            &columns,
            i as u64,
            &config.seed,
            overrides,
            skip_fk_columns,
            ref_pool,
            profile,
            &key_sets,
            &mut seen,
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

/// A `Simple`-group table whose first profiled foreign key already has
/// its parent rows generated (guaranteed by topological order). Instead
/// of a flat `planned_rows` count, visits each parent row once, draws a
/// `children_count` from the captured histogram (deterministically, keyed
/// on the parent's own index), and generates that many child rows
/// pointing at it — the actual mechanism behind [`crate::profile`]'s
/// whole reason to exist: a long tail instead of a uniform count.
#[allow(clippy::too_many_arguments)]
async fn insert_plain_table_with_cardinality(
    txn: &Transaction<'_>,
    table: &Table,
    driving_fk: &crate::introspect::ForeignKey,
    cardinality: &crate::profile::CardinalityProfile,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    ref_pool: &mut RefPool,
    is_referenced: bool,
) -> Result<u64> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);
    let columns = supplied_columns(table);
    let table_name = table.id.qualified();

    // Snapshot the parent pool up front: `ref_pool` is read-only for the
    // rest of this function (every FK, including `driving_fk` itself,
    // still goes through `generate_row`'s normal sampling — its pick for
    // `driving_fk` just gets overwritten below), so this shared borrow
    // and the later mutable one for registration don't overlap.
    let parents: Vec<Vec<PgValue>> = ref_pool
        .all(&driving_fk.ref_table, &driving_fk.ref_columns)
        .to_vec();

    let fk_positions: Vec<usize> = driving_fk
        .columns
        .iter()
        .filter_map(|c| columns.iter().position(|col| &col.name == c))
        .collect();

    let mut rows = Vec::new();
    let mut row_index: u64 = 0;
    for (parent_idx, parent_tuple) in parents.iter().enumerate() {
        let mut count_rng = derive_rng(
            &config.seed,
            &SeedKey {
                table: &table_name,
                column: &driving_fk.name,
                row_identity: &parent_idx.to_string(),
            },
        );
        let children = sample_cardinality(&cardinality.histogram, &mut count_rng);

        for _ in 0..children {
            let row_identity = row_index.to_string();
            row_index += 1;
            let mut row = generate_row(
                table,
                &columns,
                &row_identity,
                &config.seed,
                overrides,
                &HashSet::new(),
                ref_pool,
                profile,
            )?;
            for (&pos, val) in fk_positions.iter().zip(parent_tuple.iter()) {
                row[pos] = val.clone();
            }
            rows.push(row);
        }
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

#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_backfill_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    null_then_backfill: &[FkRef],
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
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
    // Full `RETURNING` rows (every unique-constraint column, by
    // construction of `returning_columns`) + the column list they're
    // indexed against — lets the backfill pass below check a freshly
    // backfilled FK value against sibling unique-constraint columns whose
    // values were already fixed in the initial insert (e.g. Listmonk's
    // `roles` table: `list_id` is fixed up front, `parent_id` is
    // backfilled after, and `UNIQUE (parent_id, list_id)` needs both).
    let mut captured_returning: HashMap<TableId, (Vec<String>, Vec<Vec<PgValue>>)> = HashMap::new();

    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id, profile);
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
        let key_sets = unique_key_index_sets(table, &columns);
        let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];

        let mut rows = Vec::with_capacity(planned_rows as usize);
        for i in 0..planned_rows {
            rows.push(generate_unique_row(
                table,
                &columns,
                i as u64,
                &config.seed,
                overrides,
                &skip,
                ref_pool,
                profile,
                &key_sets,
                &mut seen,
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
        captured_returning.insert(table_id.clone(), (returning, returned));

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

        // Unique constraints this backfilled FK actually participates in —
        // its sibling columns' values are already fixed from the initial
        // insert (captured in `returning`/`returned` above), so a
        // collision on the *combination* only becomes checkable once this
        // FK's real value is chosen here.
        let (returning, returned) = captured_returning
            .get(&r.table)
            .cloned()
            .unwrap_or_default();
        let relevant_constraints: Vec<Vec<usize>> = table
            .unique_constraints
            .iter()
            .filter(|uc| uc.columns.iter().any(|c| r.fk.columns.contains(c)))
            .filter_map(|uc| {
                uc.columns
                    .iter()
                    .map(|c| returning.iter().position(|ret| ret == c))
                    .collect::<Option<Vec<usize>>>()
            })
            .collect();
        let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); relevant_constraints.len()];

        for (row_idx, pk) in pks.iter().enumerate() {
            let mut tuple = None;
            let mut pool_was_empty = false;
            for attempt in 0..=MAX_UNIQUE_RETRY_ATTEMPTS {
                let row_identity = if attempt == 0 {
                    row_idx.to_string()
                } else {
                    format!("{row_idx}#retry{attempt}")
                };
                let mut rng = derive_rng(
                    &config.seed,
                    &SeedKey {
                        table: &table_name,
                        column: &r.fk.name,
                        row_identity: &row_identity,
                    },
                );
                let Some(candidate) = ref_pool.sample(&r.fk.ref_table, &r.fk.ref_columns, &mut rng)
                else {
                    pool_was_empty = true;
                    break; // pool empty (e.g. 0 rows configured upstream) — leave NULL
                };

                let candidate_tuples: Vec<Vec<PgValue>> = relevant_constraints
                    .iter()
                    .map(|key| {
                        key.iter()
                            .map(|&i| {
                                if let Some(pos) = r.fk.columns.iter().position(|c| {
                                    returning.get(i).map(|ret| ret == c).unwrap_or(false)
                                }) {
                                    candidate[pos].clone()
                                } else {
                                    returned[row_idx][i].clone()
                                }
                            })
                            .collect()
                    })
                    .collect();
                let collides = candidate_tuples
                    .iter()
                    .zip(seen.iter())
                    .any(|(t, s)| !t.iter().any(PgValue::is_null) && s.contains(t));
                if !collides {
                    for (t, s) in candidate_tuples.into_iter().zip(seen.iter_mut()) {
                        if !t.iter().any(PgValue::is_null) {
                            s.push(t);
                        }
                    }
                    tuple = Some(candidate);
                    break;
                }
            }
            let Some(tuple) = tuple else {
                if pool_was_empty {
                    continue; // pool was empty — leave NULL, as before
                }
                return Err(FeintError::Config(format!(
                    "table `{}` couldn't backfill foreign key `{}` for row {} without violating \
                     one of its own UNIQUE constraints after {MAX_UNIQUE_RETRY_ATTEMPTS} attempts \
                     — the referenced table(s) likely don't have enough distinct rows to fill it \
                     uniquely (increase their `rows:` in feint.yaml)",
                    r.table.qualified(),
                    r.fk.name,
                    row_idx + 1,
                )));
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

#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_deferred_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
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
        let planned_rows = rows_for(config, table_id, profile);
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
                profile,
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
        let planned_rows = rows_for(config, table_id, profile);
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
