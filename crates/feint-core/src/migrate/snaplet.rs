//! Best-effort migration from Snaplet Seed's `seed.config.ts` (and,
//! optionally, custom generators in `seed.ts`) to a `feint.yaml`.
//!
//! `seed.config.ts` is TypeScript, not a declarative config format —
//! this is deliberately **not** a full TS/JS parser. It extracts the one
//! genuinely portable, declarative piece (`select: [...]`, a flat array
//! of string literals) via a targeted text scan, and detects — without
//! claiming to fully understand — custom per-column generators defined in
//! `seed.ts`, which are arbitrary JS/TS closures and not mechanically
//! convertible in general.

use std::collections::BTreeMap;
use std::collections::HashSet;

use regex::Regex;

use crate::config::{FeintConfig, TableConfig, DEFAULT_ROWS, DEFAULT_SEED};
use crate::migrate::{MigrationReport, SkippedColumn};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SelectEntry {
    Include(String),
    Exclude(String),
}

pub struct SnapletMigration {
    pub config: FeintConfig,
    pub report: MigrationReport,
}

/// Convert a `seed.config.ts` source (and, optionally, a `seed.ts`
/// source) into a `FeintConfig` plus a report of what needs manual review.
pub fn migrate_snaplet(config_ts_source: &str, seed_ts_source: Option<&str>) -> SnapletMigration {
    let mut report = MigrationReport::default();
    let entries = parse_select(config_ts_source);

    let mut tables: BTreeMap<String, TableConfig> = BTreeMap::new();
    if entries.is_empty() {
        report.general_notes.push(
            "No `select` array found in seed.config.ts (or it wasn't in a form this parser \
             recognizes). Snaplet Seed selects every table by default in that case — run `feint \
             init <database-url>` against your database to discover tables directly."
                .to_string(),
        );
    }

    for entry in &entries {
        match entry {
            SelectEntry::Include(name) if !is_glob(name) => {
                tables
                    .entry(normalize_table_name(name))
                    .or_insert_with(|| TableConfig {
                        rows: DEFAULT_ROWS,
                        columns: BTreeMap::new(),
                    });
            }
            SelectEntry::Include(name) => {
                report.general_notes.push(format!(
                    "select includes the glob pattern `{name}` — feint.yaml needs literal table \
                     names. Run `feint init <database-url>` and keep the tables matching this \
                     pattern in the generated file."
                ));
            }
            SelectEntry::Exclude(name) => {
                report.general_notes.push(format!(
                    "select excludes `{name}` — make sure this table isn't listed in the \
                     generated feint.yaml, or remove it by hand after `feint init`."
                ));
            }
        }
    }

    if let Some(seed_ts) = seed_ts_source {
        for table in detect_custom_generators(seed_ts) {
            report.skipped.push(SkippedColumn {
                table: normalize_table_name(&table),
                column: "*".to_string(),
                reason: "seed.ts defines custom per-row generator logic for this model in \
                         TypeScript, which can't be mechanically converted. Review seed.ts and \
                         add explicit `generator:` overrides in feint.yaml where you still want \
                         that column to look a specific way."
                    .to_string(),
            });
        }
    }

    SnapletMigration {
        config: FeintConfig {
            version: 1,
            seed: DEFAULT_SEED.to_string(),
            tables,
        },
        report,
    }
}

fn is_glob(s: &str) -> bool {
    s.contains('*') || s.contains('?')
}

/// Snaplet `select` entries are often bare table names (`"users"`) or
/// schema-qualified (`"public.users"`); feint.yaml always wants
/// `schema.table`.
fn normalize_table_name(s: &str) -> String {
    if s.contains('.') {
        s.to_string()
    } else {
        format!("public.{s}")
    }
}

/// Extract the `select: [...]` array from a `seed.config.ts` source as a
/// flat list of string literals, in file order. Returns an empty list if
/// no `select` field is found.
pub fn parse_select(source: &str) -> Vec<SelectEntry> {
    let Some(select_idx) = source.find("select") else {
        return Vec::new();
    };
    let Some(rel_bracket_start) = source[select_idx..].find('[') else {
        return Vec::new();
    };
    let bracket_start = select_idx + rel_bracket_start;
    let Some(bracket_end) = find_matching_bracket(source, bracket_start) else {
        return Vec::new();
    };
    let body = &source[bracket_start + 1..bracket_end];

    let literal_re = Regex::new(r#"'([^']*)'|"([^"]*)""#).expect("valid regex");
    literal_re
        .captures_iter(body)
        .filter_map(|cap| cap.get(1).or_else(|| cap.get(2)))
        .map(|m| m.as_str())
        .map(|literal| {
            if let Some(pattern) = literal.strip_prefix('!') {
                SelectEntry::Exclude(pattern.to_string())
            } else {
                SelectEntry::Include(literal.to_string())
            }
        })
        .collect()
}

fn find_matching_bracket(source: &str, open_idx: usize) -> Option<usize> {
    let bytes = source.as_bytes();
    let mut depth = 0i32;
    for (i, &b) in bytes.iter().enumerate().skip(open_idx) {
        match b {
            b'[' => depth += 1,
            b']' => {
                depth -= 1;
                if depth == 0 {
                    return Some(i);
                }
            }
            _ => {}
        }
    }
    None
}

/// Best-effort scan for `seed.<model>(` calls in a `seed.ts` source —
/// Snaplet Seed's fluent client pattern for supplying custom per-row
/// generator closures. Returns the distinct model names found, in first-
/// seen order. Not a JS parser: this only tells you *which* models have
/// custom logic, not what that logic does.
pub fn detect_custom_generators(seed_ts_source: &str) -> Vec<String> {
    let re = Regex::new(r"\bseed\.([A-Za-z_][A-Za-z0-9_]*)\s*\(").expect("valid regex");
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for cap in re.captures_iter(seed_ts_source) {
        let name = cap[1].to_string();
        if seen.insert(name.clone()) {
            out.push(name);
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_CONFIG: &str = r#"
        import { defineConfig } from "@snaplet/seed/config";

        export default defineConfig({
          adapter: () => new SeedPostgres(postgres(process.env.DATABASE_URL)),
          select: [
            "!archive*",
            "!*_logs",
            "public.users",
            "auth.identities",
          ],
        });
    "#;

    #[test]
    fn parses_include_and_exclude_entries() {
        let entries = parse_select(EXAMPLE_CONFIG);
        assert_eq!(
            entries,
            vec![
                SelectEntry::Exclude("archive*".to_string()),
                SelectEntry::Exclude("*_logs".to_string()),
                SelectEntry::Include("public.users".to_string()),
                SelectEntry::Include("auth.identities".to_string()),
            ]
        );
    }

    #[test]
    fn migration_includes_literal_tables_and_flags_globs() {
        let migration = migrate_snaplet(EXAMPLE_CONFIG, None);
        assert!(migration.config.tables.contains_key("public.users"));
        assert!(migration.config.tables.contains_key("auth.identities"));
        assert_eq!(migration.config.tables.len(), 2);
        assert_eq!(
            migration.report.general_notes.len(),
            2,
            "both globs should be flagged"
        );
    }

    #[test]
    fn bare_table_name_gets_public_schema() {
        let entries = vec![SelectEntry::Include("orders".to_string())];
        let mut tables = BTreeMap::new();
        for e in &entries {
            if let SelectEntry::Include(name) = e {
                tables.insert(normalize_table_name(name), ());
            }
        }
        assert!(tables.contains_key("public.orders"));
    }

    #[test]
    fn detects_custom_generator_models() {
        let seed_ts = r#"
            await seed.users([{ email: (ctx) => faker.internet.email() }]);
            await seed.orders([{ total: () => 42 }]);
            await seed.users([{ name: "Alice" }]);
        "#;
        let found = detect_custom_generators(seed_ts);
        assert_eq!(found, vec!["users".to_string(), "orders".to_string()]);
    }

    #[test]
    fn migration_reports_custom_generator_models_as_skipped() {
        let seed_ts = "await seed.users([{ email: (ctx) => faker.internet.email() }]);";
        let migration = migrate_snaplet(EXAMPLE_CONFIG, Some(seed_ts));
        assert_eq!(migration.report.skipped.len(), 1);
        assert_eq!(migration.report.skipped[0].table, "public.users");
    }

    #[test]
    fn missing_select_produces_a_general_note() {
        let migration =
            migrate_snaplet("export default defineConfig({ adapter: () => {} });", None);
        assert!(migration.config.tables.is_empty());
        assert_eq!(migration.report.general_notes.len(), 1);
    }
}
