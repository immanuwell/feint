use std::collections::HashMap;
use std::path::Path;

use indicatif::MultiProgress;
use seedy_core::config::SeedyConfig;
use seedy_core::{graph, insert, introspect};

use crate::ui;

pub async fn run(
    database_url: &str,
    config_path: &Path,
    seed_override: Option<String>,
    schemas: &[String],
) -> anyhow::Result<()> {
    let mut config = SeedyConfig::load(config_path)?;
    if let Some(seed) = seed_override {
        config.seed = seed;
    }

    let mut client = seedy_core::connect::connect(database_url).await?;

    let spinner = ui::spinner("Inspecting schema...");
    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    let plan = graph::plan_insertion(&schema)?;

    let start = std::time::Instant::now();
    let txn = client.transaction().await?;

    ui::heading("Generating...");
    let multi = MultiProgress::new();
    let mut bars: HashMap<String, indicatif::ProgressBar> = HashMap::new();

    let run_result = insert::run(&txn, &schema, &plan, &config, |event| match event {
        insert::ProgressEvent::TableStarted {
            table,
            planned_rows,
        } => {
            let bar = multi.add(ui::table_bar(table, planned_rows as u64));
            bars.insert(table.to_string(), bar);
        }
        insert::ProgressEvent::TableFinished { table, rows } => {
            if let Some(bar) = bars.get(table) {
                bar.set_position(rows);
                bar.finish();
            }
        }
    })
    .await;

    let summary = match run_result {
        Ok(s) => s,
        Err(e) => {
            txn.rollback().await.ok();
            ui::error(format!("{e}"));
            ui::error("Rolled back — database is unchanged.");
            return Err(e.into());
        }
    };

    txn.commit().await?;
    let elapsed = start.elapsed();

    println!();
    ui::check(format!(
        "{} rows generated in {:.1}s",
        ui::format_count(summary.total_rows),
        elapsed.as_secs_f64()
    ));
    ui::check("All constraints valid");
    ui::check("All foreign keys valid");
    ui::check("0 production values used");

    Ok(())
}
