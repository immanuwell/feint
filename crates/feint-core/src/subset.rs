//! `--root` subsetting for CLONE mode: given a root condition, walk the
//! FK graph outward (forward BFS, "what references this?") to find
//! everything that logically belongs to the subset, then walk it inward
//! (backward closure, "what does this need to exist?") to guarantee
//! referential integrity, without unbounding the subset in the process.
//!
//! Two strictly sequential phases — forward BFS runs to a complete
//! fixpoint first, only then does backward closure start — because
//! interleaving them would make a `required`-only row's promotion to
//! `primary` (and re-expansion) depend on arbitrary processing order.
//! A `required`-only row's own children are never pulled in: that's what
//! keeps the subset bounded (a `products` row required by one
//! `order_items` row must not drag in every other order referencing that
//! product).

use std::collections::{HashMap, HashSet, VecDeque};

use postgres_types::ToSql;
use tokio_postgres::Transaction;

use crate::clone::clone_supplied_columns;
use crate::error::{FeintError, Result};
use crate::introspect::{select_column_expression, Column, Schema, Table, TableId};
use crate::mask::row_identity_key;
use crate::value::PgValue;

/// Rows selected for a `--root`-subsetted clone, keyed by table, each row
/// in [`clone_supplied_columns`] order for that table — the same shape
/// `clone::run` expects.
pub type SubsetRows = HashMap<TableId, Vec<Vec<PgValue>>>;

pub struct SubsetRoot {
    pub table: TableId,
    pub condition: String,
}

/// Parse `"<table> WHERE <condition>"` into a table reference (validated
/// against the introspected schema) and a raw SQL condition. The
/// condition is intentionally passed straight through to the source
/// database: it's operator-provided SQL against a database the operator
/// already holds credentials for, not attacker input, and arbitrary
/// WHERE clauses aren't generally parameterizable.
pub fn parse_root(schema: &Schema, root: &str) -> Result<SubsetRoot> {
    let lower = root.to_ascii_lowercase();
    let Some(idx) = lower.find(" where ") else {
        return Err(FeintError::Config(format!(
            "--root must look like \"<table> WHERE <condition>\", e.g. \
             \"public.organizations WHERE id = 42\" (got: {root:?})"
        )));
    };
    let table_part = root[..idx].trim();
    let condition = root[idx + " where ".len()..].trim().to_string();
    if table_part.is_empty() {
        return Err(FeintError::Config(
            "--root is missing a table name before WHERE".to_string(),
        ));
    }
    if condition.is_empty() {
        return Err(FeintError::Config(
            "--root's WHERE condition is empty".to_string(),
        ));
    }

    let table = resolve_table(schema, table_part)?;
    Ok(SubsetRoot { table, condition })
}

fn resolve_table(schema: &Schema, table_part: &str) -> Result<TableId> {
    if let Some((s, n)) = table_part.split_once('.') {
        let id = TableId {
            schema: s.trim_matches('"').to_string(),
            name: n.trim_matches('"').to_string(),
        };
        return if schema.table(&id).is_some() {
            Ok(id)
        } else {
            Err(FeintError::Config(format!(
                "--root table `{table_part}` was not found in the introspected schema"
            )))
        };
    }

    let bare = table_part.trim_matches('"');
    let matches: Vec<&Table> = schema.tables.iter().filter(|t| t.id.name == bare).collect();
    match matches.len() {
        0 => Err(FeintError::Config(format!(
            "--root table `{table_part}` was not found in the introspected schema"
        ))),
        1 => Ok(matches[0].id.clone()),
        _ => Err(FeintError::Config(format!(
            "--root table `{table_part}` is ambiguous across schemas ({}); qualify it as schema.table",
            matches.iter().map(|t| t.id.qualified()).collect::<Vec<_>>().join(", ")
        ))),
    }
}

pub struct SubsetOptions {
    /// Total row count across the whole closure, checked incrementally
    /// during BFS (not just at the end) so a self-referencing table's
    /// runaway expansion is caught early rather than after a lot of
    /// wasted querying. Hitting this aborts the whole clone before any
    /// target write happens — a partially-computed closure isn't a
    /// smaller valid subset, it's a subset with dangling references.
    pub max_rows: usize,
}

impl Default for SubsetOptions {
    fn default() -> Self {
        Self { max_rows: 200_000 }
    }
}

fn decode_rows(rows: Vec<tokio_postgres::Row>, ncols: usize) -> Vec<Vec<PgValue>> {
    rows.into_iter()
        .map(|row| (0..ncols).map(|i| row.get::<_, PgValue>(i)).collect())
        .collect()
}

async fn fetch_rows_where(
    source_txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    condition: &str,
) -> Result<Vec<Vec<PgValue>>> {
    let col_list = columns
        .iter()
        .map(|c| select_column_expression(c))
        .collect::<Vec<_>>()
        .join(", ");
    let sql = format!(
        "SELECT {col_list} FROM \"{}\".\"{}\" WHERE {condition}",
        table.id.schema, table.id.name
    );
    let rows = source_txn.query(&sql, &[]).await?;
    Ok(decode_rows(rows, columns.len()))
}

/// Fetch every row of `table` whose `match_columns` values equal one of
/// `key_tuples` — a batched `WHERE (match_columns...) IN (...)` query.
/// Postgres row-IN syntax degrades to a plain scalar `IN` when there's
/// only one match column (single-element parens aren't a row
/// constructor), so this needs no special-casing for that common case.
async fn fetch_rows_matching(
    source_txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    match_columns: &[String],
    key_tuples: &[Vec<PgValue>],
) -> Result<Vec<Vec<PgValue>>> {
    if key_tuples.is_empty() {
        return Ok(Vec::new());
    }

    // BFS can rediscover the same parent key many times; dedupe before
    // querying to keep the IN-list (and the batching below) small.
    let mut seen = HashSet::new();
    let mut unique_tuples: Vec<&Vec<PgValue>> = Vec::new();
    for t in key_tuples {
        let key = t
            .iter()
            .map(PgValue::as_text_literal)
            .collect::<Vec<_>>()
            .join("\0");
        if seen.insert(key) {
            unique_tuples.push(t);
        }
    }

    let col_list = columns
        .iter()
        .map(|c| select_column_expression(c))
        .collect::<Vec<_>>()
        .join(", ");
    let match_list = match_columns
        .iter()
        .map(|c| format!("\"{c}\""))
        .collect::<Vec<_>>()
        .join(", ");
    let batch_size = (60_000 / match_columns.len().max(1)).clamp(1, 5_000);

    let mut out = Vec::new();
    for chunk in unique_tuples.chunks(batch_size) {
        let mut param_idx = 1usize;
        let mut groups = Vec::with_capacity(chunk.len());
        for tuple in chunk {
            let placeholders = (0..tuple.len())
                .map(|_| {
                    let p = format!("${param_idx}");
                    param_idx += 1;
                    p
                })
                .collect::<Vec<_>>()
                .join(", ");
            groups.push(format!("({placeholders})"));
        }
        let sql = format!(
            "SELECT {col_list} FROM \"{}\".\"{}\" WHERE ({match_list}) IN ({})",
            table.id.schema,
            table.id.name,
            groups.join(", ")
        );
        let params: Vec<&(dyn ToSql + Sync)> = chunk
            .iter()
            .flat_map(|t| t.iter().map(|v| v as &(dyn ToSql + Sync)))
            .collect();
        let rows = source_txn.query(&sql, &params).await?;
        out.extend(decode_rows(rows, columns.len()));
    }
    Ok(out)
}

fn check_cap(total: usize, options: &SubsetOptions, table: &TableId) -> Result<()> {
    if total > options.max_rows {
        return Err(FeintError::Config(format!(
            "--root subset exceeded the safety cap of {} rows while expanding `{}` — nothing was \
             written to the target. Narrow --root to a smaller condition (a self-referencing or \
             highly connected table is the usual cause).",
            options.max_rows,
            table.qualified()
        )));
    }
    Ok(())
}

/// Compute the row set for a `--root`-subsetted clone: forward BFS from
/// the root condition to a complete fixpoint (marking every row found
/// this way `primary`), then backward closure over FK-owned columns to
/// fixpoint (pulling in whatever parent rows are required for referential
/// integrity, marked `required`, without re-expanding forward from them).
pub async fn compute_subset(
    source_txn: &Transaction<'_>,
    schema: &Schema,
    root: &SubsetRoot,
    options: &SubsetOptions,
) -> Result<SubsetRows> {
    let mut included: HashMap<TableId, HashMap<String, Vec<PgValue>>> = HashMap::new();
    let mut total = 0usize;

    // Phase 1: forward BFS, primary rows only, to a complete fixpoint.
    let root_table = schema.table(&root.table).expect("resolved by parse_root");
    let root_columns = clone_supplied_columns(root_table);
    let root_rows =
        fetch_rows_where(source_txn, root_table, &root_columns, &root.condition).await?;

    let mut queue: VecDeque<(TableId, Vec<Vec<PgValue>>)> = VecDeque::new();
    if !root_rows.is_empty() {
        let table_map = included.entry(root.table.clone()).or_default();
        for row in &root_rows {
            let key = row_identity_key(root_table, &root_columns, row);
            if table_map.insert(key, row.clone()).is_none() {
                total += 1;
            }
        }
        check_cap(total, options, &root.table)?;
        queue.push_back((root.table.clone(), root_rows));
    }

    while let Some((table_id, new_rows)) = queue.pop_front() {
        if new_rows.is_empty() {
            continue;
        }
        let table = schema.table(&table_id).expect("table exists");
        let table_columns = clone_supplied_columns(table);

        for child_table in &schema.tables {
            for fk in &child_table.foreign_keys {
                if fk.ref_table != table_id {
                    continue;
                }
                let ref_positions: Vec<usize> = fk
                    .ref_columns
                    .iter()
                    .map(|c| {
                        table_columns
                            .iter()
                            .position(|tc| &tc.name == c)
                            .expect("ref column exists")
                    })
                    .collect();
                let key_tuples: Vec<Vec<PgValue>> = new_rows
                    .iter()
                    .filter(|r| ref_positions.iter().all(|&i| !r[i].is_null()))
                    .map(|r| ref_positions.iter().map(|&i| r[i].clone()).collect())
                    .collect();
                if key_tuples.is_empty() {
                    continue;
                }

                let child_columns = clone_supplied_columns(child_table);
                let matched = fetch_rows_matching(
                    source_txn,
                    child_table,
                    &child_columns,
                    &fk.columns,
                    &key_tuples,
                )
                .await?;
                if matched.is_empty() {
                    continue;
                }

                let table_map = included.entry(child_table.id.clone()).or_default();
                let mut fresh = Vec::new();
                for row in matched {
                    let key = row_identity_key(child_table, &child_columns, &row);
                    if !table_map.contains_key(&key) {
                        table_map.insert(key, row.clone());
                        fresh.push(row);
                        total += 1;
                    }
                }
                if !fresh.is_empty() {
                    check_cap(total, options, &child_table.id)?;
                    queue.push_back((child_table.id.clone(), fresh));
                }
            }
        }
    }

    // Phase 2: backward closure over FK-owned columns, to fixpoint. Never
    // touches `queue` / never re-triggers phase 1 — that's what keeps the
    // subset bounded.
    loop {
        let mut added_any = false;
        let snapshot: Vec<(TableId, Vec<Vec<PgValue>>)> = included
            .iter()
            .map(|(t, m)| (t.clone(), m.values().cloned().collect()))
            .collect();

        for (table_id, rows) in &snapshot {
            let table = schema.table(table_id).expect("table exists");
            let columns = clone_supplied_columns(table);

            for fk in &table.foreign_keys {
                let col_positions: Vec<usize> = fk
                    .columns
                    .iter()
                    .map(|c| {
                        columns
                            .iter()
                            .position(|tc| &tc.name == c)
                            .expect("fk column exists")
                    })
                    .collect();
                let needed_keys: Vec<Vec<PgValue>> = rows
                    .iter()
                    .filter(|r| col_positions.iter().all(|&i| !r[i].is_null()))
                    .map(|r| col_positions.iter().map(|&i| r[i].clone()).collect())
                    .collect();
                if needed_keys.is_empty() {
                    continue;
                }

                let parent_table = schema.table(&fk.ref_table).expect("table exists");
                let parent_columns = clone_supplied_columns(parent_table);
                let matched = fetch_rows_matching(
                    source_txn,
                    parent_table,
                    &parent_columns,
                    &fk.ref_columns,
                    &needed_keys,
                )
                .await?;

                let table_map = included.entry(fk.ref_table.clone()).or_default();
                for row in matched {
                    let key = row_identity_key(parent_table, &parent_columns, &row);
                    if !table_map.contains_key(&key) {
                        table_map.insert(key, row);
                        total += 1;
                        added_any = true;
                        check_cap(total, options, &fk.ref_table)?;
                    }
                }
            }
        }

        if !added_any {
            break;
        }
    }

    Ok(included
        .into_iter()
        .map(|(t, m)| (t, m.into_values().collect()))
        .collect())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Identity, Table, TypeKind, UniqueConstraint};

    fn table(schema: &str, name: &str) -> Table {
        Table {
            id: TableId {
                schema: schema.to_string(),
                name: name.to_string(),
            },
            columns: vec![Column {
                name: "id".to_string(),
                position: 1,
                type_name: "int4".to_string(),
                type_schema: "pg_catalog".to_string(),
                type_kind: TypeKind::Scalar,
                max_length: None,
                vector_dimensions: None,
                numeric_precision: None,
                numeric_scale: None,
                check_min: None,
                check_max: None,
                check_allowed_values: None,
                check_null_escape: false,
                check_like_prefix: None,
                nullable: false,
                identity: Identity::None,
                is_stored_generated: false,
                has_default: false,
                is_serial_default: true,
            }],
            primary_key: Some(vec!["id".to_string()]),
            foreign_keys: vec![],
            unique_constraints: vec![UniqueConstraint {
                name: format!("{name}_pkey"),
                is_primary: true,
                columns: vec!["id".to_string()],
            }],
            check_constraints: vec![],
        }
    }

    #[test]
    fn parses_bare_table_name() {
        let schema = Schema {
            tables: vec![table("public", "organizations")],
        };
        let root = parse_root(&schema, "organizations WHERE id = 42").unwrap();
        assert_eq!(root.table.qualified(), "public.organizations");
        assert_eq!(root.condition, "id = 42");
    }

    #[test]
    fn parses_qualified_table_name_and_is_case_insensitive_on_where() {
        let schema = Schema {
            tables: vec![table("public", "organizations")],
        };
        let root = parse_root(&schema, "public.organizations where id = 42").unwrap();
        assert_eq!(root.table.qualified(), "public.organizations");
        assert_eq!(root.condition, "id = 42");
    }

    #[test]
    fn rejects_missing_where() {
        let schema = Schema {
            tables: vec![table("public", "organizations")],
        };
        assert!(parse_root(&schema, "organizations id = 42").is_err());
    }

    #[test]
    fn rejects_unknown_table() {
        let schema = Schema {
            tables: vec![table("public", "organizations")],
        };
        assert!(parse_root(&schema, "nonexistent WHERE id = 1").is_err());
    }

    #[test]
    fn rejects_ambiguous_bare_table_name() {
        let schema = Schema {
            tables: vec![
                table("public", "organizations"),
                table("other", "organizations"),
            ],
        };
        assert!(parse_root(&schema, "organizations WHERE id = 1").is_err());
    }
}
