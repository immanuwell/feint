//! Proves the post-mask verification pass both stays quiet on a clean
//! mask run and actually catches pipeline bugs: a corrupted hash format,
//! a redacted column that isn't really redacted, and every row's `fake`
//! value collapsing to the same value (the signature of a broken
//! per-row identity key).

mod common;

use common::TestDb;
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;
use feint_core::sanitize::{self, ProgressEvent};
use feint_core::verify;
use std::collections::BTreeMap;

const ACCOUNTS_DDL: &str = "
    CREATE TABLE accounts (
        id serial PRIMARY KEY,
        api_key text,
        notes text NOT NULL,
        email text NOT NULL
    );
";

fn config_for(table: &str) -> FeintConfig {
    let mut cols = BTreeMap::new();
    cols.insert(
        "api_key".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Hash),
        },
    );
    cols.insert(
        "notes".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Redact),
        },
    );
    cols.insert(
        "email".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Fake),
        },
    );
    let mut tables = BTreeMap::new();
    tables.insert(
        table.to_string(),
        TableConfig {
            rows: 0,
            strategy: Default::default(),
            columns: cols,
        },
    );
    FeintConfig {
        version: 1,
        seed: "verify-test".to_string(),
        tables,
    }
}

#[tokio::test]
async fn verification_is_clean_after_a_real_mask_run_and_catches_corruption_afterward() {
    let mut db = TestDb::setup("verify_masking", ACCOUNTS_DDL).await;
    db.client
        .batch_execute(
            "INSERT INTO accounts (api_key, notes, email) VALUES \
             ('key-alice', 'alice notes', 'alice@corp.com'), \
             ('key-bob', 'bob notes', 'bob@corp.com'), \
             ('key-carol', 'carol notes', 'carol@corp.com');",
        )
        .await
        .unwrap();

    let schema = db.introspect().await;
    let table = format!("{}.accounts", db.schema_name);
    let config = config_for(&table);
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

    let findings = verify::verify_masking(&db.client, &schema, &plan)
        .await
        .unwrap();
    assert!(
        findings.is_empty(),
        "a real mask run should verify clean, got {findings:?}"
    );

    // Simulate three independent pipeline bugs by corrupting the
    // already-masked data directly, then confirm verification catches
    // each one.
    db.client
        .batch_execute(&format!(
            "UPDATE \"{}\".accounts SET api_key = 'not-a-hash' WHERE api_key IS NOT NULL AND id = (SELECT min(id) FROM \"{}\".accounts);",
            db.schema_name, db.schema_name
        ))
        .await
        .unwrap();
    db.client
        .batch_execute(&format!(
            "UPDATE \"{}\".accounts SET notes = 'oops still real' WHERE id = (SELECT min(id) FROM \"{}\".accounts);",
            db.schema_name, db.schema_name
        ))
        .await
        .unwrap();
    db.client
        .batch_execute(&format!(
            "UPDATE \"{}\".accounts SET email = 'collapsed@corp.com';",
            db.schema_name
        ))
        .await
        .unwrap();

    let findings = verify::verify_masking(&db.client, &schema, &plan)
        .await
        .unwrap();
    assert_eq!(
        findings.len(),
        3,
        "expected one finding per corrupted column, got {findings:?}"
    );

    let by_column: BTreeMap<&str, &str> = findings
        .iter()
        .map(|f| (f.column.as_str(), f.issue.as_str()))
        .collect();
    assert!(by_column["api_key"].contains("hash format"));
    assert!(by_column["notes"].contains("redacted placeholder"));
    assert!(by_column["email"].contains("same fake value"));
}
