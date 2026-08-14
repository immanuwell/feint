//! Prebuilt masking policy templates: ready-made column-name-to-strategy
//! bundles for common data domains, so a new user can apply one instead
//! of writing every `mask:` override in `feint.yaml` by hand.
//!
//! A policy is a purely additive suggestion. [`apply_policy`] never
//! touches a primary-key or foreign-key column (same rule as everywhere
//! else in masking), and never overwrites a column that already has an
//! explicit `mask:` override unless the caller passes `force`.

use crate::config::{ColumnConfig, FeintConfig, TableConfig, DEFAULT_ROWS};
use crate::introspect::Schema;
use crate::mask::{is_key_column, MaskStrategy};

pub struct PolicyRule {
    /// Case-insensitive substring match against the column name. Rules
    /// are checked in order; the first match wins, so put more specific
    /// patterns (`first_name`) before broader ones (`name`).
    pub pattern: &'static str,
    pub strategy: MaskStrategy,
    pub generator: Option<&'static str>,
}

pub struct Policy {
    pub name: &'static str,
    pub description: &'static str,
    pub rules: &'static [PolicyRule],
}

pub const PII: Policy = Policy {
    name: "pii",
    description: "General personal-identifiable information: names, contact details, government IDs, dates of birth, addresses.",
    rules: &[
        PolicyRule { pattern: "email", strategy: MaskStrategy::Fake, generator: Some("email") },
        PolicyRule { pattern: "phone", strategy: MaskStrategy::Fake, generator: Some("phone") },
        PolicyRule { pattern: "first_name", strategy: MaskStrategy::Fake, generator: Some("first_name") },
        PolicyRule { pattern: "last_name", strategy: MaskStrategy::Fake, generator: Some("last_name") },
        PolicyRule { pattern: "surname", strategy: MaskStrategy::Fake, generator: Some("last_name") },
        PolicyRule { pattern: "full_name", strategy: MaskStrategy::Fake, generator: Some("person_name") },
        PolicyRule { pattern: "name", strategy: MaskStrategy::Fake, generator: Some("person_name") },
        PolicyRule { pattern: "social_security", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "ssn", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "passport", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "national_id", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "license", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "date_of_birth", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "birth_date", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "dob", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "street", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "address", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "ip_address", strategy: MaskStrategy::Fake, generator: Some("inet") },
    ],
};

pub const HEALTHCARE: Policy = Policy {
    name: "healthcare",
    description: "Medical and insurance data: record numbers, diagnoses, medications, patient identity, policy numbers.",
    rules: &[
        PolicyRule { pattern: "medical_record", strategy: MaskStrategy::Hash, generator: None },
        PolicyRule { pattern: "mrn", strategy: MaskStrategy::Hash, generator: None },
        PolicyRule { pattern: "diagnosis", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "icd_code", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "condition", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "prescription", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "medication", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "policy_number", strategy: MaskStrategy::Hash, generator: None },
        PolicyRule { pattern: "insurance_id", strategy: MaskStrategy::Hash, generator: None },
        PolicyRule { pattern: "patient_name", strategy: MaskStrategy::Fake, generator: Some("person_name") },
        PolicyRule { pattern: "subscriber_name", strategy: MaskStrategy::Fake, generator: Some("person_name") },
        PolicyRule { pattern: "first_name", strategy: MaskStrategy::Fake, generator: Some("first_name") },
        PolicyRule { pattern: "last_name", strategy: MaskStrategy::Fake, generator: Some("last_name") },
        PolicyRule { pattern: "date_of_birth", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "birth_date", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "dob", strategy: MaskStrategy::Fake, generator: Some("date") },
        PolicyRule { pattern: "ssn", strategy: MaskStrategy::Redact, generator: None },
        PolicyRule { pattern: "email", strategy: MaskStrategy::Fake, generator: Some("email") },
        PolicyRule { pattern: "phone", strategy: MaskStrategy::Fake, generator: Some("phone") },
    ],
};

pub const PAYMENTS: Policy = Policy {
    name: "payments",
    description:
        "Card and bank data: card numbers, CVVs, account and routing numbers, cardholder identity.",
    rules: &[
        PolicyRule {
            pattern: "card_number",
            strategy: MaskStrategy::Redact,
            generator: None,
        },
        PolicyRule {
            pattern: "card_last4",
            strategy: MaskStrategy::Redact,
            generator: None,
        },
        PolicyRule {
            pattern: "cvv",
            strategy: MaskStrategy::Redact,
            generator: None,
        },
        PolicyRule {
            pattern: "security_code",
            strategy: MaskStrategy::Redact,
            generator: None,
        },
        PolicyRule {
            pattern: "card",
            strategy: MaskStrategy::Redact,
            generator: None,
        },
        PolicyRule {
            pattern: "iban",
            strategy: MaskStrategy::Hash,
            generator: None,
        },
        PolicyRule {
            pattern: "account_number",
            strategy: MaskStrategy::Hash,
            generator: None,
        },
        PolicyRule {
            pattern: "routing_number",
            strategy: MaskStrategy::Hash,
            generator: None,
        },
        PolicyRule {
            pattern: "cardholder_name",
            strategy: MaskStrategy::Fake,
            generator: Some("person_name"),
        },
        PolicyRule {
            pattern: "billing_name",
            strategy: MaskStrategy::Fake,
            generator: Some("person_name"),
        },
        PolicyRule {
            pattern: "billing_email",
            strategy: MaskStrategy::Fake,
            generator: Some("email"),
        },
        PolicyRule {
            pattern: "billing_phone",
            strategy: MaskStrategy::Fake,
            generator: Some("phone"),
        },
        PolicyRule {
            pattern: "email",
            strategy: MaskStrategy::Fake,
            generator: Some("email"),
        },
        PolicyRule {
            pattern: "phone",
            strategy: MaskStrategy::Fake,
            generator: Some("phone"),
        },
    ],
};

pub const POLICIES: &[Policy] = &[PII, HEALTHCARE, PAYMENTS];

#[derive(Debug, Default)]
pub struct PolicyApplyReport {
    pub applied: Vec<(String, String, MaskStrategy)>,
    pub skipped_existing: Vec<(String, String)>,
    pub skipped_key: Vec<(String, String)>,
}

fn match_rule<'a>(policy: &'a Policy, column_name: &str) -> Option<&'a PolicyRule> {
    let n = column_name.to_ascii_lowercase();
    policy.rules.iter().find(|r| n.contains(r.pattern))
}

/// Apply `policy` to every column in `schema` whose name matches one of
/// its rules, writing `mask:`/`generator:` into `config`. Never touches a
/// primary-key or foreign-key column. Never overwrites a column that
/// already has an explicit `mask:` set, unless `force` is true.
pub fn apply_policy(
    policy: &Policy,
    schema: &Schema,
    config: &mut FeintConfig,
    force: bool,
) -> PolicyApplyReport {
    let mut report = PolicyApplyReport::default();
    for table in &schema.tables {
        let table_name = table.id.qualified();
        for column in &table.columns {
            let Some(rule) = match_rule(policy, &column.name) else {
                continue;
            };
            if is_key_column(table, &column.name) {
                report
                    .skipped_key
                    .push((table_name.clone(), column.name.clone()));
                continue;
            }

            let table_entry =
                config
                    .tables
                    .entry(table_name.clone())
                    .or_insert_with(|| TableConfig {
                        rows: DEFAULT_ROWS,
                        columns: Default::default(),
                    });
            let has_existing_mask = table_entry
                .columns
                .get(&column.name)
                .is_some_and(|c| c.mask.is_some());
            if has_existing_mask && !force {
                report
                    .skipped_existing
                    .push((table_name.clone(), column.name.clone()));
                continue;
            }

            table_entry.columns.insert(
                column.name.clone(),
                ColumnConfig {
                    generator: rule.generator.map(str::to_string),
                    mask: Some(rule.strategy),
                },
            );
            report
                .applied
                .push((table_name.clone(), column.name.clone(), rule.strategy));
        }
    }
    report
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Column, ForeignKey, Table, TableId, TypeKind};
    use std::collections::BTreeMap;

    fn text_column(name: &str) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "text".to_string(),
            type_kind: TypeKind::Scalar,
            nullable: true,
            identity: crate::introspect::Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    fn schema_with(
        table_name: &str,
        columns: Vec<Column>,
        primary_key: Option<Vec<String>>,
    ) -> Schema {
        Schema {
            tables: vec![Table {
                id: TableId {
                    schema: "public".to_string(),
                    name: table_name.to_string(),
                },
                columns,
                primary_key,
                foreign_keys: vec![],
                unique_constraints: vec![],
                check_constraints: vec![],
            }],
        }
    }

    fn empty_config() -> FeintConfig {
        FeintConfig {
            version: 1,
            seed: "default".to_string(),
            tables: BTreeMap::new(),
        }
    }

    #[test]
    fn pii_policy_matches_email_ssn_and_name_columns() {
        let schema = schema_with(
            "users",
            vec![
                text_column("id"),
                text_column("email"),
                text_column("ssn"),
                text_column("first_name"),
                text_column("status"),
            ],
            Some(vec!["id".to_string()]),
        );
        let mut config = empty_config();
        let report = apply_policy(&PII, &schema, &mut config, false);

        let applied: BTreeMap<_, _> = report
            .applied
            .iter()
            .map(|(_, col, strategy)| (col.clone(), *strategy))
            .collect();
        assert_eq!(applied.get("email"), Some(&MaskStrategy::Fake));
        assert_eq!(applied.get("ssn"), Some(&MaskStrategy::Redact));
        assert_eq!(applied.get("first_name"), Some(&MaskStrategy::Fake));
        assert!(
            !applied.contains_key("status"),
            "status doesn't look sensitive, should not match"
        );
        assert!(
            !applied.contains_key("id"),
            "id is the primary key, must never be matched"
        );
    }

    #[test]
    fn key_columns_are_never_matched_even_if_the_name_looks_sensitive() {
        let email_fk = text_column("email_id");
        let schema = Schema {
            tables: vec![Table {
                id: TableId {
                    schema: "public".to_string(),
                    name: "orders".to_string(),
                },
                columns: vec![email_fk],
                primary_key: None,
                foreign_keys: vec![ForeignKey {
                    name: "orders_email_id_fkey".to_string(),
                    columns: vec!["email_id".to_string()],
                    ref_table: TableId {
                        schema: "public".to_string(),
                        name: "emails".to_string(),
                    },
                    ref_columns: vec!["id".to_string()],
                    deferrable: false,
                    initially_deferred: false,
                }],
                unique_constraints: vec![],
                check_constraints: vec![],
            }],
        };
        let mut config = empty_config();
        let report = apply_policy(&PII, &schema, &mut config, false);
        assert!(report.applied.is_empty());
        assert_eq!(report.skipped_key.len(), 1);
    }

    #[test]
    fn existing_explicit_override_is_preserved_unless_forced() {
        let schema = schema_with(
            "users",
            vec![text_column("id"), text_column("email")],
            Some(vec!["id".to_string()]),
        );
        let mut config = empty_config();
        config.tables.insert(
            "public.users".to_string(),
            TableConfig {
                rows: DEFAULT_ROWS,
                columns: BTreeMap::from([(
                    "email".to_string(),
                    ColumnConfig {
                        generator: None,
                        mask: Some(MaskStrategy::None),
                    },
                )]),
            },
        );

        let report = apply_policy(&PII, &schema, &mut config, false);
        assert!(report.applied.is_empty());
        assert_eq!(report.skipped_existing.len(), 1);
        assert_eq!(
            config.tables["public.users"].columns["email"].mask,
            Some(MaskStrategy::None)
        );

        let report = apply_policy(&PII, &schema, &mut config, true);
        assert_eq!(report.applied.len(), 1);
        assert_eq!(
            config.tables["public.users"].columns["email"].mask,
            Some(MaskStrategy::Fake)
        );
    }

    #[test]
    fn healthcare_and_payments_policies_have_distinct_rules() {
        assert!(match_rule(&HEALTHCARE, "medical_record_number").is_some());
        assert!(match_rule(&HEALTHCARE, "diagnosis_code").is_some());
        assert!(match_rule(&PAYMENTS, "card_number").is_some());
        assert!(match_rule(&PAYMENTS, "routing_number").is_some());
        assert_eq!(
            match_rule(&PAYMENTS, "card_number").unwrap().strategy,
            MaskStrategy::Redact
        );
        assert_eq!(
            match_rule(&PAYMENTS, "routing_number").unwrap().strategy,
            MaskStrategy::Hash
        );
    }
}
