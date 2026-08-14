//! Best-effort migration from a Neosync Job export to `seedy.yaml`.
//!
//! Neosync has no static config file — jobs are configured through its
//! UI/API and stored server-side. This expects the JSON returned by its
//! API's `GetJob` call (a `mgmt.v1alpha1.Job` message serialized via
//! protojson), not a file most users would have lying around by default.
//! Field names and the transformer type list below come from that API's
//! own proto documentation (`mgmt/v1alpha1/job.proto` and
//! `transformer.proto`), retrieved via the Wayback Machine since the
//! hosted docs site is no longer live.

use std::collections::BTreeMap;

use serde::Deserialize;
use serde_json::Value;

use crate::config::{ColumnConfig, SeedyConfig, TableConfig, DEFAULT_ROWS, DEFAULT_SEED};
use crate::mask::MaskStrategy;
use crate::migrate::{ConversionConfidence, ConvertedColumn, MigrationReport, SkippedColumn};

#[derive(Debug, Deserialize, Default)]
struct Job {
    #[serde(default)]
    mappings: Vec<JobMapping>,
}

#[derive(Debug, Deserialize)]
struct JobWrapper {
    job: Job,
}

#[derive(Debug, Deserialize)]
struct JobMapping {
    schema: String,
    table: String,
    column: String,
    #[serde(default)]
    transformer: Option<JobMappingTransformer>,
}

#[derive(Debug, Deserialize)]
struct JobMappingTransformer {
    #[serde(default)]
    config: Option<Value>,
}

pub struct NeosyncMigration {
    pub config: SeedyConfig,
    pub report: MigrationReport,
}

/// Parse a Neosync `Job` export (or a `{"job": {...}}`-wrapped
/// `GetJobResponse`, tried as a fallback) and convert its column mappings
/// into `seedy.yaml` masking overrides.
pub fn migrate_neosync(job_json: &str) -> Result<NeosyncMigration, serde_json::Error> {
    let direct: Result<Job, _> = serde_json::from_str(job_json);
    let job = match direct {
        Ok(job) if !job.mappings.is_empty() => job,
        Ok(direct_empty) => {
            match serde_json::from_str::<JobWrapper>(job_json) {
                Ok(wrapped) => wrapped.job,
                Err(_) => direct_empty, // keep the (empty) direct parse; still a valid Job shape
            }
        }
        Err(direct_err) => match serde_json::from_str::<JobWrapper>(job_json) {
            Ok(wrapped) => wrapped.job,
            Err(_) => return Err(direct_err),
        },
    };

    let mut report = MigrationReport::default();
    let mut tables: BTreeMap<String, TableConfig> = BTreeMap::new();

    if job.mappings.is_empty() {
        report.general_notes.push(
            "No column mappings found. Make sure this is a Neosync Job export (a GetJob API \
             response) with a non-empty `mappings` array, not just job metadata."
                .to_string(),
        );
    }

    for mapping in &job.mappings {
        let table_key = format!("{}.{}", mapping.schema, mapping.table);
        let table_entry = tables
            .entry(table_key.clone())
            .or_insert_with(|| TableConfig {
                rows: DEFAULT_ROWS,
                columns: BTreeMap::new(),
            });

        let Some(config_key) = mapping
            .transformer
            .as_ref()
            .and_then(|t| t.config.as_ref())
            .and_then(|c| c.as_object())
            .and_then(|obj| obj.keys().next())
        else {
            continue; // no transformer set on this mapping; nothing to convert
        };

        match map_transformer(config_key) {
            Mapped::Exact { mask, generator } => {
                table_entry.columns.insert(
                    mapping.column.clone(),
                    ColumnConfig {
                        generator: generator.map(str::to_string),
                        mask: Some(mask),
                    },
                );
                report.converted.push(ConvertedColumn {
                    table: table_key,
                    column: mapping.column.clone(),
                    confidence: ConversionConfidence::Exact,
                    note: None,
                });
            }
            Mapped::Approximate {
                mask,
                generator,
                note,
            } => {
                table_entry.columns.insert(
                    mapping.column.clone(),
                    ColumnConfig {
                        generator: generator.map(str::to_string),
                        mask: Some(mask),
                    },
                );
                report.converted.push(ConvertedColumn {
                    table: table_key,
                    column: mapping.column.clone(),
                    confidence: ConversionConfidence::Approximate,
                    note: Some(note.to_string()),
                });
            }
            Mapped::Unsupported { note } => {
                report.skipped.push(SkippedColumn {
                    table: table_key,
                    column: mapping.column.clone(),
                    reason: format!("{config_key}: {note}"),
                });
            }
        }
    }

    Ok(NeosyncMigration {
        config: SeedyConfig {
            version: 1,
            seed: DEFAULT_SEED.to_string(),
            tables,
        },
        report,
    })
}

enum Mapped {
    Exact {
        mask: MaskStrategy,
        generator: Option<&'static str>,
    },
    Approximate {
        mask: MaskStrategy,
        generator: Option<&'static str>,
        note: &'static str,
    },
    Unsupported {
        note: &'static str,
    },
}

/// Map one `TransformerConfig` oneof case (the protojson field name that
/// was set, e.g. `generateEmailConfig`) to the closest seedy masking
/// strategy. The full case list comes straight from Neosync's own proto
/// docs for `mgmt.v1alpha1.TransformerConfig`.
fn map_transformer(config_key: &str) -> Mapped {
    match config_key {
        // Exact matches: seedy has the identical concept.
        "passthroughConfig" => Mapped::Exact {
            mask: MaskStrategy::None,
            generator: None,
        },
        "generateSha256HashConfig" | "generateSha256hashConfig" => Mapped::Exact {
            mask: MaskStrategy::Hash,
            generator: None,
        },

        // Exact matches: seedy has a purpose-built generator for this shape.
        "generateEmailConfig" | "transformEmailConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("email"),
        },
        "generateFirstNameConfig" | "transformFirstNameConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("first_name"),
        },
        "generateLastNameConfig" | "transformLastNameConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("last_name"),
        },
        "generateFullNameConfig" | "transformFullNameConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("person_name"),
        },
        "generateBoolConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("bool"),
        },
        "generateUuidConfig" | "transformUuidConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("uuid"),
        },
        "generateInt64Config" | "transformInt64Config" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("int8_range"),
        },
        "generateFloat64Config" | "transformFloat64Config" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("float8"),
        },
        "generateUtcTimestampConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("timestamptz"),
        },
        "generateStringConfig" | "transformStringConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("lorem_word"),
        },
        "generateIpAddressConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("inet"),
        },
        "generateE164PhoneNumberConfig"
        | "generateInt64PhoneNumberConfig"
        | "generateStringPhoneNumberConfig"
        | "transformE164PhoneNumberConfig"
        | "transformInt64PhoneNumberConfig"
        | "transformPhoneNumberConfig" => Mapped::Exact {
            mask: MaskStrategy::Fake,
            generator: Some("phone"),
        },

        // Approximate: closest seedy strategy, but the semantics differ
        // in a way worth flagging.
        "nullconfig" | "nullConfig" => Mapped::Approximate {
            mask: MaskStrategy::Redact,
            generator: None,
            note: "Neosync's Null transformer always writes NULL (and fails outright on a NOT \
                   NULL column there too); seedy's redact adapts, writing NULL on a nullable \
                   column or a fixed literal on a NOT NULL one.",
        },
        "generateCategoricalConfig" => Mapped::Approximate {
            mask: MaskStrategy::Fake,
            generator: None,
            note: "Neosync's categorical transformer picks from a defined value set; that set \
                   wasn't preserved here. Add an explicit `generator:` override, or restrict \
                   values by hand.",
        },
        "generateCardNumberConfig"
        | "generateSsnConfig"
        | "generateCityConfig"
        | "generateStateConfig"
        | "generateStreetAddressConfig"
        | "generateFullAddressConfig"
        | "generateZipcodeConfig"
        | "generateCountryConfig"
        | "generateGenderConfig"
        | "generateUsernameConfig"
        | "generateBusinessNameConfig"
        | "generateUnixTimestampConfig" => Mapped::Approximate {
            mask: MaskStrategy::Fake,
            generator: None,
            note: "seedy has no purpose-built generator matching this Neosync transformer yet; \
                   falls back to its generic type-based generator, which won't look like this \
                   specific data shape.",
        },

        // Unsupported: no seedy equivalent, or arbitrary code that can't
        // be mechanically converted.
        "generateDefaultConfig" => Mapped::Unsupported {
            note: "uses the column's own DEFAULT expression, which seedy has no equivalent for. \
                   Leave unmapped, or add an explicit override.",
        },
        "transformJavascriptConfig"
        | "generateJavascriptConfig"
        | "userDefinedTransformerConfig"
        | "transformCharacterScrambleConfig"
        | "transformPiiTextConfig" => Mapped::Unsupported {
            note: "custom code, ML-based, or user-defined transformer; not mechanically \
                   convertible. Review the original Neosync job and add a `generator:`/`mask:` \
                   override by hand.",
        },
        _ => Mapped::Unsupported {
            note: "unrecognized transformer type; not converted.",
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn job_json(mappings: &str) -> String {
        format!(r#"{{"mappings": [{mappings}]}}"#)
    }

    #[test]
    fn exact_matches_convert_with_mask_and_generator() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"email",
                "transformer":{"config":{"generateEmailConfig":{}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        let col = &migration.config.tables["public.users"].columns["email"];
        assert_eq!(col.mask, Some(MaskStrategy::Fake));
        assert_eq!(col.generator.as_deref(), Some("email"));
        assert_eq!(migration.report.converted.len(), 1);
        assert_eq!(
            migration.report.converted[0].confidence,
            ConversionConfidence::Exact
        );
    }

    #[test]
    fn sha256_hash_maps_to_hash_strategy() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"ssn",
                "transformer":{"config":{"generateSha256HashConfig":{}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        let col = &migration.config.tables["public.users"].columns["ssn"];
        assert_eq!(col.mask, Some(MaskStrategy::Hash));
    }

    #[test]
    fn passthrough_maps_to_none() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"country",
                "transformer":{"config":{"passthroughConfig":{}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        let col = &migration.config.tables["public.users"].columns["country"];
        assert_eq!(col.mask, Some(MaskStrategy::None));
    }

    #[test]
    fn custom_javascript_is_skipped_with_a_reason() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"weird_field",
                "transformer":{"config":{"transformJavascriptConfig":{"code":"return 1;"}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        assert!(!migration.config.tables["public.users"]
            .columns
            .contains_key("weird_field"));
        assert_eq!(migration.report.skipped.len(), 1);
        assert_eq!(migration.report.skipped[0].column, "weird_field");
    }

    #[test]
    fn approximate_matches_are_reported_with_a_note() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"city",
                "transformer":{"config":{"generateCityConfig":{}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        assert_eq!(migration.report.converted.len(), 1);
        assert_eq!(
            migration.report.converted[0].confidence,
            ConversionConfidence::Approximate
        );
        assert!(migration.report.converted[0].note.is_some());
    }

    #[test]
    fn wrapped_job_response_is_also_accepted() {
        let json = format!(
            r#"{{"job": {}}}"#,
            job_json(
                r#"{"schema":"public","table":"users","column":"email",
                    "transformer":{"config":{"generateEmailConfig":{}}}}"#
            )
        );
        let migration = migrate_neosync(&json).unwrap();
        assert_eq!(migration.report.converted.len(), 1);
    }

    #[test]
    fn empty_mappings_produce_a_general_note() {
        let migration = migrate_neosync(r#"{"mappings": []}"#).unwrap();
        assert!(migration.config.tables.is_empty());
        assert_eq!(migration.report.general_notes.len(), 1);
    }

    #[test]
    fn multiple_columns_group_under_one_table() {
        let json = job_json(
            r#"{"schema":"public","table":"users","column":"email",
                "transformer":{"config":{"generateEmailConfig":{}}}},
               {"schema":"public","table":"users","column":"phone",
                "transformer":{"config":{"generateE164PhoneNumberConfig":{}}}}"#,
        );
        let migration = migrate_neosync(&json).unwrap();
        assert_eq!(migration.config.tables.len(), 1);
        assert_eq!(migration.config.tables["public.users"].columns.len(), 2);
    }
}
