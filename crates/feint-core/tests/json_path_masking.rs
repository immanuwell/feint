mod common;

use std::collections::BTreeMap;

use common::{CloneFixture, TestDb};
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::{JsonPathRules, MaskStrategy};
use feint_core::sanitize::{self, ProgressEvent};

fn config_with_json_paths(table: &str, column: &str, paths: JsonPathRules) -> FeintConfig {
    let mut cols = BTreeMap::new();
    cols.insert(
        column.to_string(),
        ColumnConfig {
            generator: None,
            mask: None,
            json_paths: paths,
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
        seed: "default".to_string(),
        tables,
    }
}

fn no_progress(_event: ProgressEvent) {}

#[tokio::test]
async fn mask_in_place_only_touches_configured_json_paths() {
    let mut db = TestDb::setup(
        "json_path_sanitize",
        "CREATE TABLE users (id serial PRIMARY KEY, profile jsonb);",
    )
    .await;
    db.client
        .batch_execute(
            "INSERT INTO users (profile) VALUES \
             ('{\"bio\": \"loves hiking\", \"contact\": {\"email\": \"a@corp.com\", \"phone\": \"555-1000\"}}'), \
             ('{\"bio\": \"builds things\", \"contact\": {\"email\": \"b@corp.com\", \"phone\": \"555-2000\"}}'), \
             ('{\"bio\": \"no contact block\"}')",
        )
        .await
        .unwrap();

    let schema = db.introspect().await;
    let mut paths = JsonPathRules::new();
    paths.insert("contact.email".to_string(), MaskStrategy::Redact);
    let config = config_with_json_paths(&format!("{}.users", db.schema_name), "profile", paths);

    let plan = sanitize::plan_sanitization(&schema, &config).unwrap();
    assert_eq!(
        plan.tables.len(),
        1,
        "a json_paths-only column must still show up in the plan"
    );

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

    let rows = db
        .client
        .query("SELECT profile FROM users ORDER BY id", &[])
        .await
        .unwrap();
    assert_eq!(rows.len(), 3);

    let p0: serde_json::Value = rows[0].get(0);
    assert_eq!(p0["bio"], serde_json::json!("loves hiking"));
    assert_eq!(p0["contact"]["phone"], serde_json::json!("555-1000"));
    assert_eq!(p0["contact"]["email"], serde_json::Value::Null);

    let p1: serde_json::Value = rows[1].get(0);
    assert_eq!(p1["contact"]["phone"], serde_json::json!("555-2000"));
    assert_eq!(p1["contact"]["email"], serde_json::Value::Null);

    // Row with no "contact" object at all must survive untouched, not error.
    let p2: serde_json::Value = rows[2].get(0);
    assert_eq!(p2, serde_json::json!({ "bio": "no contact block" }));
}

#[tokio::test]
async fn clone_masks_json_paths_and_preserves_the_rest_of_the_document() {
    let ddl = "CREATE TABLE accounts (id serial PRIMARY KEY, settings jsonb);";
    let mut db = CloneFixture::setup("json_path_clone", ddl, ddl).await;
    db.source_client
        .batch_execute(
            "INSERT INTO accounts (settings) VALUES \
             ('{\"theme\": \"dark\", \"owner\": {\"ssn\": \"123-45-6789\", \"name\": \"Alice\"}}')",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let mut paths = JsonPathRules::new();
    paths.insert("owner.ssn".to_string(), MaskStrategy::Hash);
    let config = config_with_json_paths(&format!("{}.accounts", db.schema_name), "settings", paths);

    db.clone(&schema, &config).await.unwrap();

    let schema_name = &db.schema_name;
    let row = db
        .target_client
        .query_one(
            &format!("SELECT settings FROM \"{schema_name}\".accounts"),
            &[],
        )
        .await
        .unwrap();
    let settings: serde_json::Value = row.get(0);
    assert_eq!(settings["theme"], serde_json::json!("dark"));
    assert_eq!(settings["owner"]["name"], serde_json::json!("Alice"));
    let ssn = settings["owner"]["ssn"].as_str().unwrap();
    assert!(ssn.starts_with("masked_"));
    assert_ne!(ssn, "123-45-6789");
}

#[tokio::test]
async fn json_paths_and_whole_column_mask_together_is_rejected() {
    let db = TestDb::setup(
        "json_path_conflict_rejected",
        "CREATE TABLE users (id serial PRIMARY KEY, profile jsonb);",
    )
    .await;
    let schema = db.introspect().await;

    let mut cols = BTreeMap::new();
    cols.insert(
        "profile".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Hash),
            json_paths: JsonPathRules::from([("a".to_string(), MaskStrategy::Redact)]),
        },
    );
    let mut tables = BTreeMap::new();
    tables.insert(
        format!("{}.users", db.schema_name),
        TableConfig {
            rows: 0,
            strategy: Default::default(),
            columns: cols,
        },
    );
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    };

    let err = sanitize::plan_sanitization(&schema, &config)
        .expect_err("mask: and json_paths: together on one column must be rejected");
    assert!(format!("{err}").contains("both `mask:` and `json_paths:`"));
}

#[tokio::test]
async fn json_paths_on_a_non_json_column_is_rejected() {
    let db = TestDb::setup(
        "json_path_wrong_type_rejected",
        "CREATE TABLE users (id serial PRIMARY KEY, bio text);",
    )
    .await;
    let schema = db.introspect().await;
    let config = config_with_json_paths(
        &format!("{}.users", db.schema_name),
        "bio",
        JsonPathRules::from([("a".to_string(), MaskStrategy::Redact)]),
    );

    let err = sanitize::plan_sanitization(&schema, &config)
        .expect_err("json_paths on a non-json column must be rejected");
    assert!(format!("{err}").contains("not `json`/`jsonb`"));
}
