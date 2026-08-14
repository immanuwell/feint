use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::subset::{compute_subset, parse_root, SubsetOptions};
use feint_core::{introspect, snapshot};

use crate::ui;

pub async fn run(
    source_url: &str,
    output: &Path,
    root: Option<String>,
    config_path: &Path,
    schemas: &[String],
) -> anyhow::Result<()> {
    let config = if config_path.exists() {
        FeintConfig::load(config_path)?
    } else {
        FeintConfig {
            version: 1,
            seed: feint_core::config::DEFAULT_SEED.to_string(),
            tables: Default::default(),
        }
    };

    let mut source_client = feint_core::connect::connect(source_url).await?;

    let spinner = ui::spinner("Inspecting source schema...");
    let schema = introspect::introspect(&source_client, schemas).await?;
    spinner.finish_and_clear();

    let start = std::time::Instant::now();
    let source_txn = source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await?;

    let subset = match &root {
        Some(root_spec) => {
            let parsed = match parse_root(&schema, root_spec) {
                Ok(r) => r,
                Err(e) => {
                    source_txn.rollback().await.ok();
                    ui::error(format!("{e}"));
                    return Err(e.into());
                }
            };
            let spinner = ui::spinner(format!("Subsetting from {root_spec}..."));
            let result =
                compute_subset(&source_txn, &schema, &parsed, &SubsetOptions::default()).await;
            spinner.finish_and_clear();
            match result {
                Ok(rows) => Some(rows),
                Err(e) => {
                    source_txn.rollback().await.ok();
                    ui::error(format!("{e}"));
                    return Err(e.into());
                }
            }
        }
        None => None,
    };

    let spinner = ui::spinner("Capturing...");
    let capture_result = snapshot::capture(&source_txn, &schema, &config, subset.as_ref()).await;
    spinner.finish_and_clear();
    source_txn.rollback().await.ok(); // read-only txn; nothing to commit

    let snapshot_file = match capture_result {
        Ok(s) => s,
        Err(e) => {
            ui::error(format!("{e}"));
            return Err(e.into());
        }
    };

    snapshot_file.write_to_file(output)?;
    let elapsed = start.elapsed();
    let file_size = std::fs::metadata(output).map(|m| m.len()).unwrap_or(0);

    println!();
    ui::check(format!(
        "{} rows across {} tables captured in {:.1}s",
        ui::format_count(snapshot_file.total_rows()),
        snapshot_file.table_count(),
        elapsed.as_secs_f64()
    ));
    ui::check(format!(
        "Wrote {} ({})",
        output.display(),
        ui::format_bytes(file_size)
    ));
    ui::check("No target database was touched — restore it later with `feint restore`");

    Ok(())
}
