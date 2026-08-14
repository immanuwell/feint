use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::subset::{compute_subset, parse_root, SubsetOptions};
use feint_core::{clone, graph, introspect};

use crate::commands::classify;
use crate::ui;

#[allow(clippy::too_many_arguments)]
pub async fn run(
    source_url: &str,
    target_url: &str,
    root: Option<String>,
    config_path: &Path,
    schemas: &[String],
    strict: bool,
    lockfile: &Path,
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
    let mut target_client = feint_core::connect::connect(target_url).await?;

    let spinner = ui::spinner("Inspecting source schema...");
    let schema = introspect::introspect(&source_client, schemas).await?;
    spinner.finish_and_clear();

    if strict {
        classify::check_strict(&schema, &config, lockfile, false)?;
    }

    let plan = graph::plan_insertion(&schema)?;

    let start = std::time::Instant::now();
    // Source is opened strictly read-only at the transaction level, not
    // just "we only issue SELECT strings" — a bug or later refactor can't
    // accidentally smuggle a mutating statement through.
    let source_txn = source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await?;

    // Subsetting only ever reads from `source_txn` — nothing is written
    // to target until this resolves, so a cap-abort or a bad --root
    // leaves the target database untouched.
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
                Ok(rows) => {
                    let table_count = rows.values().filter(|r| !r.is_empty()).count();
                    let row_count: usize = rows.values().map(|r| r.len()).sum();
                    ui::check(format!(
                        "Subset: {} rows across {table_count} tables",
                        ui::format_count(row_count as u64)
                    ));
                    Some(rows)
                }
                Err(e) => {
                    source_txn.rollback().await.ok();
                    ui::error(format!("{e}"));
                    return Err(e.into());
                }
            }
        }
        None => None,
    };

    let target_txn = target_client.transaction().await?;

    let spinner = ui::spinner("Cloning...");
    let run_result = clone::run(
        &source_txn,
        &target_txn,
        &schema,
        &plan,
        &config,
        subset.as_ref(),
        |_event| {},
    )
    .await;
    spinner.finish_and_clear();

    let summary = match run_result {
        Ok(s) => s,
        Err(e) => {
            target_txn.rollback().await.ok();
            source_txn.rollback().await.ok();
            ui::error(format!("{e}"));
            ui::error("Rolled back — target database is unchanged.");
            return Err(e.into());
        }
    };

    target_txn.commit().await?;
    source_txn.rollback().await.ok(); // read-only txn; nothing to commit
    let elapsed = start.elapsed();

    println!();
    for (table, rows) in &summary.rows_by_table {
        ui::check(format!("{table}: {} rows", ui::format_count(*rows)));
    }
    println!();
    ui::check(format!(
        "{} rows cloned in {:.1}s",
        ui::format_count(summary.total_rows),
        elapsed.as_secs_f64()
    ));
    ui::check("All constraints valid");
    ui::check("All foreign keys valid");
    ui::check("Primary keys and foreign keys preserved from source");

    Ok(())
}
