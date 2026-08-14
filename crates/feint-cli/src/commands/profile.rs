use std::path::Path;

use feint_core::{introspect, profile};

use crate::ui;

pub async fn run(database_url: &str, output: &Path, schemas: &[String]) -> anyhow::Result<()> {
    let mut client = feint_core::connect::connect(database_url).await?;

    let spinner = ui::spinner("Inspecting schema...");
    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    let txn = client.build_transaction().read_only(true).start().await?;

    let spinner = ui::spinner("Profiling (row counts, null rates, foreign-key cardinality)...");
    let result = profile::capture(&txn, &schema).await;
    spinner.finish_and_clear();
    txn.rollback().await.ok(); // read-only txn; nothing to commit

    let profile_file = match result {
        Ok(p) => p,
        Err(e) => {
            ui::error(format!("{e}"));
            return Err(e.into());
        }
    };

    profile_file.write_to_file(output)?;

    println!();
    ui::check(format!("Wrote {}", output.display()));
    ui::check("Only aggregate counts and ratios were read — no row values left the database");

    Ok(())
}
