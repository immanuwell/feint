mod common;

use common::CloneFixture;
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;
use feint_core::FeintError;
use std::collections::BTreeMap;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

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

const USERS_ORDERS_DDL: &str = "
    CREATE TABLE users (
        id serial PRIMARY KEY,
        email text NOT NULL UNIQUE,
        name text NOT NULL,
        phone text,
        notes text
    );
    CREATE TABLE orders (
        id serial PRIMARY KEY,
        user_id integer NOT NULL REFERENCES users(id),
        total numeric(10,2) NOT NULL
    );
";

#[tokio::test]
async fn full_unmasked_clone_preserves_keys_and_resyncs_sequences() {
    let mut db = CloneFixture::setup("full_unmasked", USERS_ORDERS_DDL, USERS_ORDERS_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO users (email, name, phone, notes) VALUES \
                ('alice@corp.com', 'Alice', '555-0100', 'vip'), \
                ('bob@corp.com', 'Bob', NULL, NULL); \
             INSERT INTO orders (user_id, total) VALUES (1, 42.50), (1, 10.00), (2, 5.00);",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let summary = db
        .clone(&schema, &config)
        .await
        .expect("clone should succeed");
    assert_eq!(summary.total_rows, 5);

    let schema_name = &db.schema_name;
    let users: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".users"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(users, 2);

    // PKs preserved exactly. Alice (id=1) has a non-null phone in source;
    // email/phone are classify_sensitive-flagged and default to fake, so
    // they must differ from source, while notes isn't flagged and must
    // pass through unchanged.
    let row = db
        .target_client
        .query_one(
            &format!("SELECT email, phone, notes FROM \"{schema_name}\".users WHERE id = 1"),
            &[],
        )
        .await
        .unwrap();
    let email: String = row.get(0);
    let phone: Option<String> = row.get(1);
    let notes: Option<String> = row.get(2);
    assert_ne!(email, "alice@corp.com");
    assert_ne!(phone, Some("555-0100".to_string()));
    assert_eq!(notes, Some("vip".to_string()));

    // Bob (id=2) has a NULL phone and NULL notes in source — both must
    // stay NULL on the target, regardless of masking strategy.
    let bob_row = db
        .target_client
        .query_one(
            &format!("SELECT phone, notes FROM \"{schema_name}\".users WHERE id = 2"),
            &[],
        )
        .await
        .unwrap();
    let bob_phone: Option<String> = bob_row.get(0);
    let bob_notes: Option<String> = bob_row.get(1);
    assert_eq!(
        bob_phone, None,
        "NULL must pass through even under fake masking"
    );
    assert_eq!(bob_notes, None);

    // FK integrity.
    let orphans: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".orders o \
                 LEFT JOIN \"{schema_name}\".users u ON o.user_id = u.id WHERE u.id IS NULL"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(orphans, 0);

    // Sequence resync: a fresh insert without an explicit id must not
    // collide with the preserved ids (1, 2).
    let new_id: i32 = db
        .target_client
        .query_one(
            &format!(
                "INSERT INTO \"{schema_name}\".users (email, name) VALUES ('new@corp.com', 'New') RETURNING id"
            ),
            &[],
        )
        .await
        .expect("sequence should be resynced past the cloned ids")
        .get(0);
    assert_eq!(new_id, 3);
}

#[tokio::test]
async fn masked_clone_applies_each_strategy() {
    let mut db = CloneFixture::setup("masked_strategies", USERS_ORDERS_DDL, USERS_ORDERS_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO users (email, name, phone, notes) VALUES ('carol@corp.com', 'Carol', '555-0102', 'secret'); \
             INSERT INTO orders (user_id, total) VALUES (1, 1.00);",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = config_with(
        &format!("{}.users", db.schema_name),
        vec![
            ("email", MaskStrategy::Hash),
            ("phone", MaskStrategy::Redact),
            ("name", MaskStrategy::None),
        ],
    );
    db.clone(&schema, &config)
        .await
        .expect("clone should succeed");

    let schema_name = &db.schema_name;
    let row = db
        .target_client
        .query_one(
            &format!("SELECT email, name, phone FROM \"{schema_name}\".users WHERE id = 1"),
            &[],
        )
        .await
        .unwrap();
    let email: String = row.get(0);
    let name: String = row.get(1);
    let phone: Option<String> = row.get(2);

    assert!(
        email.starts_with("masked_"),
        "expected a hash-masked email, got {email}"
    );
    assert_eq!(name, "Carol", "mask: none must pass the real value through");
    assert_eq!(phone, None, "redact on a nullable column masks to NULL");
}

#[tokio::test]
async fn masking_key_column_is_rejected() {
    let mut db = CloneFixture::setup("mask_key_rejected", USERS_ORDERS_DDL, USERS_ORDERS_DDL).await;
    let schema = db.introspect_source().await;
    let config = config_with(
        &format!("{}.orders", db.schema_name),
        vec![("user_id", MaskStrategy::Fake)],
    );

    let err = db
        .clone(&schema, &config)
        .await
        .expect_err("masking an FK column must be rejected");
    assert!(matches!(err, FeintError::Config(_)));
    assert!(format!("{err}").contains("user_id"));

    // Nothing should have been written to target.
    let schema_name = &db.schema_name;
    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".users"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, 0);
}

#[tokio::test]
async fn redact_on_unique_non_pk_column_is_rejected() {
    let mut db =
        CloneFixture::setup("redact_unique_rejected", USERS_ORDERS_DDL, USERS_ORDERS_DDL).await;
    let schema = db.introspect_source().await;
    let config = config_with(
        &format!("{}.users", db.schema_name),
        vec![("email", MaskStrategy::Redact)],
    );

    let err = db
        .clone(&schema, &config)
        .await
        .expect_err("redact on a unique column must be rejected");
    assert!(matches!(err, FeintError::Config(_)));
}

#[tokio::test]
async fn hash_on_non_text_column_is_rejected() {
    let ddl = "CREATE TABLE amounts (id serial PRIMARY KEY, value numeric(10,2) NOT NULL);";
    let mut db = CloneFixture::setup("hash_non_text_rejected", ddl, ddl).await;
    let schema = db.introspect_source().await;
    let config = config_with(
        &format!("{}.amounts", db.schema_name),
        vec![("value", MaskStrategy::Hash)],
    );

    let err = db
        .clone(&schema, &config)
        .await
        .expect_err("hash on a numeric column must be rejected");
    assert!(matches!(err, FeintError::Config(_)));
}

#[tokio::test]
async fn backfill_cycle_table_clones_correctly() {
    let ddl = "
        CREATE TABLE employees (
            id serial PRIMARY KEY,
            manager_id integer REFERENCES employees(id),
            title text NOT NULL
        );
    ";
    let mut db = CloneFixture::setup("clone_backfill", ddl, ddl).await;
    db.source_client
        .batch_execute(
            "INSERT INTO employees (manager_id, title) VALUES (NULL, 'CEO'); \
             INSERT INTO employees (manager_id, title) VALUES (1, 'Manager'); \
             INSERT INTO employees (manager_id, title) VALUES (2, 'Report');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let summary = db
        .clone(&schema, &config)
        .await
        .expect("clone should succeed");
    assert_eq!(summary.total_rows, 3);

    let schema_name = &db.schema_name;
    let rows = db
        .target_client
        .query(
            &format!("SELECT id, manager_id FROM \"{schema_name}\".employees ORDER BY id"),
            &[],
        )
        .await
        .unwrap();
    let managers: Vec<Option<i32>> = rows.iter().map(|r| r.get(1)).collect();
    assert_eq!(
        managers,
        vec![None, Some(1), Some(2)],
        "self-ref chain must be preserved exactly"
    );

    let orphans: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".employees e \
                 LEFT JOIN \"{schema_name}\".employees m ON e.manager_id = m.id \
                 WHERE e.manager_id IS NOT NULL AND m.id IS NULL"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(orphans, 0);
}

#[tokio::test]
async fn identity_always_column_preserves_values_and_resyncs() {
    let ddl = "
        CREATE TABLE tickets (
            id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            title text NOT NULL
        );
    ";
    let mut db = CloneFixture::setup("clone_identity_always", ddl, ddl).await;
    db.source_client
        .batch_execute("INSERT INTO tickets (title) VALUES ('First'), ('Second');")
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    db.clone(&schema, &config)
        .await
        .expect("clone should succeed (OVERRIDING SYSTEM VALUE)");

    let schema_name = &db.schema_name;
    let rows = db
        .target_client
        .query(
            &format!("SELECT id, title FROM \"{schema_name}\".tickets ORDER BY id"),
            &[],
        )
        .await
        .unwrap();
    let ids: Vec<i32> = rows.iter().map(|r| r.get(0)).collect();
    assert_eq!(
        ids,
        vec![1, 2],
        "identity-always ids must be preserved from source"
    );

    let new_id: i32 = db
        .target_client
        .query_one(
            &format!("INSERT INTO \"{schema_name}\".tickets (title) VALUES ('Third') RETURNING id"),
            &[],
        )
        .await
        .expect("identity sequence should be resynced past the cloned ids")
        .get(0);
    assert_eq!(new_id, 3);
}
