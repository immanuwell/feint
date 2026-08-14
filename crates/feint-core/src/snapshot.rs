//! `feint snapshot` / `feint restore`: capture a `clone`-shaped read from a
//! source database into a single file, and replay it into a target
//! database later without ever needing a live connection to the source
//! again.
//!
//! The file only ever needs to carry the already-masked row data and the
//! column names it belongs to — nothing about insertion order, foreign-key
//! cycle handling, or SQL types. `restore` recomputes all of that fresh
//! from the *target* database's own introspected schema, exactly the way
//! `clone` recomputes it from the source's schema on every run. This is
//! what keeps the file format small and the two sides of the split
//! trivially consistent with each other.
//!
//! Deliberately out of scope for now: a table with `strategy: generate`
//! (see `clone.rs`'s hybrid mode). A `generate` table's rows need a live
//! target connection to resolve server-assigned columns via `RETURNING`,
//! which a file replay can't provide. `capture` rejects a config with any
//! `generate`-strategy table rather than silently only snapshotting part
//! of a hybrid run.

use std::collections::HashMap;
use std::io::{Read, Write};
use std::path::Path;

use serde::{Deserialize, Serialize};
use tokio_postgres::Transaction;

use crate::clone::{self, table_strategy};
use crate::config::{FeintConfig, TableStrategy};
use crate::error::{FeintError, Result};
use crate::graph::InsertGroup;
use crate::insert::sql_cast_type;
use crate::introspect::{Column, Schema, Table, TableId};
use crate::mask::validate_masking_config;
use crate::subset::SubsetRows;
use crate::value::PgValue;

const FORMAT_VERSION: u32 = 1;

#[derive(Debug, Serialize, Deserialize)]
struct SnapshotTable {
    schema: String,
    name: String,
    /// Column names in the same order as each row's values. Not
    /// necessarily the same order the target's own schema will report —
    /// `restore` reindexes by name, not position.
    columns: Vec<String>,
    rows: Vec<Vec<PgValue>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SnapshotFile {
    format_version: u32,
    tables: Vec<SnapshotTable>,
}

#[derive(Debug)]
pub struct SnapshotSummary {
    pub rows_by_table: Vec<(String, u64)>,
    pub total_rows: u64,
}

/// Reads every table's real rows from `source_txn`, masking them exactly
/// as `clone` would, and returns the result as an in-memory [`SnapshotFile`]
/// ready to write to disk. Rejects (before reading anything) a config that
/// sets `strategy: generate` on any table — see the module doc.
pub async fn capture(
    source_txn: &Transaction<'_>,
    schema: &Schema,
    config: &FeintConfig,
    subset: Option<&SubsetRows>,
) -> Result<SnapshotFile> {
    validate_masking_config(schema, config)?;
    for table in &schema.tables {
        if table_strategy(config, &table.id) != TableStrategy::Mask {
            return Err(FeintError::Config(format!(
                "table `{}` is `strategy: generate` — `feint snapshot` doesn't support hybrid \
                 runs yet, only real (masked) rows. A generate-strategy table needs a live \
                 target connection to resolve server-assigned columns, which a snapshot file \
                 can't provide. Remove the `strategy:` override for this run, or exclude the \
                 table from the config.",
                table.id.qualified()
            )));
        }
    }

    let mut tables = Vec::with_capacity(schema.tables.len());
    for table in &schema.tables {
        let columns = clone::clone_supplied_columns(table);
        let rows = clone::read_table_rows(source_txn, table, &columns, subset).await?;
        let rows = clone::mask_rows(table, &columns, rows, config)?;
        tables.push(SnapshotTable {
            schema: table.id.schema.clone(),
            name: table.id.name.clone(),
            columns: columns.iter().map(|c| c.name.clone()).collect(),
            rows,
        });
    }

    Ok(SnapshotFile {
        format_version: FORMAT_VERSION,
        tables,
    })
}

impl SnapshotFile {
    pub fn table_count(&self) -> usize {
        self.tables.len()
    }

    pub fn total_rows(&self) -> u64 {
        self.tables.iter().map(|t| t.rows.len() as u64).sum()
    }

    /// gzip-compressed bincode. Both are load-bearing: bincode keeps a
    /// large row set compact and fast to (de)serialize; gzip cuts real
    /// database exports (long runs of similar strings, repeated column
    /// structure) down further on top of that.
    pub fn write_to_file(&self, path: &Path) -> Result<()> {
        let bytes = bincode::serialize(self)
            .map_err(|e| FeintError::Config(format!("failed to encode snapshot: {e}")))?;
        let file = std::fs::File::create(path)?;
        let mut encoder = flate2::write::GzEncoder::new(file, flate2::Compression::default());
        encoder.write_all(&bytes)?;
        encoder.finish()?;
        Ok(())
    }

    pub fn read_from_file(path: &Path) -> Result<Self> {
        let file = std::fs::File::open(path)?;
        let mut decoder = flate2::read::GzDecoder::new(file);
        let mut bytes = Vec::new();
        decoder.read_to_end(&mut bytes)?;
        let snapshot: SnapshotFile = bincode::deserialize(&bytes).map_err(|e| {
            FeintError::Config(format!(
                "failed to decode snapshot file {}: {e} (not a feint snapshot, or corrupted)",
                path.display()
            ))
        })?;
        if snapshot.format_version != FORMAT_VERSION {
            return Err(FeintError::Config(format!(
                "snapshot file {} is format version {}, but this build of feint only \
                 understands version {FORMAT_VERSION}. Recapture it with a matching feint \
                 version.",
                path.display(),
                snapshot.format_version
            )));
        }
        Ok(snapshot)
    }

    /// The distinct set of schema names this snapshot has data for — used
    /// to introspect exactly the right schemas on the target without the
    /// caller having to pass `--schema` again.
    pub fn schema_names(&self) -> Vec<String> {
        let mut seen = std::collections::BTreeSet::new();
        for t in &self.tables {
            seen.insert(t.schema.clone());
        }
        seen.into_iter().collect()
    }
}

/// Reindex `rows` (captured in `snapshot_columns` order) into `target_columns`
/// order, by column name. Every target column must be present in the
/// snapshot and vice versa — a mismatch means the schema drifted between
/// capture and restore, which needs a human to look at, not a guess.
fn reindex_rows(
    table_name: &str,
    snapshot_columns: &[String],
    target_columns: &[&Column],
    rows: &[Vec<PgValue>],
) -> Result<Vec<Vec<PgValue>>> {
    if snapshot_columns.len() != target_columns.len() {
        return Err(FeintError::Config(format!(
            "table `{table_name}` has {} column(s) in the snapshot but {} in the target schema \
             — the schema changed since this snapshot was captured. Recapture it, or make the \
             target schema match.",
            snapshot_columns.len(),
            target_columns.len()
        )));
    }
    let snap_index: HashMap<&str, usize> = snapshot_columns
        .iter()
        .enumerate()
        .map(|(i, name)| (name.as_str(), i))
        .collect();
    let mut positions = Vec::with_capacity(target_columns.len());
    for col in target_columns {
        let Some(&idx) = snap_index.get(col.name.as_str()) else {
            return Err(FeintError::Config(format!(
                "table `{table_name}` column `{}` exists in the target schema but not in the \
                 snapshot — the schema changed since this snapshot was captured. Recapture it, \
                 or make the target schema match.",
                col.name
            )));
        };
        positions.push(idx);
    }
    Ok(rows
        .iter()
        .map(|r| positions.iter().map(|&i| r[i].clone()).collect())
        .collect())
}

/// Replays a snapshot into `target_txn`. `target_schema`/`plan` must come
/// from introspecting the target database itself, not the original source
/// — this is what lets `restore` recompute insertion order and foreign-key
/// cycle handling fresh, with no cycle/ordering metadata stored in the
/// file at all. A table `plan` expects but the snapshot has no data for
/// (e.g. a `--root` snapshot that never touched it) is left empty, the
/// same way a `--root` clone leaves an unrelated table empty.
pub async fn restore(
    target_txn: &Transaction<'_>,
    target_schema: &Schema,
    plan: &crate::graph::InsertPlan,
    snapshot: &SnapshotFile,
) -> Result<SnapshotSummary> {
    target_txn
        .batch_execute("SET CONSTRAINTS ALL DEFERRED")
        .await?;

    let by_table: HashMap<TableId, &SnapshotTable> = snapshot
        .tables
        .iter()
        .map(|t| {
            (
                TableId {
                    schema: t.schema.clone(),
                    name: t.name.clone(),
                },
                t,
            )
        })
        .collect();

    let mut rows_by_table = Vec::new();
    let mut total_rows = 0u64;

    for group in &plan.groups {
        match group {
            InsertGroup::Simple(table_id) => {
                let table = target_schema.table(table_id).expect("table exists");
                let n = restore_table(target_txn, table, &by_table).await?;
                rows_by_table.push((table_id.qualified(), n));
                total_rows += n;
            }
            InsertGroup::Deferred(tables) => {
                for table_id in tables {
                    let table = target_schema.table(table_id).expect("table exists");
                    let n = restore_table(target_txn, table, &by_table).await?;
                    rows_by_table.push((table_id.qualified(), n));
                    total_rows += n;
                }
            }
            InsertGroup::Backfill {
                tables,
                null_then_backfill,
            } => {
                let n = restore_backfill_group(
                    target_txn,
                    target_schema,
                    tables,
                    null_then_backfill,
                    &by_table,
                )
                .await?;
                for (t, c) in n {
                    total_rows += c;
                    rows_by_table.push((t, c));
                }
            }
        }
    }

    Ok(SnapshotSummary {
        rows_by_table,
        total_rows,
    })
}

async fn restore_table(
    target_txn: &Transaction<'_>,
    table: &Table,
    by_table: &HashMap<TableId, &SnapshotTable>,
) -> Result<u64> {
    let Some(snap) = by_table.get(&table.id) else {
        return Ok(0);
    };
    let columns = clone::clone_supplied_columns(table);
    let rows = reindex_rows(&table.id.qualified(), &snap.columns, &columns, &snap.rows)?;
    let overriding = clone::needs_overriding_system_value(&columns);
    crate::copy::bulk_insert_no_returning(target_txn, table, &columns, &rows, overriding).await?;
    clone::resync_sequences(target_txn, table, &columns, &rows).await?;
    Ok(rows.len() as u64)
}

async fn restore_backfill_group(
    target_txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    null_then_backfill: &[crate::graph::FkRef],
    by_table: &HashMap<TableId, &SnapshotTable>,
) -> Result<Vec<(String, u64)>> {
    let mut skip_by_table: HashMap<TableId, std::collections::HashSet<String>> = HashMap::new();
    for r in null_then_backfill {
        skip_by_table
            .entry(r.table.clone())
            .or_default()
            .extend(r.fk.columns.iter().cloned());
    }

    let mut results = Vec::new();
    let mut table_rows: HashMap<TableId, (Vec<&Column>, Vec<Vec<PgValue>>)> = HashMap::new();

    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let columns = clone::clone_supplied_columns(table);
        let full_rows = match by_table.get(table_id) {
            Some(snap) => reindex_rows(&table_id.qualified(), &snap.columns, &columns, &snap.rows)?,
            None => Vec::new(),
        };

        let skip = skip_by_table.get(table_id).cloned().unwrap_or_default();
        let skip_indices: Vec<usize> = columns
            .iter()
            .enumerate()
            .filter(|(_, c)| skip.contains(&c.name))
            .map(|(i, _)| i)
            .collect();

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

        let overriding = clone::needs_overriding_system_value(&columns);
        crate::copy::bulk_insert_no_returning(
            target_txn,
            table,
            &columns,
            &insert_rows,
            overriding,
        )
        .await?;
        clone::resync_sequences(target_txn, table, &columns, &full_rows).await?;

        results.push((table_id.qualified(), full_rows.len() as u64));
        table_rows.insert(table_id.clone(), (columns, full_rows));
    }

    for r in null_then_backfill {
        let table = schema.table(&r.table).expect("table exists");
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
            let mut params: Vec<&(dyn postgres_types::ToSql + Sync)> = fk_positions
                .iter()
                .map(|&i| &row[i] as &(dyn postgres_types::ToSql + Sync))
                .collect();
            params.extend(
                pk_positions
                    .iter()
                    .map(|&i| &row[i] as &(dyn postgres_types::ToSql + Sync)),
            );
            target_txn.execute(&sql, &params).await?;
        }
    }

    Ok(results)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_snapshot() -> SnapshotFile {
        SnapshotFile {
            format_version: FORMAT_VERSION,
            tables: vec![SnapshotTable {
                schema: "public".to_string(),
                name: "users".to_string(),
                columns: vec!["id".to_string(), "email".to_string()],
                rows: vec![
                    vec![PgValue::Int4(1), PgValue::Text("a@example.com".to_string())],
                    vec![PgValue::Int4(2), PgValue::Null],
                ],
            }],
        }
    }

    #[test]
    fn snapshot_file_round_trips_through_disk() {
        let dir = std::env::temp_dir().join(format!("feint-snapshot-unit-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("test.bin");

        let original = sample_snapshot();
        original.write_to_file(&path).unwrap();
        let loaded = SnapshotFile::read_from_file(&path).unwrap();

        assert_eq!(loaded.total_rows(), 2);
        assert_eq!(loaded.table_count(), 1);
        assert_eq!(loaded.tables[0].rows, original.tables[0].rows);

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn a_future_format_version_is_rejected_rather_than_misread() {
        let dir = std::env::temp_dir().join(format!(
            "feint-snapshot-version-unit-{}",
            std::process::id()
        ));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("test.bin");

        let mut future = sample_snapshot();
        future.format_version = FORMAT_VERSION + 1;
        future.write_to_file(&path).unwrap();

        let err = SnapshotFile::read_from_file(&path)
            .expect_err("a newer format version must be rejected, not silently misparsed");
        assert!(matches!(err, FeintError::Config(_)));
        assert!(format!("{err}").contains("version"));

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn schema_names_returns_the_distinct_set_across_tables() {
        let snapshot = SnapshotFile {
            format_version: FORMAT_VERSION,
            tables: vec![
                SnapshotTable {
                    schema: "public".to_string(),
                    name: "users".to_string(),
                    columns: vec![],
                    rows: vec![],
                },
                SnapshotTable {
                    schema: "billing".to_string(),
                    name: "invoices".to_string(),
                    columns: vec![],
                    rows: vec![],
                },
                SnapshotTable {
                    schema: "public".to_string(),
                    name: "orders".to_string(),
                    columns: vec![],
                    rows: vec![],
                },
            ],
        };
        assert_eq!(
            snapshot.schema_names(),
            vec!["billing".to_string(), "public".to_string()]
        );
    }
}
