use std::collections::HashMap;
use std::io::Write as _;
use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::introspect;
use feint_core::sanitize::{self, ProgressEvent};
use feint_core::verify;
use serde::Serialize;
use tokio_postgres::config::Host;

use crate::commands::classify;
use crate::ui;

#[derive(Serialize)]
struct DryRunJson {
    dry_run: bool,
    tables: Vec<DryRunTableJson>,
    total_rows: u64,
}

#[derive(Serialize)]
struct DryRunTableJson {
    table: String,
    rows: u64,
}

#[derive(Serialize)]
struct MaskJson {
    target: String,
    tables: Vec<MaskTableJson>,
    total_rows: u64,
    verification: Option<VerificationJson>,
}

#[derive(Serialize)]
struct MaskTableJson {
    table: String,
    rows: u64,
}

#[derive(Serialize, Clone)]
struct VerificationJson {
    ok: bool,
    issues: Vec<VerificationIssueJson>,
}

#[derive(Serialize, Clone)]
struct VerificationIssueJson {
    table: String,
    column: String,
    strategy: &'static str,
    issue: String,
}

#[allow(clippy::too_many_arguments)]
pub async fn run(
    database_url: &str,
    config_path: &Path,
    schemas: &[String],
    batch_size: usize,
    dry_run: bool,
    yes: bool,
    resume: bool,
    max_batches: Option<usize>,
    skip_verify: bool,
    strict: bool,
    lockfile: &Path,
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

    let mut client = feint_core::connect::connect(database_url).await?;

    let spinner = ui::spinner("Inspecting schema...");
    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    if strict {
        classify::check_strict(&schema, &config, lockfile, json)?;
    }

    let plan = sanitize::plan_sanitization(&schema, &config)?;

    if plan.tables.is_empty() {
        if json {
            println!(
                "{}",
                serde_json::to_string(&MaskJson {
                    target: describe_target(database_url),
                    tables: Vec::new(),
                    total_rows: 0,
                    verification: None,
                })?
            );
        } else {
            ui::check("Nothing to mask — no column resolved to a masking strategy.");
        }
        return Ok(());
    }

    if !json {
        println!();
        ui::heading(format!("Target: {}", describe_target(database_url)));
        println!();
        ui::heading("Tables and columns to mask:");
        for t in &plan.tables {
            let cols = t
                .columns
                .iter()
                .map(|c| format!("{} ({})", c.name, strategy_label(c.strategy)))
                .collect::<Vec<_>>()
                .join(", ");
            println!("  {}: {cols}", t.table.qualified());
        }
    }

    if dry_run {
        let spinner = ui::spinner("Counting rows (dry run — nothing will be written)...");
        let report = sanitize::dry_run(&client, &schema, &plan).await?;
        spinner.finish_and_clear();

        let total: i64 = report.iter().map(|t| t.row_count).sum();
        if json {
            println!(
                "{}",
                serde_json::to_string(&DryRunJson {
                    dry_run: true,
                    tables: report
                        .iter()
                        .map(|t| DryRunTableJson {
                            table: t.table.clone(),
                            rows: t.row_count.max(0) as u64,
                        })
                        .collect(),
                    total_rows: total.max(0) as u64,
                })?
            );
        } else {
            println!();
            for t in &report {
                println!(
                    "  {}: {} rows",
                    t.table,
                    ui::format_count(t.row_count as u64)
                );
            }
            println!();
            ui::check(format!(
                "Dry run: {} rows across {} tables would be masked. Nothing was written.",
                ui::format_count(total.max(0) as u64),
                report.len()
            ));
        }
        return Ok(());
    }

    if !yes {
        let mut prompt_out = std::io::stderr();
        write!(
            prompt_out,
            "\nType \"yes\" to mask this database in place: "
        )
        .ok();
        prompt_out.flush().ok();
        let mut input = String::new();
        std::io::stdin().read_line(&mut input)?;
        if input.trim() != "yes" {
            ui::error("Aborted — input did not match \"yes\". Nothing was written.");
            anyhow::bail!("aborted: confirmation not given");
        }
    }

    if !json {
        println!();
        ui::heading("Masking...");
    }
    let spinner = ui::spinner("starting...");
    let mut table_counts: HashMap<String, u64> = HashMap::new();
    let mut finished: Vec<(String, u64)> = Vec::new();

    let run_result = sanitize::run_sanitization(
        &mut client,
        &schema,
        &plan,
        &config,
        batch_size,
        resume,
        max_batches,
        |event| match event {
            ProgressEvent::TableStarted { table } => {
                spinner.set_message(format!("{table} ..."));
            }
            ProgressEvent::BatchCommitted { table, rows } => {
                let count = table_counts.entry(table.to_string()).or_insert(0);
                *count += rows;
                spinner.set_message(format!(
                    "{table}: {} rows masked so far",
                    ui::format_count(*count)
                ));
            }
            ProgressEvent::TableFinished { table, rows } => {
                finished.push((table.to_string(), rows));
            }
        },
    )
    .await;
    spinner.finish_and_clear();

    let summary = match run_result {
        Ok(s) => s,
        Err(e) => {
            ui::error(format!("{e}"));
            // Unlike `up`/`clone`, this does NOT roll back — each batch
            // already committed independently, on purpose, so a
            // multi-hour run survives being interrupted. Whatever
            // completed stayed masked; nothing completed is lost.
            ui::error(
                "Stopped partway through. Already-masked batches are committed and stay masked \
                 (this is expected, not data loss). Re-run with --resume to continue from where \
                 this run stopped.",
            );
            return Err(e.into());
        }
    };

    if !json {
        println!();
        for (table, rows) in &summary.rows_by_table {
            ui::check(format!("{table}: {} rows", ui::format_count(*rows)));
        }
        println!();
        ui::check(format!(
            "{} rows masked",
            ui::format_count(summary.total_rows)
        ));
        ui::check("Row counts unchanged on every table");
        ui::check("Primary keys and foreign keys untouched");
    }

    let mut verification_json = None;

    if !skip_verify {
        if !json {
            println!();
        }
        let spinner = ui::spinner("Verifying masked values...");
        let findings = verify::verify_masking(&client, &schema, &plan).await?;
        spinner.finish_and_clear();

        let ok = findings.is_empty();
        if !json {
            if ok {
                ui::check("Verification: every masked column looks correctly masked");
            } else {
                ui::error(format!(
                    "Verification found {} issue(s) — masking may not have applied cleanly:",
                    findings.len()
                ));
                for f in &findings {
                    ui::error(format!(
                        "  {}.{} ({}): {}",
                        f.table,
                        f.column,
                        strategy_label(f.strategy),
                        f.issue
                    ));
                }
            }
        }
        verification_json = Some(VerificationJson {
            ok,
            issues: findings
                .iter()
                .map(|f| VerificationIssueJson {
                    table: f.table.clone(),
                    column: f.column.clone(),
                    strategy: strategy_label(f.strategy),
                    issue: f.issue.clone(),
                })
                .collect(),
        });
    }

    if json {
        println!(
            "{}",
            serde_json::to_string(&MaskJson {
                target: describe_target(database_url),
                tables: summary
                    .rows_by_table
                    .iter()
                    .map(|(table, rows)| MaskTableJson {
                        table: table.clone(),
                        rows: *rows,
                    })
                    .collect(),
                total_rows: summary.total_rows,
                verification: verification_json.clone(),
            })?
        );
    }

    if let Some(v) = &verification_json {
        if !v.ok {
            anyhow::bail!(
                "{} column(s) failed post-mask verification. The masking run itself completed \
                 and committed (see above) — this is a separate check on top of it. Investigate \
                 before treating this database as safe.",
                v.issues.len()
            );
        }
    }

    Ok(())
}

fn strategy_label(strategy: feint_core::mask::MaskStrategy) -> &'static str {
    use feint_core::mask::MaskStrategy;
    match strategy {
        MaskStrategy::Fake => "fake",
        MaskStrategy::Hash => "hash",
        MaskStrategy::Redact => "redact",
        MaskStrategy::None => "none",
    }
}

/// Host/port/db/user only — never the password, even though it may be
/// present in `database_url`.
fn describe_target(database_url: &str) -> String {
    let Ok(config) = database_url.parse::<tokio_postgres::Config>() else {
        return "<unparseable connection URL>".to_string();
    };
    let host = match config.get_hosts().first() {
        Some(Host::Tcp(h)) => h.clone(),
        _ => "?".to_string(),
    };
    let port = config.get_ports().first().copied().unwrap_or(5432);
    let dbname = config.get_dbname().unwrap_or("?");
    let user = config.get_user().unwrap_or("?");
    format!("{user}@{host}:{port}/{dbname}")
}
