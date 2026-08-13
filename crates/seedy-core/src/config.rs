//! `seedy.yaml` config model.

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::error::Result;
use crate::introspect::Schema;

pub const DEFAULT_SEED: &str = "default";
pub const DEFAULT_ROWS: u32 = 100;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ColumnConfig {
    pub generator: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TableConfig {
    pub rows: u32,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub columns: BTreeMap<String, ColumnConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct SeedyConfig {
    pub version: u32,
    pub seed: String,
    pub tables: BTreeMap<String, TableConfig>,
}

impl SeedyConfig {
    /// Build a default config from an introspected schema: every table
    /// gets `DEFAULT_ROWS` rows and no explicit column overrides — column
    /// generators are inferred at generation time by
    /// [`crate::generate::resolve_generator`], so the file the user sees
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
                        columns: BTreeMap::new(),
                    },
                )
            })
            .collect();
        SeedyConfig {
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
}
