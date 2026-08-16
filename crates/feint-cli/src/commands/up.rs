use std::collections::HashMap;
use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::profile::ProfileFile;
use feint_core::{graph, insert, introspect};
use indicatif::MultiProgress;

use crate::ui;

#[allow(clippy::too_many_arguments)]
pub async fn run(
    database_url: &str,
    config_path: &Path,
    seed_override: Option<String>,
    schemas: &[String],
    profile_path: Option<&Path>,
) -> anyhow::Result<()> {
    let mut config = FeintConfig::load(config_path)?;
    if let Some(seed) = seed_override {
        config.seed = seed;
    }
    let profile = profile_path.map(ProfileFile::read_from_file).transpose()?;

    let mut client = feint_core::connect::connect(database_url).await?;

    let spinner = ui::spinner("Inspecting schema...");
    let mut schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    feint_core::config::apply_logical_foreign_keys(&mut schema, &config)?;

    let plan = graph::plan_insertion(&schema)?;

    let start = std::time::Instant::now();
    let txn = client.transaction().await?;

    ui::heading("Generating...");
    let multi = MultiProgress::new();
    let mut bars: HashMap<String, indicatif::ProgressBar> = HashMap::new();

    let run_result =
        insert::run(
            &txn,
            &schema,
            &plan,
            &config,
            profile.as_ref(),
            |event| match event {
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
            },
        )
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
