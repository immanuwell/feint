use std::path::Path;

use feint_core::config::FeintConfig;
use feint_core::graph::{self, InsertGroup, TreeNode};
use feint_core::introspect;

use crate::ui;

pub async fn run(database_url: &str, config_path: &Path, schemas: &[String]) -> anyhow::Result<()> {
    let spinner = ui::spinner("Analyzing database...");
    let client = feint_core::connect::connect(database_url).await?;

    let schema = introspect::introspect(&client, schemas).await?;
    spinner.finish_and_clear();

    // A feint.yaml may not exist yet — `plan` is useful both before and
    // after `init`, falling back to default row counts when there's none.
    let config = FeintConfig::load(config_path).ok();

    println!();
    for root in graph::dependency_tree(&schema) {
        print_tree(&root, "", true);
    }

    println!();
    ui::heading("Insertion order:");
    match graph::plan_insertion(&schema) {
        Ok(plan) => {
            let mut step = 1u32;
            let mut total_rows: u64 = 0;
            for group in &plan.groups {
                let label = match group {
                    InsertGroup::Simple(_) => None,
                    InsertGroup::Deferred(_) => Some("deferred cycle"),
                    InsertGroup::Backfill {
                        self_referencing, ..
                    } => {
                        if self_referencing.is_empty() {
                            Some("null+backfill cycle")
                        } else {
                            Some("null+backfill cycle, self-referencing")
                        }
                    }
                    InsertGroup::SelfReferencing(_) => Some("self-referencing, sequence-anchored"),
                };
                for table in group.tables() {
                    let rows = config
                        .as_ref()
                        .and_then(|c| c.table_config(&table.qualified()))
                        .map(|tc| tc.rows)
                        .unwrap_or(feint_core::config::DEFAULT_ROWS);
                    total_rows += rows as u64;
                    let suffix = label.map(|l| format!("  ({l})")).unwrap_or_default();
                    println!(
                        "  {step}. {} ({} rows){suffix}",
                        table.qualified(),
                        ui::format_count(rows as u64)
                    );
                    step += 1;
                }
            }
            println!();
            ui::check(format!(
                "Estimated {} rows total",
                ui::format_count(total_rows)
            ));
        }
        Err(e) => ui::warn(format!("{e}")),
    }

    let sensitive_count: usize = schema
        .tables
        .iter()
        .flat_map(|t| &t.columns)
        .filter(|c| feint_core::generate::classify_sensitive(&c.name).is_some())
        .count();
    if sensitive_count > 0 {
        println!("Sensitive columns: {sensitive_count} (see `feint init` for details)");
    }

    Ok(())
}

fn print_tree(node: &TreeNode, prefix: &str, is_root: bool) {
    if is_root {
        println!("{}", node.table.name);
    }

    let n = node.children.len();
    for (i, child) in node.children.iter().enumerate() {
        let is_last = i == n - 1;
        let connector = if is_last { "└── " } else { "├── " };
        let marker = if child.cyclic_ref { " ⟲" } else { "" };
        println!("{prefix}{connector}{}{marker}", child.table.name);

        let next_prefix = format!("{prefix}{}", if is_last { "    " } else { "│   " });
        print_tree(child, &next_prefix, false);
    }
}
