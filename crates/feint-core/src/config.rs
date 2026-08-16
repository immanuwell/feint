//! `feint.yaml` config model.

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::error::{FeintError, Result};
use crate::introspect::{ForeignKey, Schema};
use crate::mask::{JsonPathRules, MaskStrategy};

pub const DEFAULT_SEED: &str = "default";
pub const DEFAULT_ROWS: u32 = 100;

#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
pub struct ColumnConfig {
    #[serde(default)]
    pub generator: Option<String>,
    /// CLONE-mode masking strategy override. See [`crate::mask`].
    #[serde(default)]
    pub mask: Option<MaskStrategy>,
    /// Per-path masking rules for a `json`/`jsonb` column: mask specific
    /// keys inside the value instead of the whole column. Mutually
    /// exclusive with `mask` (other than `mask: none`, the default) — see
    /// [`crate::mask::validate_masking_config`]. Only meaningful for
    /// `clone`/`mask`; GENERATE mode never reads it.
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub json_paths: JsonPathRules,
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

/// A user-declared FK relationship with no matching PostgreSQL constraint
/// — for a column whose value is only ever tied to another table by
/// application logic invisible to SQL introspection (e.g. a trigger keyed
/// off it with no declared `REFERENCES`, or a value a `BEFORE INSERT`
/// trigger validates against another table). GENERATE mode merges every
/// table's `logical_foreign_keys` into the introspected schema's real
/// `foreign_keys` via [`apply_logical_foreign_keys`] before planning
/// insertion order, so RefPool sampling and dependency ordering treat it
/// exactly like a real FK — the only difference is Postgres itself never
/// validates it, so a wrong declaration fails as an ordinary FK violation
/// at insert time rather than a config-time error. See DOCS.md's "Logical
/// foreign keys" section.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct LogicalForeignKey {
    /// This table's own column(s) that should be sampled from
    /// `ref_table`'s existing values instead of generated independently.
    pub columns: Vec<String>,
    /// Schema-qualified, e.g. `public.accounts` — same format as a
    /// `feint.yaml` table key.
    pub ref_table: String,
    pub ref_columns: Vec<String>,
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
    /// See [`LogicalForeignKey`]. Empty for every table `init` generates —
    /// there's no safe way to infer one from the schema alone; a user adds
    /// these by hand once they've identified the real relationship.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub logical_foreign_keys: Vec<LogicalForeignKey>,
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
                        logical_foreign_keys: Vec::new(),
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

/// Merge every table's [`LogicalForeignKey`]s into the introspected
/// schema's real `Table.foreign_keys`, so the rest of the pipeline
/// (dependency ordering in [`crate::graph::plan_insertion`], RefPool
/// sampling in `insert.rs`) treats them identically to a real FK
/// constraint. Call once, right after introspection and before
/// `plan_insertion`/`insert::run` — every read of `schema` here is
/// immutable until every declaration across every table has been
/// validated, so a bad declaration on one table can't leave an earlier
/// table's real `foreign_keys` half-mutated.
pub fn apply_logical_foreign_keys(schema: &mut Schema, config: &FeintConfig) -> Result<()> {
    let mut to_add: Vec<(crate::introspect::TableId, ForeignKey)> = Vec::new();

    for (table_key, table_config) in &config.tables {
        for (i, lfk) in table_config.logical_foreign_keys.iter().enumerate() {
            if lfk.columns.is_empty() || lfk.columns.len() != lfk.ref_columns.len() {
                return Err(FeintError::Config(format!(
                    "table `{table_key}`'s logical_foreign_keys[{i}] must list the same \
                     number of `columns` and `ref_columns` (got {} and {})",
                    lfk.columns.len(),
                    lfk.ref_columns.len()
                )));
            }
            let Some(table) = schema
                .tables
                .iter()
                .find(|t| &t.id.qualified() == table_key)
            else {
                return Err(FeintError::Config(format!(
                    "feint.yaml declares logical_foreign_keys on `{table_key}`, but that \
                     table wasn't found in the introspected schema"
                )));
            };
            for c in &lfk.columns {
                if table.column(c).is_none() {
                    return Err(FeintError::Config(format!(
                        "table `{table_key}`'s logical_foreign_keys[{i}] names its own \
                         column `{c}`, which doesn't exist on that table"
                    )));
                }
            }
            let Some(ref_table) = schema
                .tables
                .iter()
                .find(|t| &t.id.qualified() == &lfk.ref_table)
            else {
                return Err(FeintError::Config(format!(
                    "table `{table_key}`'s logical_foreign_keys[{i}].ref_table `{}` wasn't \
                     found in the introspected schema — use its schema-qualified name (e.g. \
                     `public.accounts`)",
                    lfk.ref_table
                )));
            };
            for c in &lfk.ref_columns {
                if ref_table.column(c).is_none() {
                    return Err(FeintError::Config(format!(
                        "table `{table_key}`'s logical_foreign_keys[{i}].ref_columns names \
                         `{}`.`{c}`, which doesn't exist on that table",
                        lfk.ref_table
                    )));
                }
            }
            to_add.push((
                table.id.clone(),
                ForeignKey {
                    name: format!("feint_logical_fk_{table_key}_{i}").replace(['.', ' '], "_"),
                    columns: lfk.columns.clone(),
                    ref_table: ref_table.id.clone(),
                    ref_columns: lfk.ref_columns.clone(),
                    deferrable: false,
                    initially_deferred: false,
                },
            ));
        }
    }

    for (table_id, fk) in to_add {
        let table = schema
            .tables
            .iter_mut()
            .find(|t| t.id == table_id)
            .expect("table existence already validated above");
        table.foreign_keys.push(fk);
    }

    Ok(())
}

#[cfg(test)]
mod logical_fk_tests {
    use super::*;
    use crate::introspect::{Column, Identity, Table, TableId, TypeKind};

    fn int_column(name: &str) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "integer".to_string(),
            type_schema: "pg_catalog".to_string(),
            type_kind: TypeKind::Scalar,
            max_length: None,
            vector_dimensions: None,
            numeric_precision: None,
            numeric_scale: None,
            check_min: None,
            check_max: None,
            check_allowed_values: None,
            check_null_escape: false,
            check_like_prefix: None,
            nullable: false,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    /// `accounts(id)` and `conversations(id, account_id)` — Chatwoot's real
    /// shape, minimized: `conversations.account_id` has no real FK to
    /// `accounts.id` at all.
    fn chatwoot_shaped_schema() -> Schema {
        Schema {
            tables: vec![
                Table {
                    id: TableId {
                        schema: "public".to_string(),
                        name: "accounts".to_string(),
                    },
                    columns: vec![int_column("id")],
                    primary_key: Some(vec!["id".to_string()]),
                    foreign_keys: vec![],
                    unique_constraints: vec![],
                    check_constraints: vec![],
                },
                Table {
                    id: TableId {
                        schema: "public".to_string(),
                        name: "conversations".to_string(),
                    },
                    columns: vec![int_column("id"), int_column("account_id")],
                    primary_key: Some(vec!["id".to_string()]),
                    foreign_keys: vec![],
                    unique_constraints: vec![],
                    check_constraints: vec![],
                },
            ],
        }
    }

    fn config_with_lfk(lfk: LogicalForeignKey) -> FeintConfig {
        let mut config = FeintConfig {
            version: 1,
            seed: "test".to_string(),
            tables: BTreeMap::new(),
        };
        config.tables.insert(
            "public.conversations".to_string(),
            TableConfig {
                rows: DEFAULT_ROWS,
                strategy: TableStrategy::default(),
                columns: BTreeMap::new(),
                logical_foreign_keys: vec![lfk],
            },
        );
        config
    }

    #[test]
    fn merges_a_valid_declaration_into_the_real_foreign_keys() {
        let mut schema = chatwoot_shaped_schema();
        let config = config_with_lfk(LogicalForeignKey {
            columns: vec!["account_id".to_string()],
            ref_table: "public.accounts".to_string(),
            ref_columns: vec!["id".to_string()],
        });

        apply_logical_foreign_keys(&mut schema, &config).expect("should merge cleanly");

        let conversations = schema
            .tables
            .iter()
            .find(|t| t.id.name == "conversations")
            .unwrap();
        assert_eq!(conversations.foreign_keys.len(), 1);
        let fk = &conversations.foreign_keys[0];
        assert_eq!(fk.columns, vec!["account_id".to_string()]);
        assert_eq!(fk.ref_table.qualified(), "public.accounts");
        assert_eq!(fk.ref_columns, vec!["id".to_string()]);
        assert!(
            !fk.deferrable,
            "a logical FK has no real DB constraint to defer"
        );
    }

    #[test]
    fn a_table_with_no_logical_foreign_keys_declared_is_untouched() {
        let mut schema = chatwoot_shaped_schema();
        let config = FeintConfig {
            version: 1,
            seed: "test".to_string(),
            tables: BTreeMap::new(),
        };
        apply_logical_foreign_keys(&mut schema, &config).expect("no-op should not error");
        for table in &schema.tables {
            assert!(table.foreign_keys.is_empty());
        }
    }

    #[test]
    fn rejects_a_columns_ref_columns_length_mismatch() {
        let mut schema = chatwoot_shaped_schema();
        let config = config_with_lfk(LogicalForeignKey {
            columns: vec!["account_id".to_string()],
            ref_table: "public.accounts".to_string(),
            ref_columns: vec!["id".to_string(), "extra".to_string()],
        });
        let err = apply_logical_foreign_keys(&mut schema, &config).unwrap_err();
        assert!(format!("{err}").contains("same number"));
    }

    #[test]
    fn rejects_a_nonexistent_own_column() {
        let mut schema = chatwoot_shaped_schema();
        let config = config_with_lfk(LogicalForeignKey {
            columns: vec!["nope".to_string()],
            ref_table: "public.accounts".to_string(),
            ref_columns: vec!["id".to_string()],
        });
        let err = apply_logical_foreign_keys(&mut schema, &config).unwrap_err();
        assert!(format!("{err}").contains("nope"));
    }

    #[test]
    fn rejects_a_ref_table_not_found_in_the_schema() {
        let mut schema = chatwoot_shaped_schema();
        let config = config_with_lfk(LogicalForeignKey {
            columns: vec!["account_id".to_string()],
            ref_table: "public.does_not_exist".to_string(),
            ref_columns: vec!["id".to_string()],
        });
        let err = apply_logical_foreign_keys(&mut schema, &config).unwrap_err();
        assert!(format!("{err}").contains("does_not_exist"));
    }

    #[test]
    fn rejects_a_nonexistent_ref_column() {
        let mut schema = chatwoot_shaped_schema();
        let config = config_with_lfk(LogicalForeignKey {
            columns: vec!["account_id".to_string()],
            ref_table: "public.accounts".to_string(),
            ref_columns: vec!["nope".to_string()],
        });
        let err = apply_logical_foreign_keys(&mut schema, &config).unwrap_err();
        assert!(format!("{err}").contains("nope"));
    }

    #[test]
    fn a_declaration_on_a_table_not_in_the_schema_errors_clearly() {
        let mut schema = chatwoot_shaped_schema();
        let mut config = FeintConfig {
            version: 1,
            seed: "test".to_string(),
            tables: BTreeMap::new(),
        };
        config.tables.insert(
            "public.does_not_exist".to_string(),
            TableConfig {
                rows: DEFAULT_ROWS,
                strategy: TableStrategy::default(),
                columns: BTreeMap::new(),
                logical_foreign_keys: vec![LogicalForeignKey {
                    columns: vec!["x".to_string()],
                    ref_table: "public.accounts".to_string(),
                    ref_columns: vec!["id".to_string()],
                }],
            },
        );
        let err = apply_logical_foreign_keys(&mut schema, &config).unwrap_err();
        assert!(format!("{err}").contains("does_not_exist"));
    }
}
