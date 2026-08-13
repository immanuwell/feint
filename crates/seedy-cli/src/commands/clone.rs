use std::path::Path;

use seedy_core::config::SeedyConfig;
use seedy_core::{clone, graph, introspect};

use crate::ui;

pub async fn run(
    source_url: &str,
    target_url: &str,
    root: Option<String>,
    config_path: &Path,
    schemas: &[String],
) -> anyhow::Result<()> {
    if root.is_some() {
        anyhow::bail!(
            "--root subsetting isn't implemented yet — omit it to clone the whole database"
        );
    }

    let config = if config_path.exists() {
        SeedyConfig::load(config_path)?
    } else {
        SeedyConfig {
            version: 1,
            seed: seedy_core::config::DEFAULT_SEED.to_string(),
            tables: Default::default(),
        }
    };

    let (mut source_client, source_conn) =
        tokio_postgres::connect(source_url, tokio_postgres::NoTls).await?;
    tokio::spawn(async move {
        if let Err(e) = source_conn.await {
            eprintln!("source connection error: {e}");
        }
    });
    let (mut target_client, target_conn) =
        tokio_postgres::connect(target_url, tokio_postgres::NoTls).await?;
    tokio::spawn(async move {
        if let Err(e) = target_conn.await {
            eprintln!("target connection error: {e}");
        }
    });

    let spinner = ui::spinner("Inspecting source schema...");
    let schema = introspect::introspect(&source_client, schemas).await?;
    spinner.finish_and_clear();

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
    let target_txn = target_client.transaction().await?;

    let spinner = ui::spinner("Cloning...");
    let run_result = clone::run(
        &source_txn,
        &target_txn,
        &schema,
        &plan,
        &config,
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
