use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::introspect;
use feint_core::mask::MaskStrategy;
use feint_core::policy::{self, PolicyApplyReport};

use crate::ui;

pub fn list() {
    println!();
    ui::heading("Available masking policies:");
    for p in policy::POLICIES {
        println!();
        println!("  {}", p.name);
        println!("    {}", p.description);
    }
    println!();
    println!("Apply one with: feint policy apply <NAME> <DATABASE_URL>");
}

pub async fn apply(
    name: &str,
    database_url: &str,
    config_path: &Path,
    schemas: &[String],
    force: bool,
) -> anyhow::Result<()> {
    let Some(policy_def) = policy::POLICIES.iter().find(|p| p.name == name) else {
        let names: Vec<&str> = policy::POLICIES.iter().map(|p| p.name).collect();
        anyhow::bail!("unknown policy `{name}`. Available: {}", names.join(", "));
    };

    let mut config = if config_path.exists() {
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

    let PolicyApplyReport {
        applied,
        skipped_existing,
        skipped_key,
    } = policy::apply_policy(policy_def, &schema, &mut config, force);
    config.save(config_path)?;

    println!();
    ui::heading(format!("Applied policy `{name}`:"));
    for (table, column, strategy) in &applied {
        println!("  {table}.{column}: mask: {}", strategy_label(*strategy));
    }

    if !skipped_existing.is_empty() {
        println!();
        ui::warn(format!(
            "{} column(s) already had an explicit mask: left unchanged. Pass --force to overwrite.",
            skipped_existing.len()
        ));
    }
    if !skipped_key.is_empty() {
        println!();
        ui::warn(format!(
            "{} column(s) matched the policy but are primary/foreign keys: left unmasked, as always.",
            skipped_key.len()
        ));
    }

    println!();
    if applied.is_empty() {
        ui::check(format!("No new columns matched. {}", config_path.display()));
    } else {
        ui::check(format!(
            "{} column(s) configured. Wrote {}",
            applied.len(),
            config_path.display()
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
