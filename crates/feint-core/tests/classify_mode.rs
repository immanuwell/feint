mod common;

use std::collections::BTreeMap;

use common::TestDb;
use feint_core::classify::{self, ClassificationLock};
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

/// A scratch lockfile path unique to this test process, so parallel tests
/// in this binary never clobber each other's file.
fn scratch_lockfile(name: &str) -> std::path::PathBuf {
    std::env::temp_dir().join(format!(
        "feint-classify-mode-test-{name}-{}.yaml",
        std::process::id()
    ))
}

#[tokio::test]
async fn real_schema_flags_sensitive_columns_and_excludes_keys() {
    let db = TestDb::setup(
        "classify_basic",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL, status text NOT NULL);",
    )
    .await;
    let schema = db.introspect().await;

    let report = classify::classify_schema(&schema, &empty_config());
    let email_key = format!("{}.users.email", db.schema_name);
    let status_key = format!("{}.users.status", db.schema_name);
    let id_key = format!("{}.users.id", db.schema_name);

    assert!(
        !report.columns.contains_key(&id_key),
        "primary key column must be excluded from classification"
    );

    let email = &report.columns[&email_key];
    assert!(email.sensitive);
    assert_eq!(email.strategy, MaskStrategy::Fake);

    let status = &report.columns[&status_key];
    assert!(!status.sensitive);
    assert_eq!(status.strategy, MaskStrategy::None);
}

#[tokio::test]
async fn lockfile_round_trips_and_matches_the_schema_it_was_written_from() {
    let db = TestDb::setup(
        "classify_lockfile_roundtrip",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    let schema = db.introspect().await;
    let config = empty_config();

    let report = classify::classify_schema(&schema, &config);
    let lock = ClassificationLock::from_report(&report);

    let path = scratch_lockfile("roundtrip");
    lock.save(&path).unwrap();
    let loaded = ClassificationLock::load(&path)
        .unwrap()
        .expect("lockfile exists");

    let schema_again = db.introspect().await;
    let report_again = classify::classify_schema(&schema_again, &config);
    let diff = classify::diff_against_lock(&report_again, &loaded);

    assert!(
        !diff.is_dirty(),
        "re-classifying the same, unchanged schema against its own lockfile must not drift"
    );
    std::fs::remove_file(&path).ok();
}

#[tokio::test]
async fn a_new_column_added_after_the_lockfile_was_written_shows_up_as_drift() {
    let db = TestDb::setup(
        "classify_new_column",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    let config = empty_config();

    let before = db.introspect().await;
    let lock = ClassificationLock::from_report(&classify::classify_schema(&before, &config));

    db.client
        .batch_execute("ALTER TABLE users ADD COLUMN ssn text")
        .await
        .unwrap();

    let after = db.introspect().await;
    let report = classify::classify_schema(&after, &config);
    let diff = classify::diff_against_lock(&report, &lock);

    assert!(diff.is_dirty());
    let ssn_key = format!("{}.users.ssn", db.schema_name);
    assert_eq!(diff.new_columns.len(), 1);
    assert_eq!(diff.new_columns[0].column, ssn_key);
    assert!(
        diff.new_columns[0].sensitive,
        "ssn must be flagged sensitive by the naming heuristic"
    );
    assert_eq!(diff.new_sensitive_count(), 1);
}

#[tokio::test]
async fn an_explicit_mask_none_override_on_a_sensitive_column_is_visible_in_the_report() {
    let db = TestDb::setup(
        "classify_override",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    let schema = db.introspect().await;

    // Config-key gotcha: table config must be keyed off the test's actual
    // schema-qualified name, never a hardcoded "public." prefix, or the
    // override silently fails to match and this test would pass for the
    // wrong reason.
    let table_key = format!("{}.users", db.schema_name);
    let mut tables = BTreeMap::new();
    tables.insert(
        table_key,
        TableConfig {
            rows: 0,
            strategy: Default::default(),
            columns: BTreeMap::from([(
                "email".to_string(),
                ColumnConfig {
                    generator: None,
                    mask: Some(MaskStrategy::None),
                },
            )]),
        },
    );
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    };

    let report = classify::classify_schema(&schema, &config);
    let email_key = format!("{}.users.email", db.schema_name);
    let entry = &report.columns[&email_key];

    // The heuristic still flags the column as sensitive by name even
    // though the override resolves it to `none` — this is exactly the
    // "acknowledged but unmasked" state the lockfile needs to capture, as
    // opposed to a column nobody ever looked at.
    assert!(entry.sensitive);
    assert_eq!(entry.strategy, MaskStrategy::None);
}

#[tokio::test]
async fn weakening_a_masked_column_to_none_is_caught_as_changed_drift() {
    let db = TestDb::setup(
        "classify_weakened",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    let schema = db.introspect().await;
    let table_key = format!("{}.users", db.schema_name);

    let hashed_config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::from([(
            table_key.clone(),
            TableConfig {
                rows: 0,
                strategy: Default::default(),
                columns: BTreeMap::from([(
                    "email".to_string(),
                    ColumnConfig {
                        generator: None,
                        mask: Some(MaskStrategy::Hash),
                    },
                )]),
            },
        )]),
    };
    let lock = ClassificationLock::from_report(&classify::classify_schema(&schema, &hashed_config));

    let downgraded_config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::from([(
            table_key,
            TableConfig {
                rows: 0,
                strategy: Default::default(),
                columns: BTreeMap::from([(
                    "email".to_string(),
                    ColumnConfig {
                        generator: None,
                        mask: Some(MaskStrategy::None),
                    },
                )]),
            },
        )]),
    };
    let report = classify::classify_schema(&schema, &downgraded_config);
    let diff = classify::diff_against_lock(&report, &lock);

    assert!(diff.is_dirty());
    assert!(
        diff.new_columns.is_empty(),
        "no column was added or removed"
    );
    assert_eq!(diff.changed_columns.len(), 1);
    assert_eq!(diff.changed_columns[0].old.strategy, MaskStrategy::Hash);
    assert_eq!(diff.changed_columns[0].new.strategy, MaskStrategy::None);
}
