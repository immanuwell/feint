use std::path::Path;

use seedy_core::config::SeedyConfig;
use seedy_core::graph::{plan_insertion, InsertGroup};
use seedy_core::introspect::{self, TypeKind};

use crate::ui;

pub async fn run(database_url: &str, config_path: &Path) -> anyhow::Result<()> {
    let spinner = ui::spinner("Analyzing database...");
    let (client, connection) = tokio_postgres::connect(database_url, tokio_postgres::NoTls).await?;
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {e}");
        }
    });

    let schema = introspect::introspect(&client).await?;
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
            "{check_count} CHECK constraints detected (not validated by generators — review seedy.yaml)"
        ));
    }

    let config = SeedyConfig::from_schema(&schema);
    config.save(config_path)?;
    println!();
    ui::check(format!("Generated {}", config_path.display()));

    Ok(())
}
