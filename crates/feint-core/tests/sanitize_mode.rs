mod common;

use common::TestDb;
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;
use feint_core::sanitize::{self, ProgressEvent};
use std::collections::BTreeMap;

fn config_with(table: &str, columns: Vec<(&str, MaskStrategy)>) -> FeintConfig {
    let mut cols = BTreeMap::new();
    for (name, strategy) in columns {
        cols.insert(
            name.to_string(),
            ColumnConfig {
                generator: None,
                mask: Some(strategy),
            },
        );
    }
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
        seed: "default".to_string(),
        tables,
    }
}

fn no_progress(_event: ProgressEvent) {}

#[tokio::test]
async fn masks_across_many_batches_and_preserves_row_count() {
    let mut db = TestDb::setup(
        "sanitize_bulk",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;

    let values: Vec<String> = (0..237).map(|i| format!("('user{i}@corp.com')")).collect();
    db.client
        .batch_execute(&format!(
            "INSERT INTO users (email) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let schema = db.introspect().await;
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    };
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();
    assert_eq!(
        plan.tables.len(),
        1,
        "email should be auto-detected as sensitive"
    );

    let summary = sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        false,
        None,
        no_progress,
    )
    .await
    .unwrap();
    assert_eq!(summary.total_rows, 237);

    let count: i64 = db
        .client
        .query_one("SELECT count(*) FROM users", &[])
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, 237, "row count must be unchanged by masking");

    let still_original: i64 = db
        .client
        .query_one(
            "SELECT count(*) FROM users WHERE email LIKE '%@corp.com'",
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        still_original, 0,
        "every row's email must have been replaced"
    );
}

/// A completed mask run leaves its `_feint_mask_checkpoint` bookkeeping
/// table behind in the schema. Every other command re-introspects that
/// same schema afterward, so the checkpoint table must never show up as
/// user schema — `up` would otherwise generate garbage synthetic rows into
/// it, corrupting the checkpoint state undetected.
#[tokio::test]
async fn checkpoint_table_is_excluded_from_schema_introspection() {
    let mut db = TestDb::setup(
        "sanitize_checkpoint_hidden",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    db.client
        .batch_execute("INSERT INTO users (email) VALUES ('a@corp.com'), ('b@corp.com')")
        .await
        .unwrap();

    let schema = db.introspect().await;
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    };
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();
    sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        false,
        None,
        no_progress,
    )
    .await
    .unwrap();

    let checkpoint_exists: i64 = db
        .client
        .query_one(
            "SELECT count(*) FROM information_schema.tables \
             WHERE table_name = '_feint_mask_checkpoint' AND table_schema = $1",
            &[&db.schema_name],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        checkpoint_exists, 1,
        "sanity check: the checkpoint table must actually exist after a mask run"
    );

    let schema_after = db.introspect().await;
    assert!(
        schema_after
            .tables
            .iter()
            .all(|t| t.id.name != "_feint_mask_checkpoint"),
        "introspection must never surface feint's own checkpoint table as user schema"
    );
}

/// The core correctness property: after a genuinely partial run (stopped
/// honestly mid-way via `max_batches`, not simulated) followed by
/// `--resume`, every row — both the ones masked in the first session and
/// the ones masked in the second — must equal the single-pass expected
/// output. `hash` is the strategy that would expose a double-mask bug
/// (hashing an already-hashed value produces something that still looks
/// like a valid hash, but doesn't match the true single-pass hash of the
/// original value), unlike `fake`, which is accidentally safe either way
/// because it's keyed by primary key, not by value.
#[tokio::test]
async fn resume_after_partial_run_masks_each_row_exactly_once() {
    let mut db = TestDb::setup(
        "sanitize_resume",
        "CREATE TABLE notes (id serial PRIMARY KEY, note text NOT NULL);",
    )
    .await;

    let originals: Vec<String> = (0..50).map(|i| format!("original-note-{i}")).collect();
    let values: Vec<String> = originals.iter().map(|n| format!("('{n}')")).collect();
    db.client
        .batch_execute(&format!(
            "INSERT INTO notes (note) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let schema = db.introspect().await;
    let config = config_with(
        &format!("{}.notes", db.schema_name),
        vec![("note", MaskStrategy::Hash)],
    );
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();

    // Session 1: stop honestly after 2 batches of 10 rows (20 of 50 rows).
    let summary1 = sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        false,
        Some(2),
        no_progress,
    )
    .await
    .unwrap();
    assert_eq!(
        summary1.total_rows, 20,
        "session 1 should stop after exactly 2 batches"
    );

    let masked_after_session1: i64 = db
        .client
        .query_one("SELECT count(*) FROM notes WHERE note LIKE 'masked_%'", &[])
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        masked_after_session1, 20,
        "only the first 20 rows should be masked so far"
    );

    // Session 2: resume, must complete the remaining 30 rows.
    let summary2 = sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        true,
        None,
        no_progress,
    )
    .await
    .unwrap();
    assert_eq!(
        summary2.total_rows, 30,
        "session 2 should pick up exactly where session 1 left off"
    );

    // Every row, regardless of which session masked it, must equal the
    // true single-pass hash of its ORIGINAL value. If session 2 had
    // re-read and re-hashed any of session 1's rows, those rows would
    // show a hash-of-a-hash and fail this check.
    let rows = db
        .client
        .query("SELECT id, note FROM notes ORDER BY id", &[])
        .await
        .unwrap();
    assert_eq!(rows.len(), 50);
    for row in rows {
        let id: i32 = row.get(0);
        let note: String = row.get(1);
        let original = &originals[id as usize - 1];
        let expected_digest = blake3::hash(format!("default\0{original}").as_bytes());
        let expected = format!("masked_{}", &expected_digest.to_hex()[..24]);
        assert_eq!(
            note, expected,
            "row {id} does not match its single-pass expected hash"
        );
    }
}

#[tokio::test]
async fn fresh_run_rejects_when_progress_exists() {
    let mut db = TestDb::setup(
        "sanitize_fresh_rejects",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);",
    )
    .await;
    db.client
        .batch_execute("INSERT INTO users (email) VALUES ('a@corp.com'), ('b@corp.com');")
        .await
        .unwrap();

    let schema = db.introspect().await;
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    };
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();

    sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        false,
        None,
        no_progress,
    )
    .await
    .unwrap();

    let err = sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        10,
        false,
        None,
        no_progress,
    )
    .await
    .expect_err("a fresh run must refuse to start when checkpoint progress already exists");
    assert!(format!("{err}").contains("--resume"));
}

#[tokio::test]
async fn masking_key_column_is_rejected() {
    let db = TestDb::setup(
        "sanitize_mask_key_rejected",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL); \
         CREATE TABLE orders (id serial PRIMARY KEY, user_id integer NOT NULL REFERENCES users(id));",
    )
    .await;

    let schema = db.introspect().await;
    let config = config_with(
        &format!("{}.orders", db.schema_name),
        vec![("user_id", MaskStrategy::Fake)],
    );
    let err = sanitize::plan_sanitization(&schema, &config)
        .expect_err("masking an FK column must be rejected");
    assert!(format!("{err}").contains("user_id"));
}

#[tokio::test]
async fn table_without_primary_key_is_rejected_if_it_needs_masking() {
    let db = TestDb::setup(
        "sanitize_no_pk_rejected",
        "CREATE TABLE events (email text NOT NULL, payload text);",
    )
    .await;

    let schema = db.introspect().await;
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    };
    let err = sanitize::plan_sanitization(&schema, &config)
        .expect_err("a table with a sensitive column but no primary key must be rejected");
    assert!(format!("{err}").contains("primary key"));
}

#[tokio::test]
async fn null_values_stay_null_across_a_resumed_run() {
    let mut db = TestDb::setup(
        "sanitize_null_resume",
        "CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL, phone text);",
    )
    .await;
    let values: Vec<String> = (0..25)
        .map(|i| {
            if i % 5 == 0 {
                format!("('user{i}@corp.com', NULL)")
            } else {
                format!("('user{i}@corp.com', '555-{i:04}')")
            }
        })
        .collect();
    db.client
        .batch_execute(&format!(
            "INSERT INTO users (email, phone) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let schema = db.introspect().await;
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    };
    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();

    // Partial then resumed run, small batches, to exercise NULL handling
    // across the checkpoint boundary too, not just within one batch.
    sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        5,
        false,
        Some(2),
        no_progress,
    )
    .await
    .unwrap();
    sanitize::run_sanitization(
        &mut db.client,
        &schema,
        &plan,
        &config,
        5,
        true,
        None,
        no_progress,
    )
    .await
    .unwrap();

    let null_count: i64 = db
        .client
        .query_one("SELECT count(*) FROM users WHERE phone IS NULL", &[])
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        null_count, 5,
        "every originally-NULL phone must still be NULL after masking"
    );
}
