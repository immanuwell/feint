//! Mask-in-place: rewrite a single database's own sensitive columns,
//! batched and resumable.
//!
//! Unlike `clone` (source and target are always different databases, so
//! the source is never touched and stays a stable reference no matter how
//! many times you run), mask-in-place reads and writes the *same* row.
//! That makes a naive re-run unsafe: `mask::MaskStrategy::Hash` is keyed
//! off the real value at read time, and a partially-masked table would
//! hash its own already-masked output on a second pass. The fix is
//! structural, not detection-based: a checkpoint table records the last
//! primary key processed per table, and each batch's `UPDATE` commits in
//! the *same* transaction as its checkpoint advance — a batch is either
//! fully applied and checkpointed, or not applied at all, so no row is
//! ever read and masked more than once, ever, across any number of
//! resumed runs.

use std::collections::BTreeMap;

use postgres_types::ToSql;
use tokio_postgres::{Client, Transaction};

use crate::config::FeintConfig;
use crate::error::{FeintError, Result};
use crate::insert::sql_cast_type;
use crate::introspect::{Schema, Table, TableId, MASK_CHECKPOINT_TABLE as CHECKPOINT_TABLE};
use crate::mask::{self, validate_masking_config, MaskStrategy};
use crate::value::PgValue;

const MAX_BIND_PARAMS: usize = 60_000;

#[derive(Debug, Clone)]
pub struct ColumnMaskPlan {
    pub name: String,
    pub strategy: MaskStrategy,
}

#[derive(Debug, Clone)]
pub struct TableMaskPlan {
    pub table: TableId,
    pub columns: Vec<ColumnMaskPlan>,
    pub primary_key: Vec<String>,
}

#[derive(Debug, Clone, Default)]
pub struct SanitizePlan {
    /// Only tables with at least one column resolving to a non-`none`
    /// mask strategy — a table with nothing to mask is left out entirely.
    pub tables: Vec<TableMaskPlan>,
}

/// Resolve which tables/columns need masking. Reuses `mask`'s validation
/// and resolution logic unchanged. A table that has something to mask but
/// no primary key is rejected — mask-in-place needs a stable, orderable
/// key to batch and checkpoint against safely.
pub fn plan_sanitization(schema: &Schema, config: &FeintConfig) -> Result<SanitizePlan> {
    validate_masking_config(schema, config)?;

    let mut tables = Vec::new();
    for table in &schema.tables {
        let empty = BTreeMap::new();
        let overrides = config
            .table_config(&table.id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);

        let mut columns = Vec::new();
        for column in &table.columns {
            if column.is_stored_generated {
                continue; // never legal to write to, regardless of masking
            }
            let override_strategy = overrides.get(&column.name).and_then(|c| c.mask);
            let strategy = mask::resolve_mask_strategy(table, column, override_strategy);
            if strategy == MaskStrategy::None {
                continue;
            }
            columns.push(ColumnMaskPlan {
                name: column.name.clone(),
                strategy,
            });
        }

        if columns.is_empty() {
            continue;
        }

        let Some(primary_key) = table.primary_key.clone() else {
            return Err(FeintError::Config(format!(
                "table `{}` has columns to mask ({}) but no primary key — mask-in-place needs a \
                 primary key to batch and checkpoint safely. Add a primary key, or set `mask: none` \
                 on its sensitive columns to skip it explicitly.",
                table.id.qualified(),
                columns.iter().map(|c| c.name.as_str()).collect::<Vec<_>>().join(", ")
            )));
        };

        tables.push(TableMaskPlan {
            table: table.id.clone(),
            columns,
            primary_key,
        });
    }

    Ok(SanitizePlan { tables })
}

pub struct DryRunTableReport {
    pub table: String,
    pub columns: Vec<(String, MaskStrategy)>,
    pub row_count: i64,
}

/// Report what a real run would touch, without writing anything.
pub async fn dry_run(
    client: &Client,
    schema: &Schema,
    plan: &SanitizePlan,
) -> Result<Vec<DryRunTableReport>> {
    let mut out = Vec::with_capacity(plan.tables.len());
    for t in &plan.tables {
        let table = schema.table(&t.table).expect("table exists");
        let row_count = row_count(client, table).await?;
        out.push(DryRunTableReport {
            table: t.table.qualified(),
            columns: t
                .columns
                .iter()
                .map(|c| (c.name.clone(), c.strategy))
                .collect(),
            row_count,
        });
    }
    Ok(out)
}

pub enum ProgressEvent<'a> {
    TableStarted { table: &'a str },
    BatchCommitted { table: &'a str, rows: u64 },
    TableFinished { table: &'a str, rows: u64 },
}

#[derive(Debug)]
pub struct SanitizeSummary {
    pub rows_by_table: Vec<(String, u64)>,
    pub total_rows: u64,
}

/// Run the mask-in-place pass. `resume` must be `true` to continue a
/// prior interrupted run (found via the checkpoint table); a fresh run
/// refuses to start if unfinished progress already exists, forcing a
/// conscious choice rather than silently mixing the two.
///
/// `max_batches`, if set, stops the whole run (cleanly, mid-way, with a
/// legitimate checkpoint left behind) after that many batches have
/// committed across all tables combined — useful for pacing a very large
/// run across multiple invocations, or for testing resume behavior
/// against a genuinely partial, honestly-checkpointed run rather than a
/// simulated one.
#[allow(clippy::too_many_arguments)]
pub async fn run_sanitization(
    client: &mut Client,
    schema: &Schema,
    plan: &SanitizePlan,
    config: &FeintConfig,
    batch_size: usize,
    resume: bool,
    max_batches: Option<usize>,
    mut progress: impl FnMut(ProgressEvent),
) -> Result<SanitizeSummary> {
    ensure_checkpoint_table(client).await?;
    if !resume {
        reject_if_progress_exists(client, plan).await?;
    }

    let mut rows_by_table = Vec::new();
    let mut total_rows = 0u64;
    let mut batches_run = 0usize;

    'tables: for table_plan in &plan.tables {
        let table = schema.table(&table_plan.table).expect("table exists");
        let table_name = table_plan.table.qualified();
        progress(ProgressEvent::TableStarted { table: &table_name });

        let before_count = row_count(client, table).await?;

        let checkpoint = load_checkpoint(client, &table_plan.table).await?;
        if checkpoint.completed {
            progress(ProgressEvent::TableFinished {
                table: &table_name,
                rows: 0,
            });
            rows_by_table.push((table_name, 0));
            continue;
        }

        let row_width = table_plan.primary_key.len() + table_plan.columns.len();
        let effective_batch_size = batch_size.clamp(1, (MAX_BIND_PARAMS / row_width.max(1)).max(1));

        let mut last_pk = checkpoint.last_pk;
        let mut table_rows = 0u64;

        loop {
            let txn = client.transaction().await?;
            let batch =
                fetch_batch(&txn, table, table_plan, &last_pk, effective_batch_size).await?;

            if batch.is_empty() {
                mark_completed(&txn, &table_plan.table).await?;
                txn.commit().await?;
                break;
            }

            let n = batch.len() as u64;
            apply_batch(&txn, table, table_plan, config, &batch).await?;
            let new_last_pk = pk_text_values(table_plan.primary_key.len(), batch.last().unwrap());
            let is_last_batch = batch.len() < effective_batch_size;
            save_checkpoint(&txn, &table_plan.table, &new_last_pk, is_last_batch).await?;
            txn.commit().await?;

            last_pk = new_last_pk;
            table_rows += n;
            total_rows += n;
            batches_run += 1;
            progress(ProgressEvent::BatchCommitted {
                table: &table_name,
                rows: n,
            });

            if is_last_batch {
                break;
            }
            if max_batches.is_some_and(|max| batches_run >= max) {
                progress(ProgressEvent::TableFinished {
                    table: &table_name,
                    rows: table_rows,
                });
                rows_by_table.push((table_name, table_rows));
                break 'tables;
            }
        }

        let after_count = row_count(client, table).await?;
        if before_count != after_count {
            return Err(FeintError::Config(format!(
                "row-count invariant violated on `{table_name}`: {before_count} rows before masking, \
                 {after_count} after. Masking only ever runs UPDATE, never DELETE/TRUNCATE — this \
                 indicates something else wrote to this table concurrently during the run."
            )));
        }

        progress(ProgressEvent::TableFinished {
            table: &table_name,
            rows: table_rows,
        });
        rows_by_table.push((table_name, table_rows));
    }

    Ok(SanitizeSummary {
        rows_by_table,
        total_rows,
    })
}

async fn row_count(client: &Client, table: &Table) -> Result<i64> {
    let row = client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{}\".\"{}\"",
                table.id.schema, table.id.name
            ),
            &[],
        )
        .await?;
    Ok(row.get(0))
}

fn pk_text_values(pk_len: usize, row: &[PgValue]) -> Vec<String> {
    row[..pk_len].iter().map(PgValue::as_text_literal).collect()
}

async fn fetch_batch(
    txn: &Transaction<'_>,
    table: &Table,
    table_plan: &TableMaskPlan,
    last_pk: &[String],
    batch_size: usize,
) -> Result<Vec<Vec<PgValue>>> {
    let pk_cols = &table_plan.primary_key;
    let select_cols: Vec<&str> = pk_cols
        .iter()
        .map(String::as_str)
        .chain(table_plan.columns.iter().map(|c| c.name.as_str()))
        .collect();
    let col_list = select_cols
        .iter()
        .map(|c| format!("\"{c}\""))
        .collect::<Vec<_>>()
        .join(", ");
    let order_list = pk_cols
        .iter()
        .map(|c| format!("\"{c}\""))
        .collect::<Vec<_>>()
        .join(", ");

    let mut owned_params: Vec<PgValue> = Vec::new();
    let where_clause = if last_pk.is_empty() {
        String::new()
    } else {
        let pk_tuple = pk_cols
            .iter()
            .map(|c| format!("\"{c}\""))
            .collect::<Vec<_>>()
            .join(", ");
        let placeholders = pk_cols
            .iter()
            .enumerate()
            .map(|(i, c)| {
                format!(
                    "${}::{}",
                    i + 1,
                    sql_cast_type(table.column(c).expect("pk column exists"))
                )
            })
            .collect::<Vec<_>>()
            .join(", ");
        owned_params = last_pk.iter().map(|v| PgValue::Raw(v.clone())).collect();
        format!("WHERE ({pk_tuple}) > ({placeholders})")
    };

    let sql = format!(
        "SELECT {col_list} FROM \"{}\".\"{}\" {where_clause} ORDER BY {order_list} LIMIT {batch_size}",
        table.id.schema, table.id.name
    );
    let params: Vec<&(dyn ToSql + Sync)> = owned_params
        .iter()
        .map(|v| v as &(dyn ToSql + Sync))
        .collect();
    let rows = txn.query(&sql, &params).await?;

    let mut out = Vec::with_capacity(rows.len());
    for row in rows {
        let mut tuple = Vec::with_capacity(select_cols.len());
        for i in 0..select_cols.len() {
            tuple.push(row.get::<_, PgValue>(i));
        }
        out.push(tuple);
    }
    Ok(out)
}

async fn apply_batch(
    txn: &Transaction<'_>,
    table: &Table,
    table_plan: &TableMaskPlan,
    config: &FeintConfig,
    batch: &[Vec<PgValue>],
) -> Result<()> {
    let pk_cols = &table_plan.primary_key;
    let pk_count = pk_cols.len();
    let table_name = table_plan.table.qualified();

    let empty = BTreeMap::new();
    let overrides = config
        .table_config(&table_name)
        .map(|t| &t.columns)
        .unwrap_or(&empty);

    let mut masked_rows: Vec<Vec<PgValue>> = Vec::with_capacity(batch.len());
    for row in batch {
        let pk_vals = &row[..pk_count];
        let row_identity = pk_vals
            .iter()
            .map(PgValue::as_text_literal)
            .collect::<Vec<_>>()
            .join("\0");
        let mut out_row = pk_vals.to_vec();
        for (i, col_plan) in table_plan.columns.iter().enumerate() {
            let real_value = &row[pk_count + i];
            let column = table.column(&col_plan.name).expect("column exists");
            let generator_override = overrides
                .get(&col_plan.name)
                .and_then(|c| c.generator.as_deref());
            let masked = mask::mask_value(
                col_plan.strategy,
                column,
                generator_override,
                real_value,
                &config.seed,
                &table_name,
                &row_identity,
            )?;
            out_row.push(masked);
        }
        masked_rows.push(out_row);
    }

    let mask_col_names: Vec<&str> = table_plan.columns.iter().map(|c| c.name.as_str()).collect();
    let value_alias_cols: Vec<String> = (0..pk_count)
        .map(|i| format!("pk{i}"))
        .chain((0..mask_col_names.len()).map(|i| format!("c{i}")))
        .collect();

    let mut param_idx = 1usize;
    let mut value_groups = Vec::with_capacity(masked_rows.len());
    for row in &masked_rows {
        let mut placeholders = Vec::with_capacity(row.len());
        for i in 0..row.len() {
            let cast = if i < pk_count {
                sql_cast_type(table.column(&pk_cols[i]).expect("pk column exists"))
            } else {
                sql_cast_type(
                    table
                        .column(mask_col_names[i - pk_count])
                        .expect("mask column exists"),
                )
            };
            placeholders.push(format!("${param_idx}::{cast}"));
            param_idx += 1;
        }
        value_groups.push(format!("({})", placeholders.join(", ")));
    }

    let set_clause = mask_col_names
        .iter()
        .enumerate()
        .map(|(i, c)| format!("\"{c}\" = v.c{i}"))
        .collect::<Vec<_>>()
        .join(", ");
    let join_clause = (0..pk_count)
        .map(|i| format!("t.\"{}\" = v.pk{i}", pk_cols[i]))
        .collect::<Vec<_>>()
        .join(" AND ");

    let sql = format!(
        "UPDATE \"{}\".\"{}\" AS t SET {set_clause} FROM (VALUES {}) AS v({}) WHERE {join_clause}",
        table.id.schema,
        table.id.name,
        value_groups.join(", "),
        value_alias_cols.join(", ")
    );
    let params: Vec<&(dyn ToSql + Sync)> = masked_rows
        .iter()
        .flat_map(|r| r.iter().map(|v| v as &(dyn ToSql + Sync)))
        .collect();
    txn.execute(&sql, &params).await?;
    Ok(())
}

async fn ensure_checkpoint_table(client: &Client) -> Result<()> {
    client
        .batch_execute(&format!(
            "CREATE TABLE IF NOT EXISTS \"{CHECKPOINT_TABLE}\" (
                table_name text PRIMARY KEY,
                last_pk text[] NOT NULL DEFAULT '{{}}',
                completed boolean NOT NULL DEFAULT false,
                updated_at timestamptz NOT NULL DEFAULT now()
            )"
        ))
        .await?;
    Ok(())
}

struct Checkpoint {
    last_pk: Vec<String>,
    completed: bool,
}

async fn load_checkpoint(client: &Client, table: &TableId) -> Result<Checkpoint> {
    let row = client
        .query_opt(
            &format!("SELECT last_pk, completed FROM \"{CHECKPOINT_TABLE}\" WHERE table_name = $1"),
            &[&table.qualified()],
        )
        .await?;
    Ok(match row {
        Some(r) => Checkpoint {
            last_pk: r.get(0),
            completed: r.get(1),
        },
        None => Checkpoint {
            last_pk: Vec::new(),
            completed: false,
        },
    })
}

async fn save_checkpoint(
    txn: &Transaction<'_>,
    table: &TableId,
    last_pk: &[String],
    completed: bool,
) -> Result<()> {
    txn.execute(
        &format!(
            "INSERT INTO \"{CHECKPOINT_TABLE}\" (table_name, last_pk, completed, updated_at) \
             VALUES ($1, $2, $3, now()) \
             ON CONFLICT (table_name) DO UPDATE SET last_pk = EXCLUDED.last_pk, completed = EXCLUDED.completed, updated_at = now()"
        ),
        &[&table.qualified(), &last_pk, &completed],
    )
    .await?;
    Ok(())
}

async fn mark_completed(txn: &Transaction<'_>, table: &TableId) -> Result<()> {
    txn.execute(
        &format!(
            "INSERT INTO \"{CHECKPOINT_TABLE}\" (table_name, completed, updated_at) \
             VALUES ($1, true, now()) \
             ON CONFLICT (table_name) DO UPDATE SET completed = true, updated_at = now()"
        ),
        &[&table.qualified()],
    )
    .await?;
    Ok(())
}

async fn reject_if_progress_exists(client: &Client, plan: &SanitizePlan) -> Result<()> {
    for t in &plan.tables {
        let row = client
            .query_opt(
                &format!("SELECT 1 FROM \"{CHECKPOINT_TABLE}\" WHERE table_name = $1"),
                &[&t.table.qualified()],
            )
            .await?;
        if row.is_some() {
            return Err(FeintError::Config(format!(
                "found existing mask-in-place progress for `{}` from a previous run. Pass --resume \
                 to continue it, or clear the `{CHECKPOINT_TABLE}` table yourself to start over.",
                t.table.qualified()
            )));
        }
    }
    Ok(())
}
