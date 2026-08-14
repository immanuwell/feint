//! Post-mask verification: after `mask` finishes, re-read the database
//! and check that each masked column's values actually have the shape
//! masking should have produced. This is defense in depth against
//! pipeline bugs, not a content-based PII detector — it can't tell you
//! whether a `fake` value merely looks like a real name, but it can tell
//! you whether masking silently skipped rows, produced a malformed hash,
//! left a non-null value in a column that should be redacted, or
//! collapsed every row's `fake` value to the same one (a strong sign the
//! per-row identity keying broke).

use tokio_postgres::Client;

use crate::error::Result;
use crate::introspect::Schema;
use crate::mask::{redact_literal, MaskStrategy};
use crate::sanitize::SanitizePlan;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct VerificationFinding {
    pub table: String,
    pub column: String,
    pub strategy: MaskStrategy,
    pub issue: String,
}

/// Check every masked column in `plan` against the database's current
/// state. Returns one finding per column that looks wrong; an empty
/// vector means everything checked out.
///
/// A column masked via `json_paths` (see [`crate::mask::mask_json_column_value`])
/// is not checked here: its plan-level `strategy` is `none` (masking
/// happens per path, not for the whole column), so it's skipped like any
/// other unmasked column. Verifying arbitrary JSON paths would need to
/// walk each configured path's shape per row, which this pass doesn't do
/// yet.
pub async fn verify_masking(
    client: &Client,
    schema: &Schema,
    plan: &SanitizePlan,
) -> Result<Vec<VerificationFinding>> {
    let mut findings = Vec::new();

    for table_plan in &plan.tables {
        let table = schema
            .table(&table_plan.table)
            .expect("table in sanitize plan must exist in schema");
        let qualified = table_plan.table.qualified();

        for col_plan in &table_plan.columns {
            let column = table
                .column(&col_plan.name)
                .expect("column in sanitize plan must exist on table");

            let finding = match col_plan.strategy {
                MaskStrategy::None => None,
                MaskStrategy::Redact => check_redact(client, &qualified, column).await?,
                MaskStrategy::Hash => check_hash(client, &qualified, &col_plan.name).await?,
                MaskStrategy::Fake => check_fake(client, &qualified, &col_plan.name).await?,
            };

            if let Some(issue) = finding {
                findings.push(VerificationFinding {
                    table: qualified.clone(),
                    column: col_plan.name.clone(),
                    strategy: col_plan.strategy,
                    issue,
                });
            }
        }
    }

    Ok(findings)
}

async fn check_redact(
    client: &Client,
    qualified_table: &str,
    column: &crate::introspect::Column,
) -> Result<Option<String>> {
    let count: i64 = if column.nullable {
        let sql = format!(
            "SELECT count(*) FROM {qualified_table} WHERE \"{}\" IS NOT NULL",
            column.name
        );
        client.query_one(&sql, &[]).await?.get(0)
    } else {
        let literal = redact_literal(column);
        let cast = crate::insert::sql_cast_type(column);
        let sql = format!(
            "SELECT count(*) FROM {qualified_table} WHERE \"{}\" IS DISTINCT FROM $1::{cast}",
            column.name
        );
        client
            .query_one(
                &sql,
                &[&literal as &(dyn tokio_postgres::types::ToSql + Sync)],
            )
            .await?
            .get(0)
    };

    if count > 0 {
        Ok(Some(format!(
            "{count} row(s) do not hold the expected redacted placeholder"
        )))
    } else {
        Ok(None)
    }
}

async fn check_hash(
    client: &Client,
    qualified_table: &str,
    column_name: &str,
) -> Result<Option<String>> {
    let sql = format!(
        "SELECT count(*) FROM {qualified_table} WHERE \"{column_name}\" IS NOT NULL AND \"{column_name}\" !~ '^masked_[0-9a-f]{{24}}$'"
    );
    let count: i64 = client.query_one(&sql, &[]).await?.get(0);
    if count > 0 {
        Ok(Some(format!(
            "{count} row(s) do not match the expected hash format (masked_<hex>)"
        )))
    } else {
        Ok(None)
    }
}

async fn check_fake(
    client: &Client,
    qualified_table: &str,
    column_name: &str,
) -> Result<Option<String>> {
    let sql = format!(
        "SELECT count(*), count(DISTINCT \"{column_name}\") FROM {qualified_table} WHERE \"{column_name}\" IS NOT NULL"
    );
    let row = client.query_one(&sql, &[]).await?;
    let total: i64 = row.get(0);
    let distinct: i64 = row.get(1);
    if total > 1 && distinct == 1 {
        Ok(Some(format!(
            "all {total} non-null row(s) share the exact same fake value — masking may not be varying per row"
        )))
    } else {
        Ok(None)
    }
}
