use std::collections::BTreeMap;
use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::graph::{plan_insertion, InsertGroup};
use feint_core::introspect::{self, Column, Table, TypeKind};

use crate::ui;

/// How many non-null rows of a JSONB column to sample when looking for
/// sensitive-looking key names. Only key names are ever read into memory
/// here (see [`sample_json_key_paths`]) — the actual values are dropped
/// immediately after each row's keys are extracted, and nothing sampled is
/// ever printed or written anywhere.
const JSON_SAMPLE_ROWS: i64 = 200;
/// How many levels of nested object to recurse into when looking for
/// sensitive key names inside a sampled JSON value. 0 = top-level keys only.
const JSON_SAMPLE_MAX_DEPTH: usize = 2;

pub async fn run(database_url: &str, config_path: &Path, schemas: &[String]) -> anyhow::Result<()> {
    let spinner = ui::spinner("Analyzing database...");
    let client = feint_core::connect::connect(database_url).await?;

    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    let fk_count: usize = schema.tables.iter().map(|t| t.foreign_keys.len()).sum();
    let all_columns: Vec<_> = schema.tables.iter().flat_map(|t| &t.columns).collect();
    let enum_count = all_columns
        .iter()
        .filter(|c| matches!(c.type_kind, TypeKind::Enum(_)))
        .count();
    let jsonb_count = all_columns
        .iter()
        .filter(|c| c.type_name == "json" || c.type_name == "jsonb")
        .count();
    let check_count: usize = schema
        .tables
        .iter()
        .map(|t| t.check_constraints.len())
        .sum();

    println!();
    ui::heading(format!("{} tables", schema.tables.len()));
    println!("{fk_count} foreign keys");
    println!("{enum_count} enums");
    println!("{jsonb_count} JSONB columns");

    match plan_insertion(&schema) {
        Ok(plan) => {
            let cyclic = plan
                .groups
                .iter()
                .filter(|g| !matches!(g, InsertGroup::Simple(_)))
                .count();
            if cyclic > 0 {
                println!("{cyclic} cyclic dependencies (resolvable)");
            }
        }
        Err(e) => ui::warn(format!("{e}")),
    }

    if check_count > 0 {
        ui::warn(format!(
            "{check_count} CHECK constraints detected (not validated by generators — see comments in {})",
            config_path.display()
        ));
    }

    let mut sensitive: Vec<(String, &'static str)> = Vec::new();
    let mut json_sensitive: Vec<(String, &'static str)> = Vec::new();
    for table in &schema.tables {
        for column in &table.columns {
            if let Some(kind) = feint_core::generate::classify_sensitive(&column.name) {
                sensitive.push((format!("{}.{}", table.id.name, column.name), kind));
            }
            if column.type_name == "json" || column.type_name == "jsonb" {
                match sample_json_key_paths(&client, table, column).await {
                    Ok(paths) => {
                        for (path, kind) in paths {
                            json_sensitive
                                .push((format!("{}.{}.{path}", table.id.name, column.name), kind));
                        }
                    }
                    Err(e) => ui::warn(format!(
                        "could not sample {}.{} for JSON key names: {e}",
                        table.id.name, column.name
                    )),
                }
            }
        }
    }
    if !sensitive.is_empty() {
        println!();
        ui::heading("Sensitive fields detected:");
        let width = sensitive.iter().map(|(n, _)| n.len()).max().unwrap_or(0);
        for (name, kind) in &sensitive {
            println!("  {name:<width$}  {kind}");
        }
    }
    if !json_sensitive.is_empty() {
        println!();
        ui::heading("Sensitive-looking keys inside JSON/JSONB columns:");
        let width = json_sensitive
            .iter()
            .map(|(n, _)| n.len())
            .max()
            .unwrap_or(0);
        for (name, kind) in &json_sensitive {
            println!("  {name:<width$}  {kind}");
        }
        println!(
            "  (found by sampling up to {JSON_SAMPLE_ROWS} real rows' key names only, never \
             values — see \"JSON path masking\" in DOCS.md for how to mask these paths)"
        );
    }

    let config = FeintConfig::from_schema(&schema);
    config.save_annotated(&schema, config_path)?;
    println!();
    ui::check(format!("Generated {}", config_path.display()));

    Ok(())
}

/// Sample up to [`JSON_SAMPLE_ROWS`] non-null real values of a JSON/JSONB
/// column and scan each one's own key names for feint's sensitive-name
/// heuristic, up to [`JSON_SAMPLE_MAX_DEPTH`] levels of nesting. Each
/// sampled `serde_json::Value` is only ever used to walk its keys before
/// being dropped — no value is retained, printed, or written anywhere;
/// this only ever reports where a suspicious key *name* was seen.
async fn sample_json_key_paths(
    client: &tokio_postgres::Client,
    table: &Table,
    column: &Column,
) -> anyhow::Result<Vec<(String, &'static str)>> {
    let sql = format!(
        "SELECT \"{}\" FROM \"{}\".\"{}\" WHERE \"{}\" IS NOT NULL LIMIT {JSON_SAMPLE_ROWS}",
        column.name, table.id.schema, table.id.name, column.name
    );
    let rows = client.query(&sql, &[]).await?;
    let mut seen: BTreeMap<String, &'static str> = BTreeMap::new();
    for row in rows {
        let value: serde_json::Value = row.get(0);
        for (path, kind) in
            feint_core::generate::detect_sensitive_json_keys(&value, JSON_SAMPLE_MAX_DEPTH)
        {
            seen.entry(path).or_insert(kind);
        }
    }
    Ok(seen.into_iter().collect())
}
