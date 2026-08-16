//! Column classification and its lockfile: which columns look sensitive,
//! and what masking strategy they currently resolve to. This is fail-closed
//! masking, not another masking strategy — it exists because the
//! resolve-by-default heuristic in [`crate::mask::resolve_mask_strategy`]
//! is convenient but silent: a brand new column that the heuristic doesn't
//! recognize resolves to [`MaskStrategy::None`] and nothing about a normal
//! `mask` or `clone` run notices or fails. A committed lockfile pins the
//! last consciously-reviewed classification of every non-key column, so a
//! CI run can compare the live schema against it and fail the moment they
//! disagree, instead of trusting the heuristic forever by convention.
//!
//! Complements `verify.rs`: that module checks masking that already ran
//! actually did what it claimed. This module checks the *plan* before
//! anything runs at all.

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::config::FeintConfig;
use crate::error::Result;
use crate::generate::classify_sensitive;
use crate::introspect::Schema;
use crate::mask::{is_key_column, resolve_mask_strategy, JsonPathRules, MaskStrategy};

pub const DEFAULT_LOCKFILE: &str = "feint.lock.yaml";
const LOCK_VERSION: u32 = 1;

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ColumnClassification {
    /// True if the column name matches feint's sensitive-name heuristic
    /// ([`classify_sensitive`]), regardless of what strategy it resolved to
    /// — a heuristic hit with an explicit `mask: none` override is exactly
    /// the case this module exists to surface.
    pub sensitive: bool,
    pub strategy: MaskStrategy,
    /// Configured `json_paths:` rules, if any. A column with rules here
    /// and `strategy: none` is not unmasked — it's masked per-path
    /// instead. See [`crate::mask::mask_json_column_value`].
    #[serde(default, skip_serializing_if = "JsonPathRules::is_empty")]
    pub json_paths: JsonPathRules,
}

/// Every non-key, writable column in the schema, keyed `schema.table.column`.
/// Key columns and stored-generated columns are left out: they can never
/// resolve to anything but `none` (see [`is_key_column`]), so tracking them
/// in the lockfile would just be permanent, unactionable noise.
#[derive(Debug, Clone, Default, Serialize)]
pub struct ClassificationReport {
    pub columns: BTreeMap<String, ColumnClassification>,
}

pub fn classify_schema(schema: &Schema, config: &FeintConfig) -> ClassificationReport {
    let mut columns = BTreeMap::new();
    for table in &schema.tables {
        let empty = BTreeMap::new();
        let overrides = config
            .table_config(&table.id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);

        for column in &table.columns {
            if column.is_stored_generated || is_key_column(table, &column.name) {
                continue;
            }
            let override_strategy = overrides.get(&column.name).and_then(|c| c.mask);
            let strategy = resolve_mask_strategy(table, column, override_strategy);
            let sensitive = classify_sensitive(&column.name).is_some();
            let json_paths = overrides
                .get(&column.name)
                .map(|c| c.json_paths.clone())
                .unwrap_or_default();
            let key = format!("{}.{}", table.id.qualified(), column.name);
            columns.insert(
                key,
                ColumnClassification {
                    sensitive,
                    strategy,
                    json_paths,
                },
            );
        }
    }
    ClassificationReport { columns }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
struct LockedColumn {
    sensitive: bool,
    strategy: MaskStrategy,
    #[serde(default, skip_serializing_if = "JsonPathRules::is_empty")]
    json_paths: JsonPathRules,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ClassificationLock {
    version: u32,
    columns: BTreeMap<String, LockedColumn>,
}

impl ClassificationLock {
    pub fn from_report(report: &ClassificationReport) -> Self {
        ClassificationLock {
            version: LOCK_VERSION,
            columns: report
                .columns
                .iter()
                .map(|(k, v)| {
                    (
                        k.clone(),
                        LockedColumn {
                            sensitive: v.sensitive,
                            strategy: v.strategy,
                            json_paths: v.json_paths.clone(),
                        },
                    )
                })
                .collect(),
        }
    }

    /// `None` if the file doesn't exist yet — a fresh repo with no approved
    /// classification, not an error condition by itself. Callers that
    /// require an established baseline (e.g. `--check`) turn that into an
    /// error explicitly.
    pub fn load(path: &Path) -> Result<Option<Self>> {
        if !path.exists() {
            return Ok(None);
        }
        let text = std::fs::read_to_string(path)?;
        Ok(Some(serde_yaml_ng::from_str(&text)?))
    }

    pub fn save(&self, path: &Path) -> Result<()> {
        let text = serde_yaml_ng::to_string(self)?;
        std::fs::write(path, text)?;
        Ok(())
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct DriftEntry {
    pub column: String,
    pub sensitive: bool,
    pub strategy: MaskStrategy,
}

#[derive(Debug, Clone, Serialize)]
pub struct ChangedEntry {
    pub column: String,
    pub old: ColumnClassification,
    pub new: ColumnClassification,
}

#[derive(Debug, Clone, Default, Serialize)]
pub struct ClassificationDiff {
    /// Columns that exist now but were absent from the lockfile entirely —
    /// e.g. a new column any engineer just added.
    pub new_columns: Vec<DriftEntry>,
    /// Columns the lockfile knows about that no longer exist in the schema.
    pub removed_columns: Vec<String>,
    /// Columns present in both, but whose sensitivity or resolved strategy
    /// changed since the lockfile was last written.
    pub changed_columns: Vec<ChangedEntry>,
}

impl ClassificationDiff {
    pub fn is_dirty(&self) -> bool {
        !self.new_columns.is_empty()
            || !self.removed_columns.is_empty()
            || !self.changed_columns.is_empty()
    }

    /// The subset of `new_columns` that also match the sensitive-name
    /// heuristic — the scariest slice of the diff, called out separately
    /// because "3 new columns, 1 looks sensitive" is a very different
    /// severity than "3 new columns, 0 look sensitive."
    pub fn new_sensitive_count(&self) -> usize {
        self.new_columns.iter().filter(|c| c.sensitive).count()
    }
}

pub fn diff_against_lock(
    report: &ClassificationReport,
    lock: &ClassificationLock,
) -> ClassificationDiff {
    let mut diff = ClassificationDiff::default();

    for (column, current) in &report.columns {
        match lock.columns.get(column) {
            None => diff.new_columns.push(DriftEntry {
                column: column.clone(),
                sensitive: current.sensitive,
                strategy: current.strategy,
            }),
            Some(locked) => {
                if locked.sensitive != current.sensitive
                    || locked.strategy != current.strategy
                    || locked.json_paths != current.json_paths
                {
                    diff.changed_columns.push(ChangedEntry {
                        column: column.clone(),
                        old: ColumnClassification {
                            sensitive: locked.sensitive,
                            strategy: locked.strategy,
                            json_paths: locked.json_paths.clone(),
                        },
                        new: current.clone(),
                    });
                }
            }
        }
    }

    for column in lock.columns.keys() {
        if !report.columns.contains_key(column) {
            diff.removed_columns.push(column.clone());
        }
    }

    diff
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Column, Identity, Table, TableId, TypeKind};

    fn text_column(name: &str) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "text".to_string(),
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
            nullable: true,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    fn schema_with(columns: Vec<Column>) -> Schema {
        Schema {
            tables: vec![Table {
                id: TableId {
                    schema: "public".to_string(),
                    name: "users".to_string(),
                },
                columns,
                primary_key: Some(vec!["id".to_string()]),
                foreign_keys: vec![],
                unique_constraints: vec![],
                check_constraints: vec![],
            }],
        }
    }

    fn empty_config() -> FeintConfig {
        FeintConfig {
            version: 1,
            seed: "seed".to_string(),
            tables: Default::default(),
        }
    }

    #[test]
    fn key_columns_are_excluded_from_the_report() {
        let schema = schema_with(vec![text_column("id"), text_column("email")]);
        let report = classify_schema(&schema, &empty_config());
        assert!(!report.columns.contains_key("public.users.id"));
        assert!(report.columns.contains_key("public.users.email"));
    }

    #[test]
    fn heuristic_hit_resolves_to_fake_by_default() {
        let schema = schema_with(vec![text_column("id"), text_column("email")]);
        let report = classify_schema(&schema, &empty_config());
        let entry = &report.columns["public.users.email"];
        assert!(entry.sensitive);
        assert_eq!(entry.strategy, MaskStrategy::Fake);
    }

    #[test]
    fn non_heuristic_column_is_unmasked_and_not_flagged_sensitive() {
        let schema = schema_with(vec![text_column("id"), text_column("status")]);
        let report = classify_schema(&schema, &empty_config());
        let entry = &report.columns["public.users.status"];
        assert!(!entry.sensitive);
        assert_eq!(entry.strategy, MaskStrategy::None);
    }

    #[test]
    fn a_new_column_since_the_lockfile_shows_up_as_drift() {
        let before = schema_with(vec![text_column("id"), text_column("email")]);
        let lock = ClassificationLock::from_report(&classify_schema(&before, &empty_config()));

        let after = schema_with(vec![
            text_column("id"),
            text_column("email"),
            text_column("ssn"),
        ]);
        let report = classify_schema(&after, &empty_config());
        let diff = diff_against_lock(&report, &lock);

        assert!(diff.is_dirty());
        assert_eq!(diff.new_columns.len(), 1);
        assert_eq!(diff.new_columns[0].column, "public.users.ssn");
        assert!(diff.new_columns[0].sensitive);
        assert_eq!(diff.new_sensitive_count(), 1);
        assert!(diff.removed_columns.is_empty());
        assert!(diff.changed_columns.is_empty());
    }

    #[test]
    fn a_removed_column_shows_up_as_drift_too() {
        let before = schema_with(vec![text_column("id"), text_column("email")]);
        let lock = ClassificationLock::from_report(&classify_schema(&before, &empty_config()));

        let after = schema_with(vec![text_column("id")]);
        let report = classify_schema(&after, &empty_config());
        let diff = diff_against_lock(&report, &lock);

        assert!(diff.is_dirty());
        assert_eq!(diff.removed_columns, vec!["public.users.email".to_string()]);
    }

    #[test]
    fn weakening_an_override_from_hash_to_none_shows_up_as_changed_not_new() {
        let schema = schema_with(vec![text_column("id"), text_column("email")]);
        let mut config = empty_config();
        let lock = {
            let mut hashed_config = config.clone();
            hashed_config.tables.insert(
                "public.users".to_string(),
                crate::config::TableConfig {
                    rows: 10,
                    strategy: Default::default(),
                    columns: BTreeMap::from([(
                        "email".to_string(),
                        crate::config::ColumnConfig {
                            generator: None,
                            mask: Some(MaskStrategy::Hash),
                            json_paths: Default::default(),
                        },
                    )]),
                    logical_foreign_keys: Default::default(),
                },
            );
            ClassificationLock::from_report(&classify_schema(&schema, &hashed_config))
        };

        // Someone quietly downgrades the override to `none` — no new or
        // removed column, but a real, security-relevant change.
        config.tables.insert(
            "public.users".to_string(),
            crate::config::TableConfig {
                rows: 10,
                strategy: Default::default(),
                columns: BTreeMap::from([(
                    "email".to_string(),
                    crate::config::ColumnConfig {
                        generator: None,
                        mask: Some(MaskStrategy::None),
                        json_paths: Default::default(),
                    },
                )]),
                logical_foreign_keys: Default::default(),
            },
        );
        let report = classify_schema(&schema, &config);
        let diff = diff_against_lock(&report, &lock);

        assert!(diff.is_dirty());
        assert!(diff.new_columns.is_empty());
        assert_eq!(diff.changed_columns.len(), 1);
        assert_eq!(diff.changed_columns[0].old.strategy, MaskStrategy::Hash);
        assert_eq!(diff.changed_columns[0].new.strategy, MaskStrategy::None);
    }

    #[test]
    fn matching_lockfile_is_not_dirty() {
        let schema = schema_with(vec![text_column("id"), text_column("email")]);
        let report = classify_schema(&schema, &empty_config());
        let lock = ClassificationLock::from_report(&report);
        let diff = diff_against_lock(&report, &lock);
        assert!(!diff.is_dirty());
    }

    #[test]
    fn lock_round_trips_through_yaml() {
        let schema = schema_with(vec![text_column("id"), text_column("email")]);
        let report = classify_schema(&schema, &empty_config());
        let lock = ClassificationLock::from_report(&report);

        let dir = std::env::temp_dir().join(format!("feint-classify-test-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("feint.lock.yaml");
        lock.save(&path).unwrap();
        let loaded = ClassificationLock::load(&path).unwrap().unwrap();
        assert_eq!(lock, loaded);
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn missing_lockfile_loads_as_none() {
        let path = std::env::temp_dir().join("feint-classify-does-not-exist.yaml");
        assert!(ClassificationLock::load(&path).unwrap().is_none());
    }
}
