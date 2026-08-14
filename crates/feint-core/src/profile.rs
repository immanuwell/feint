//! `feint profile`: extract a statistical shape from a real database
//! (row counts, per-column null fractions, and per-foreign-key
//! cardinality histograms), commit the result, and generate against it
//! with `up --profile`.
//!
//! Nothing sensitive ever leaves the database this way: every value in
//! the file is an aggregate count or a ratio, never a real row's data.
//! The cardinality query in particular only ever counts how many child
//! rows each parent row has, via a `LEFT JOIN` + `COUNT`, never reading a
//! column's actual value.
//!
//! This directly answers the most common complaint about synthetic test
//! data: a uniform `rows:` count per table produces a uniform number of
//! children per parent (a user with 1 order looks the same as a user with
//! 1000), which is not what production data looks like and is not enough
//! to reproduce production's query plans. A captured cardinality
//! histogram lets `up` reproduce the real shape (a long tail: most
//! parents have few children, a few have many) instead.

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};
use tokio_postgres::Transaction;

use crate::error::{FeintError, Result};
use crate::introspect::{Schema, Table};

const FORMAT_VERSION: u32 = 1;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProfileFile {
    format_version: u32,
    /// Keyed by schema-qualified table name.
    tables: BTreeMap<String, TableProfile>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct TableProfile {
    pub row_count: u64,
    /// Column name -> fraction of rows where it's NULL, `0.0..=1.0`.
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub null_fractions: BTreeMap<String, f64>,
    /// Foreign key constraint name -> the shape of how many rows of
    /// *this* table point at each row of the referenced table. Only
    /// captured for single-column foreign keys referencing a single
    /// unique/primary-key column — composite keys are skipped rather
    /// than approximated.
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub cardinality: BTreeMap<String, CardinalityProfile>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CardinalityProfile {
    /// `(children_count, number_of_parent_rows_with_that_count)`, sorted
    /// by `children_count`. Includes the zero-children bucket, so parents
    /// with no children at all are represented too, not silently dropped.
    pub histogram: Vec<(u32, u64)>,
}

impl ProfileFile {
    pub fn table(&self, qualified_name: &str) -> Option<&TableProfile> {
        self.tables.get(qualified_name)
    }

    pub fn write_to_file(&self, path: &Path) -> Result<()> {
        let text = serde_yaml_ng::to_string(self)?;
        std::fs::write(path, text)?;
        Ok(())
    }

    pub fn read_from_file(path: &Path) -> Result<Self> {
        let text = std::fs::read_to_string(path)?;
        let profile: ProfileFile = serde_yaml_ng::from_str(&text)?;
        if profile.format_version != FORMAT_VERSION {
            return Err(FeintError::Config(format!(
                "profile file {} is format version {}, but this build of feint only understands \
                 version {FORMAT_VERSION}. Recapture it with a matching feint version.",
                path.display(),
                profile.format_version
            )));
        }
        Ok(profile)
    }
}

pub async fn capture(txn: &Transaction<'_>, schema: &Schema) -> Result<ProfileFile> {
    let mut tables = BTreeMap::new();
    for table in &schema.tables {
        let row_count = row_count(txn, table).await?;
        let null_fractions = capture_null_fractions(txn, table, row_count).await?;
        let cardinality = capture_cardinality(txn, schema, table).await?;
        tables.insert(
            table.id.qualified(),
            TableProfile {
                row_count,
                null_fractions,
                cardinality,
            },
        );
    }
    Ok(ProfileFile {
        format_version: FORMAT_VERSION,
        tables,
    })
}

async fn row_count(txn: &Transaction<'_>, table: &Table) -> Result<u64> {
    let row = txn
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{}\".\"{}\"",
                table.id.schema, table.id.name
            ),
            &[],
        )
        .await?;
    let n: i64 = row.get(0);
    Ok(n.max(0) as u64)
}

async fn capture_null_fractions(
    txn: &Transaction<'_>,
    table: &Table,
    row_count: u64,
) -> Result<BTreeMap<String, f64>> {
    let mut fractions = BTreeMap::new();
    if row_count == 0 {
        return Ok(fractions);
    }
    for column in &table.columns {
        if !column.nullable || column.is_stored_generated {
            continue;
        }
        let sql = format!(
            "SELECT count(*) FILTER (WHERE \"{}\" IS NULL) FROM \"{}\".\"{}\"",
            column.name, table.id.schema, table.id.name
        );
        let row = txn.query_one(&sql, &[]).await?;
        let null_count: i64 = row.get(0);
        let fraction = null_count as f64 / row_count as f64;
        if fraction > 0.0 {
            fractions.insert(column.name.clone(), fraction);
        }
    }
    Ok(fractions)
}

async fn capture_cardinality(
    txn: &Transaction<'_>,
    schema: &Schema,
    table: &Table,
) -> Result<BTreeMap<String, CardinalityProfile>> {
    let mut cardinality = BTreeMap::new();
    for fk in &table.foreign_keys {
        if fk.columns.len() != 1 || fk.ref_columns.len() != 1 {
            continue; // composite keys: skipped, not approximated
        }
        let Some(ref_table) = schema.table(&fk.ref_table) else {
            continue;
        };
        let fk_col = &fk.columns[0];
        let ref_col = &fk.ref_columns[0];

        let sql = format!(
            "SELECT child_count, count(*) AS num_parents FROM ( \
                 SELECT p.\"{ref_col}\" AS parent_key, count(c.\"{fk_col}\") AS child_count \
                 FROM \"{}\".\"{}\" p \
                 LEFT JOIN \"{}\".\"{}\" c ON c.\"{fk_col}\" = p.\"{ref_col}\" \
                 GROUP BY p.\"{ref_col}\" \
             ) t GROUP BY child_count ORDER BY child_count",
            ref_table.id.schema, ref_table.id.name, table.id.schema, table.id.name
        );
        let rows = txn.query(&sql, &[]).await?;
        if rows.is_empty() {
            continue; // no parent rows at all: nothing to profile
        }
        let histogram: Vec<(u32, u64)> = rows
            .iter()
            .map(|r| {
                let count: i64 = r.get(0);
                let parents: i64 = r.get(1);
                (count.max(0) as u32, parents.max(0) as u64)
            })
            .collect();
        cardinality.insert(fk.name.clone(), CardinalityProfile { histogram });
    }
    Ok(cardinality)
}
