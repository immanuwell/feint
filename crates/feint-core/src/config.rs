//! `feint.yaml` config model.

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::error::Result;
use crate::introspect::Schema;
use crate::mask::MaskStrategy;

pub const DEFAULT_SEED: &str = "default";
pub const DEFAULT_ROWS: u32 = 100;

#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
pub struct ColumnConfig {
    #[serde(default)]
    pub generator: Option<String>,
    /// CLONE-mode masking strategy override. See [`crate::mask`].
    #[serde(default)]
    pub mask: Option<MaskStrategy>,
}

/// Per-table behavior for `clone`'s hybrid mode: clone this table's real
/// rows (masked, as always), or leave the real rows alone entirely and pad
/// with `rows:` synthetic rows generated the same way `up` would. See
/// [`crate::clone`] and DOCS.md's "Hybrid clone" section for the
/// soundness rule this implies about which tables can reference which.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TableStrategy {
    #[default]
    Mask,
    Generate,
}

impl TableStrategy {
    fn is_default(&self) -> bool {
        *self == TableStrategy::Mask
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TableConfig {
    pub rows: u32,
    /// See [`TableStrategy`]. Defaults to `mask` — a table this key never
    /// mentions behaves exactly as `clone` always has.
    #[serde(default, skip_serializing_if = "TableStrategy::is_default")]
    pub strategy: TableStrategy,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub columns: BTreeMap<String, ColumnConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct FeintConfig {
    pub version: u32,
    pub seed: String,
    pub tables: BTreeMap<String, TableConfig>,
}

impl FeintConfig {
    /// Build a default config from an introspected schema: every table
    /// gets `DEFAULT_ROWS` rows and no explicit column overrides — column
    /// generators are inferred at generation time by
    /// [`crate::generate::generate_value`], so the file the user sees
    /// stays short and readable rather than listing every column.
    pub fn from_schema(schema: &Schema) -> Self {
        let tables = schema
            .tables
            .iter()
            .map(|t| {
                (
                    t.id.qualified(),
                    TableConfig {
                        rows: DEFAULT_ROWS,
                        strategy: TableStrategy::default(),
                        columns: BTreeMap::new(),
                    },
                )
            })
            .collect();
        FeintConfig {
            version: 1,
            seed: DEFAULT_SEED.to_string(),
            tables,
        }
    }

    pub fn load(path: &Path) -> Result<Self> {
        let text = std::fs::read_to_string(path)?;
        Ok(serde_yaml_ng::from_str(&text)?)
    }

    pub fn save(&self, path: &Path) -> Result<()> {
        let text = serde_yaml_ng::to_string(self)?;
        std::fs::write(path, text)?;
        Ok(())
    }

    pub fn table_config(&self, qualified_name: &str) -> Option<&TableConfig> {
        self.tables.get(qualified_name)
    }

    /// Render as YAML with each table's CHECK-constraint definitions
    /// inlined as comments above it. `serde` can't attach comments, so
    /// this builds the text by hand; kept separate from `save`/`load`
    /// (plain `serde_yaml_ng` round-trips used by `up`) since this is
    /// purely for the human-facing file `init` writes — the comments are
    /// non-semantic and dropped on the next `load`.
    pub fn to_annotated_yaml(&self, schema: &Schema) -> String {
        let mut out = String::new();
        out.push_str(&format!("version: {}\n", self.version));
        out.push_str(&format!("seed: {}\n", self.seed));
        out.push_str("tables:\n");
        for (name, table_config) in &self.tables {
            out.push_str(&format!("  {name}:\n"));
            if let Some(table) = schema.tables.iter().find(|t| t.id.qualified() == *name) {
                if !table.check_constraints.is_empty() {
                    out.push_str("    # CHECK constraints (not validated by generators):\n");
                    for check in &table.check_constraints {
                        out.push_str(&format!("    #   {}: {}\n", check.name, check.definition));
                    }
                }
            }
            out.push_str(&format!("    rows: {}\n", table_config.rows));
            if !table_config.strategy.is_default() {
                let s = serde_yaml_ng::to_string(&table_config.strategy).unwrap_or_default();
                out.push_str(&format!("    strategy: {}\n", s.trim()));
            }
            if !table_config.columns.is_empty() {
                out.push_str("    columns:\n");
                for (col_name, col_config) in &table_config.columns {
                    out.push_str(&format!("      {col_name}:\n"));
                    if let Some(gen) = &col_config.generator {
                        out.push_str(&format!("        generator: {gen}\n"));
                    }
                    if let Some(mask) = col_config.mask {
                        let s = serde_yaml_ng::to_string(&mask).unwrap_or_default();
                        out.push_str(&format!("        mask: {}\n", s.trim()));
                    }
                }
            }
        }
        out
    }

    pub fn save_annotated(&self, schema: &Schema, path: &Path) -> Result<()> {
        std::fs::write(path, self.to_annotated_yaml(schema))?;
        Ok(())
    }
}
