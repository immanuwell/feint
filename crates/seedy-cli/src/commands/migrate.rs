use std::path::Path;

use seedy_core::migrate::{snaplet, ConversionConfidence, MigrationReport};

use crate::ui;

pub async fn run_snaplet(
    config_ts_path: &Path,
    seed_ts_path: Option<&Path>,
    output: &Path,
) -> anyhow::Result<()> {
    let config_ts = std::fs::read_to_string(config_ts_path)?;
    let seed_ts = seed_ts_path.map(std::fs::read_to_string).transpose()?;

    let migration = snaplet::migrate_snaplet(&config_ts, seed_ts.as_deref());
    migration.config.save(output)?;

    println!();
    ui::check(format!("Wrote {}", output.display()));
    print_report(&migration.report, migration.config.tables.len());
    Ok(())
}

pub async fn run_neosync(job_json_path: &Path, output: &Path) -> anyhow::Result<()> {
    let job_json = std::fs::read_to_string(job_json_path)?;
    let migration = seedy_core::migrate::neosync::migrate_neosync(&job_json)?;
    migration.config.save(output)?;

    println!();
    ui::check(format!("Wrote {}", output.display()));
    print_report(&migration.report, migration.config.tables.len());
    Ok(())
}

fn print_report(report: &MigrationReport, table_count: usize) {
    println!();
    ui::heading(format!("{table_count} tables converted"));

    if !report.converted.is_empty() {
        let exact = report
            .converted
            .iter()
            .filter(|c| c.confidence == ConversionConfidence::Exact)
            .count();
        let approx = report.converted.len() - exact;
        println!();
        ui::heading(format!(
            "{} columns converted ({exact} exact, {approx} approximate):",
            report.converted.len()
        ));
        for c in &report.converted {
            match &c.note {
                Some(note) => println!("  {}.{} — {note}", c.table, c.column),
                None => println!("  {}.{}", c.table, c.column),
            }
        }
    }

    if !report.skipped.is_empty() {
        println!();
        ui::heading(format!(
            "{} columns need manual review:",
            report.skipped.len()
        ));
        for s in &report.skipped {
            println!("  {}.{} — {}", s.table, s.column, s.reason);
        }
    }

    if !report.general_notes.is_empty() {
        println!();
        ui::heading("Notes:");
        for note in &report.general_notes {
            ui::warn(note);
        }
    }
}
