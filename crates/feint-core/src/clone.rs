//! Direct database-to-database clone: reads real rows from a source
//! Postgres connection and writes them to a target connection, preserving
//! primary keys and foreign keys exactly as they are on the source.
//!
//! Unlike `insert.rs` (GENERATE mode), no `RefPool`/remapping is needed —
//! every value, including FK-owning columns, is already known from the
//! source `SELECT` before any target write happens. This is deliberately
//! a separate, simpler orchestration loop rather than a reuse of
//! `insert_plain_table`/`insert_backfill_group`/`insert_deferred_group`,
//! which exist specifically to solve GENERATE mode's "don't know the
//! target PK until the DB assigns/returns it" problem.

use std::collections::{HashMap, HashSet};

use postgres_types::ToSql;
use tokio_postgres::Transaction;

use crate::config::FeintConfig;
use crate::error::{FeintError, Result};
use crate::graph::{FkRef, InsertGroup, InsertPlan};
use crate::insert::{execute_batched_insert, sql_cast_type};
use crate::introspect::{Column, Identity, Schema, Table, TableId};
use crate::mask::{self, validate_masking_config};
use crate::subset::SubsetRows;
use crate::value::PgValue;

pub enum ProgressEvent<'a> {
    TableStarted { table: &'a str },
    TableFinished { table: &'a str, rows: u64 },
}

#[derive(Debug)]
pub struct CloneSummary {
    pub rows_by_table: Vec<(String, u64)>,
    pub total_rows: u64,
}

/// Columns CLONE mode supplies a value for. Unlike GENERATE mode's
/// `insert::supplied_columns`, this *includes* `Identity::Always` columns
/// (CLONE mode wants to preserve the source's real value, which requires
/// `OVERRIDING SYSTEM VALUE`) and serial/identity-by-default columns
/// (an explicit value is always legal there, same as GENERATE mode
/// already relies on). Only stored-generated columns are excluded — no
/// Postgres clause exists to override those.
pub(crate) fn clone_supplied_columns(table: &Table) -> Vec<&Column> {
    table
        .columns
        .iter()
        .filter(|c| !c.is_stored_generated)
        .collect()
}

pub(crate) fn needs_overriding_system_value(columns: &[&Column]) -> bool {
    columns.iter().any(|c| c.identity == Identity::Always)
}

/// `subset` is `None` for a full-database clone (read every row) or
/// `Some` for a `--root`-subsetted clone, in which case the rows for this
/// table were already selected by `subset::compute_subset` and are used
/// as-is (a table absent from the map contributes zero rows).
async fn read_table_rows(
    source_txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    subset: Option<&SubsetRows>,
) -> Result<Vec<Vec<PgValue>>> {
    if let Some(subset) = subset {
        return Ok(subset.get(&table.id).cloned().unwrap_or_default());
    }

    let col_list = columns
        .iter()
        .map(|c| format!("\"{}\"", c.name))
        .collect::<Vec<_>>()
        .join(", ");
    let sql = format!(
        "SELECT {col_list} FROM \"{}\".\"{}\"",
        table.id.schema, table.id.name
    );
    let rows = source_txn.query(&sql, &[]).await?;
    let mut out = Vec::with_capacity(rows.len());
    for row in rows {
        let mut tuple = Vec::with_capacity(columns.len());
        for i in 0..columns.len() {
            tuple.push(row.get::<_, PgValue>(i));
        }
        out.push(tuple);
    }
    Ok(out)
}

/// Apply each column's masking strategy to every row, using the row's
/// pristine (pre-mask) values for the identity key so `fake` masking
/// stays keyed on the real source row regardless of which other columns
/// in the same row already got masked.
fn mask_rows(
    table: &Table,
    columns: &[&Column],
    rows: Vec<Vec<PgValue>>,
    config: &FeintConfig,
) -> Result<Vec<Vec<PgValue>>> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);
    let table_name = table.id.qualified();

    rows.into_iter()
        .map(|row| {
            let row_identity = mask::row_identity_key(table, columns, &row);
            columns
                .iter()
                .enumerate()
                .map(|(i, col)| {
                    let override_strategy = overrides.get(&col.name).and_then(|c| c.mask);
                    let strategy = mask::resolve_mask_strategy(table, col, override_strategy);
                    let generator_override = overrides
                        .get(&col.name)
                        .and_then(|c| c.generator.as_deref());
                    mask::mask_value(
                        strategy,
                        col,
                        generator_override,
                        &row[i],
                        &config.seed,
                        &table_name,
                        &row_identity,
                    )
                })
                .collect::<Result<Vec<PgValue>>>()
        })
        .collect()
}

fn pgvalue_as_i64(value: &PgValue) -> Option<i64> {
    match value {
        PgValue::Int2(v) => Some(*v as i64),
        PgValue::Int4(v) => Some(*v as i64),
        PgValue::Int8(v) => Some(*v),
        _ => None,
    }
}

/// Postgres never advances a `nextval()`-backed sequence (or an identity
/// column's internal sequence) when you supply an explicit value — only
/// `nextval()` itself does. Without this, the very next unrelated insert
/// against the target collides with a duplicate key. Runs once per table
/// right after that table's rows are written, using the max value already
/// in hand rather than a follow-up `SELECT MAX(...)`.
async fn resync_sequences(
    target_txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    rows: &[Vec<PgValue>],
) -> Result<()> {
    for (idx, col) in columns.iter().enumerate() {
        if !(col.is_serial_default || col.identity != Identity::None) {
            continue;
        }
        let Some(max_value) = rows.iter().filter_map(|r| pgvalue_as_i64(&r[idx])).max() else {
            continue;
        };
        let qualified = format!("{}.{}", table.id.schema, table.id.name);
        let seq_row = target_txn
            .query_one(
                "SELECT pg_get_serial_sequence($1, $2)",
                &[&qualified, &col.name],
            )
            .await?;
        let seq_name: Option<String> = seq_row.get(0);
        if let Some(seq_name) = seq_name {
            // `setval`'s first parameter is `regclass`, and tokio-postgres
            // refuses to bind a `String` to a regclass-typed placeholder
            // (its `ToSql` impl only accepts text-family OIDs). `seq_name`
            // comes straight from `pg_get_serial_sequence`, not user input,
            // so it's safe to inline as a single-quoted literal — Postgres
            // does the usual implicit text->regclass cast, same as typing
            // `SELECT setval('my_seq', 100)` directly.
            let literal = seq_name.replace('\'', "''");
            target_txn
                .execute(
                    &format!("SELECT setval('{literal}', $1, true)"),
                    &[&max_value],
                )
                .await?;
        }
    }
    Ok(())
}

pub async fn run(
    source_txn: &Transaction<'_>,
    target_txn: &Transaction<'_>,
    schema: &Schema,
    plan: &InsertPlan,
    config: &FeintConfig,
    subset: Option<&SubsetRows>,
    mut progress: impl FnMut(ProgressEvent),
) -> Result<CloneSummary> {
    validate_masking_config(schema, config)?;
    target_txn
        .batch_execute("SET CONSTRAINTS ALL DEFERRED")
        .await?;

    let mut rows_by_table = Vec::new();
    let mut total_rows = 0u64;

    for group in &plan.groups {
        match group {
            InsertGroup::Simple(table_id) => {
                let table = schema.table(table_id).expect("table exists in schema");
                progress(ProgressEvent::TableStarted {
                    table: &table_id.qualified(),
                });
                let n = clone_table_full(source_txn, target_txn, table, config, subset).await?;
                progress(ProgressEvent::TableFinished {
                    table: &table_id.qualified(),
                    rows: n,
                });
                rows_by_table.push((table_id.qualified(), n));
                total_rows += n;
            }
            InsertGroup::Deferred(tables) => {
                for table_id in tables {
                    let table = schema.table(table_id).expect("table exists in schema");
                    progress(ProgressEvent::TableStarted {
                        table: &table_id.qualified(),
                    });
                    let n = clone_table_full(source_txn, target_txn, table, config, subset).await?;
                    progress(ProgressEvent::TableFinished {
                        table: &table_id.qualified(),
                        rows: n,
                    });
                    rows_by_table.push((table_id.qualified(), n));
                    total_rows += n;
                }
            }
            InsertGroup::Backfill {
                tables,
                null_then_backfill,
            } => {
                let n = clone_backfill_group(
                    source_txn,
                    target_txn,
                    schema,
                    tables,
                    null_then_backfill,
                    config,
                    subset,
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

    Ok(CloneSummary {
        rows_by_table,
        total_rows,
    })
}

async fn clone_table_full(
    source_txn: &Transaction<'_>,
    target_txn: &Transaction<'_>,
    table: &Table,
    config: &FeintConfig,
    subset: Option<&SubsetRows>,
) -> Result<u64> {
    let columns = clone_supplied_columns(table);
    let rows = read_table_rows(source_txn, table, &columns, subset).await?;
    let rows = mask_rows(table, &columns, rows, config)?;
    let overriding = needs_overriding_system_value(&columns);
    execute_batched_insert(target_txn, table, &columns, &rows, &[], overriding).await?;
    resync_sequences(target_txn, table, &columns, &rows).await?;
    Ok(rows.len() as u64)
}

#[allow(clippy::too_many_arguments)]
async fn clone_backfill_group(
    source_txn: &Transaction<'_>,
    target_txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    null_then_backfill: &[FkRef],
    config: &FeintConfig,
    subset: Option<&SubsetRows>,
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
    let mut table_rows: HashMap<TableId, (Vec<&Column>, Vec<Vec<PgValue>>)> = HashMap::new();

    for table_id in tables {
        let table = schema.table(table_id).expect("table exists in schema");
        progress(ProgressEvent::TableStarted {
            table: &table_id.qualified(),
        });

        let columns = clone_supplied_columns(table);
        let full_rows = read_table_rows(source_txn, table, &columns, subset).await?;
        let full_rows = mask_rows(table, &columns, full_rows, config)?;

        let skip = skip_by_table.get(table_id).cloned().unwrap_or_default();
        let skip_indices: Vec<usize> = columns
            .iter()
            .enumerate()
            .filter(|(_, c)| skip.contains(&c.name))
            .map(|(i, _)| i)
            .collect();

        // These columns are nullable by construction: `graph::plan_insertion`
        // only chooses the Backfill strategy when every cyclic FK column is
        // nullable, so writing Null here can never violate NOT NULL.
        let insert_rows: Vec<Vec<PgValue>> = full_rows
            .iter()
            .map(|row| {
                let mut r = row.clone();
                for &i in &skip_indices {
                    r[i] = PgValue::Null;
                }
                r
            })
            .collect();

        let overriding = needs_overriding_system_value(&columns);
        execute_batched_insert(target_txn, table, &columns, &insert_rows, &[], overriding).await?;
        resync_sequences(target_txn, table, &columns, &full_rows).await?;

        progress(ProgressEvent::TableFinished {
            table: &table_id.qualified(),
            rows: full_rows.len() as u64,
        });
        results.push((table_id.qualified(), full_rows.len() as u64));
        table_rows.insert(table_id.clone(), (columns, full_rows));
    }

    // Backfill: UPDATE the nulled columns back to their real source values,
    // now that every row in the cycle exists on target.
    for r in null_then_backfill {
        let table = schema.table(&r.table).expect("table exists in schema");
        let pk_cols = table.primary_key.clone().ok_or_else(|| {
            FeintError::Config(format!(
                "table `{}` is part of a foreign-key cycle resolved by null+backfill, but has no \
                 primary key to target the backfill UPDATE",
                r.table.qualified()
            ))
        })?;
        let (columns, full_rows) = table_rows.get(&r.table).expect("rows were read above");
        let col_positions: HashMap<&str, usize> = columns
            .iter()
            .enumerate()
            .map(|(i, c)| (c.name.as_str(), i))
            .collect();
        let pk_positions: Vec<usize> = pk_cols.iter().map(|c| col_positions[c.as_str()]).collect();
        let fk_positions: Vec<usize> =
            r.fk.columns
                .iter()
                .map(|c| col_positions[c.as_str()])
                .collect();

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

        for row in full_rows {
            let mut params: Vec<&(dyn ToSql + Sync)> = fk_positions
                .iter()
                .map(|&i| &row[i] as &(dyn ToSql + Sync))
                .collect();
            params.extend(pk_positions.iter().map(|&i| &row[i] as &(dyn ToSql + Sync)));
            target_txn.execute(&sql, &params).await?;
        }
    }

    Ok(results)
}
