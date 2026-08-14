//! End-to-end proof that `feint policy apply` produces a config that
//! actually does something meaningful when fed to `feint mask`: it
//! upgrades weak defaults (a bare SSN column would otherwise fall back to
//! a generic fake-word replacement) to policy-appropriate ones (redact),
//! and two policies applied to the same config don't clobber each
//! other's already-set columns.

mod common;

use common::TestDb;
use feint_core::config::FeintConfig;
use feint_core::mask::MaskStrategy;
use feint_core::policy::{self, PolicyApplyReport};
use feint_core::sanitize::{self, ProgressEvent};

const CUSTOMERS_DDL: &str = "
    CREATE TABLE customers (
        id serial PRIMARY KEY,
        email text NOT NULL,
        ssn text,
        card_number text,
        notes text
    );
";

#[tokio::test]
async fn policy_apply_then_mask_upgrades_weak_defaults_and_stacks_without_clobbering() {
    let mut db = TestDb::setup("policy_apply", CUSTOMERS_DDL).await;
    db.client
        .batch_execute(
            "INSERT INTO customers (email, ssn, card_number, notes) VALUES \
             ('alice@corp.com', '123-45-6789', '4111111111111111', 'vip customer');",
        )
        .await
        .unwrap();

    let schema = db.introspect().await;
    let mut config = FeintConfig {
        version: 1,
        seed: "policy-test".to_string(),
        tables: Default::default(),
    };

    let PolicyApplyReport {
        applied: pii_applied,
        ..
    } = policy::apply_policy(&policy::PII, &schema, &mut config, false);
    let table_name = format!("{}.customers", db.schema_name);
    assert!(
        pii_applied
            .iter()
            .any(|(t, c, s)| t == &table_name && c == "ssn" && *s == MaskStrategy::Redact),
        "pii policy should set ssn to redact, got {pii_applied:?}"
    );
    assert!(
        pii_applied
            .iter()
            .any(|(t, c, s)| t == &table_name && c == "email" && *s == MaskStrategy::Fake),
        "pii policy should set email to fake, got {pii_applied:?}"
    );

    // payments also matches "email" — must not clobber the pii policy's
    // choice, since email already has an explicit mask set.
    let PolicyApplyReport {
        applied: payments_applied,
        skipped_existing,
        ..
    } = policy::apply_policy(&policy::PAYMENTS, &schema, &mut config, false);
    assert!(
        payments_applied
            .iter()
            .any(|(t, c, s)| t == &table_name && c == "card_number" && *s == MaskStrategy::Redact),
        "payments policy should set card_number to redact, got {payments_applied:?}"
    );
    assert!(
        skipped_existing
            .iter()
            .any(|(t, c)| t == &table_name && c == "email"),
        "payments policy must not clobber email, already set by pii"
    );
    assert_eq!(
        config.tables[&table_name].columns["email"]
            .generator
            .as_deref(),
        Some("email"),
        "email's generator must still be the pii policy's choice, not overwritten"
    );

    // Now actually run mask with the policy-produced config.
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();
    sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        100,
        false,
        None,
        |_: ProgressEvent| {},
    )
    .await
    .unwrap();

    let row = db
        .client
        .query_one("SELECT email, ssn, card_number, notes FROM customers", &[])
        .await
        .unwrap();
    let email: String = row.get(0);
    let ssn: Option<String> = row.get(1);
    let card_number: Option<String> = row.get(2);
    let notes: String = row.get(3);

    assert_ne!(email, "alice@corp.com", "email should have been faked");
    assert!(
        ssn.is_none(),
        "ssn is nullable, redact must null it out, got {ssn:?}"
    );
    assert!(
        card_number.is_none(),
        "card_number is nullable, redact must null it out, got {card_number:?}"
    );
    assert_eq!(
        notes, "vip customer",
        "notes never matched any policy rule, must pass through untouched"
    );
}
