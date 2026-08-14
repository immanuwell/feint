use std::path::Path;

use feint_core::classify::{
    self, ClassificationDiff, ClassificationLock, ClassificationReport, ColumnClassification,
};
use feint_core::config::FeintConfig;
use feint_core::introspect;
use feint_core::mask::MaskStrategy;
use serde::Serialize;
use std::collections::BTreeMap;

use crate::ui;

#[derive(Serialize)]
struct ClassifyJson {
    lockfile: String,
    columns: BTreeMap<String, ColumnClassification>,
    diff: Option<ClassificationDiff>,
    written: bool,
}

#[allow(clippy::too_many_arguments)]
pub async fn run(
    database_url: &str,
    config_path: &Path,
    schemas: &[String],
    lockfile: &Path,
    write: bool,
    check: bool,
    json: bool,
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

    let client = feint_core::connect::connect(database_url).await?;
    let spinner = ui::spinner("Inspecting schema...");
    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    let report = classify::classify_schema(&schema, &config);
    if !json {
        print_report(&report);
    }

    let existing_lock = ClassificationLock::load(lockfile)?;

    if write {
        let lock = ClassificationLock::from_report(&report);
        lock.save(lockfile)?;
        if json {
            print_json(&report, None, lockfile, true)?;
        } else {
            println!();
            ui::check(format!(
                "Wrote {} — {} column(s) approved as of this classification.",
                lockfile.display(),
                report.columns.len()
            ));
        }
        return Ok(());
    }

    let Some(lock) = existing_lock else {
        if check {
            if json {
                print_json(&report, None, lockfile, false)?;
            } else {
                println!();
                ui::error(format!(
                    "no lockfile at {} — nothing has been approved yet. Run `feint classify {} \
                     --write` once to establish a baseline, commit the lockfile, then `--check` \
                     will fail closed on future drift.",
                    lockfile.display(),
                    database_url
                ));
            }
            anyhow::bail!("classification lockfile missing");
        }
        if json {
            print_json(&report, None, lockfile, false)?;
        } else {
            println!();
            ui::warn(format!(
                "no lockfile at {} yet — nothing to compare against. Run with --write to create one.",
                lockfile.display()
            ));
        }
        return Ok(());
    };

    let diff = classify::diff_against_lock(&report, &lock);
    if json {
        print_json(&report, Some(&diff), lockfile, false)?;
    } else {
        print_diff(&diff, lockfile);
    }

    if diff.is_dirty() && check {
        anyhow::bail!(
            "classification has drifted from {} — see above. Review the columns, then re-run with \
             --write once they've been consciously approved.",
            lockfile.display()
        );
    }

    Ok(())
}

fn print_json(
    report: &ClassificationReport,
    diff: Option<&ClassificationDiff>,
    lockfile: &Path,
    written: bool,
) -> anyhow::Result<()> {
    println!(
        "{}",
        serde_json::to_string(&ClassifyJson {
            lockfile: lockfile.display().to_string(),
            columns: report.columns.clone(),
            diff: diff.cloned(),
            written,
        })?
    );
    Ok(())
}

fn print_report(report: &ClassificationReport) {
    let sensitive_count = report.columns.values().filter(|c| c.sensitive).count();
    println!();
    ui::heading(format!(
        "{} column(s) tracked, {sensitive_count} look sensitive by name:",
        report.columns.len()
    ));
    for (column, entry) in &report.columns {
        let flag = if entry.sensitive { "sensitive" } else { "" };
        println!(
            "  {:<48} {:<10} {}",
            column,
            flag,
            strategy_label(entry.strategy)
        );
    }
}

fn print_diff(diff: &ClassificationDiff, lockfile: &Path) {
    println!();
    if !diff.is_dirty() {
        ui::check(format!(
            "Matches {} — nothing has drifted.",
            lockfile.display()
        ));
        return;
    }

    ui::heading(format!("Drifted from {}:", lockfile.display()));
    for c in &diff.new_columns {
        let tag = if c.sensitive { "new, sensitive" } else { "new" };
        println!(
            "  + {:<48} {tag}, resolves to {}",
            c.column,
            strategy_label(c.strategy)
        );
    }
    for c in &diff.changed_columns {
        println!(
            "  ~ {:<48} {} -> {}",
            c.column,
            strategy_label(c.old.strategy),
            strategy_label(c.new.strategy)
        );
    }
    for column in &diff.removed_columns {
        println!("  - {column:<48} removed (column no longer exists)");
    }

    println!();
    let sensitive_new = diff.new_sensitive_count();
    if sensitive_new > 0 {
        ui::warn(format!(
            "{} new column(s) since the last approved classification, {sensitive_new} look sensitive.",
            diff.new_columns.len()
        ));
    } else if !diff.new_columns.is_empty() {
        ui::warn(format!(
            "{} new column(s) since the last approved classification.",
            diff.new_columns.len()
        ));
    }
}

/// Fail-closed check for `mask --strict` / `clone --strict`: requires an
/// approved lockfile to already exist and the live schema to match it
/// exactly. Called before any table is read or written, so a drifted
/// schema aborts the whole run rather than silently masking (or not
/// masking) a column nobody has reviewed yet.
///
/// `json` suppresses this function's own stdout output (the drift table
/// and the success line) — set it when the caller has its own `--json`
/// contract to keep stdout limited to that caller's single JSON payload.
/// On drift, the failure is still reported through the returned `Err`,
/// json or not.
pub fn check_strict(
    schema: &introspect::Schema,
    config: &FeintConfig,
    lockfile: &Path,
    json: bool,
) -> anyhow::Result<()> {
    let report = classify::classify_schema(schema, config);
    let Some(lock) = ClassificationLock::load(lockfile)? else {
        anyhow::bail!(
            "--strict requires an approved classification lockfile at {} — run `feint classify \
             <database_url> --write` once, review the report, and commit the file. After that, \
             --strict fails closed on any future drift.",
            lockfile.display()
        );
    };

    let diff = classify::diff_against_lock(&report, &lock);
    if diff.is_dirty() {
        if !json {
            print_diff(&diff, lockfile);
        }
        let drifted =
            diff.new_columns.len() + diff.removed_columns.len() + diff.changed_columns.len();
        anyhow::bail!(
            "--strict: {drifted} column(s) have drifted from the approved classification in {} — \
             refusing to run. Review the columns above, then `feint classify <database_url> \
             --write` once they've been consciously approved.",
            lockfile.display()
        );
    }

    if !json {
        ui::check(format!(
            "--strict: classification matches {} — nothing has drifted.",
            lockfile.display()
        ));
    }
    Ok(())
}

fn strategy_label(strategy: MaskStrategy) -> &'static str {
    match strategy {
        MaskStrategy::Fake => "fake",
        MaskStrategy::Hash => "hash",
        MaskStrategy::Redact => "redact",
        MaskStrategy::None => "none",
    }
}
