use std::path::Path;

use feint_core::{graph, introspect, snapshot::SnapshotFile};

use crate::ui;

pub async fn run(snapshot_path: &Path, target_url: &str) -> anyhow::Result<()> {
    let spinner = ui::spinner("Reading snapshot file...");
    let snapshot_file = SnapshotFile::read_from_file(snapshot_path)?;
    spinner.finish_and_clear();

    let mut target_client = feint_core::connect::connect(target_url).await?;

    let schema_names = snapshot_file.schema_names();
    let spinner = ui::spinner("Inspecting target schema...");
    let target_schema = introspect::introspect(&target_client, &schema_names).await?;
    spinner.finish_and_clear();

    let plan = graph::plan_insertion(&target_schema)?;

    let start = std::time::Instant::now();
    let target_txn = target_client.transaction().await?;

    let spinner = ui::spinner("Restoring...");
    let run_result =
        feint_core::snapshot::restore(&target_txn, &target_schema, &plan, &snapshot_file).await;
    spinner.finish_and_clear();

    let summary = match run_result {
        Ok(s) => s,
        Err(e) => {
            target_txn.rollback().await.ok();
            ui::error(format!("{e}"));
            ui::error("Rolled back — target database is unchanged.");
            return Err(e.into());
        }
    };

    target_txn.commit().await?;
    let elapsed = start.elapsed();

    println!();
    for (table, rows) in &summary.rows_by_table {
        ui::check(format!("{table}: {} rows", ui::format_count(*rows)));
    }
    println!();
    ui::check(format!(
        "{} rows restored in {:.1}s",
        ui::format_count(summary.total_rows),
        elapsed.as_secs_f64()
    ));
    ui::check("All constraints valid");
    ui::check("All foreign keys valid");

    Ok(())
}
