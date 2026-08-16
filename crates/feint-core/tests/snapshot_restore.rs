mod common;

use std::collections::BTreeMap;

use common::CloneFixture;
use feint_core::config::{FeintConfig, TableConfig, TableStrategy};
use feint_core::graph::plan_insertion;
use feint_core::introspect::introspect;
use feint_core::snapshot::{self, SnapshotFile};
use feint_core::subset::{compute_subset, parse_root, SubsetOptions};
use feint_core::FeintError;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

fn temp_snapshot_path(name: &str) -> std::path::PathBuf {
    std::env::temp_dir().join(format!(
        "feint-snapshot-test-{name}-{}.bin",
        std::process::id()
    ))
}

const USERS_ORDERS_DDL: &str = "
    CREATE TABLE users (
        id serial PRIMARY KEY,
        email text NOT NULL UNIQUE
    );
    CREATE TABLE orders (
        id serial PRIMARY KEY,
        user_id integer NOT NULL REFERENCES users(id),
        total numeric(10,2) NOT NULL
    );
";

#[tokio::test]
async fn snapshot_then_restore_round_trips_masked_rows_through_a_real_file() {
    let mut db = CloneFixture::setup("snapshot_basic", USERS_ORDERS_DDL, USERS_ORDERS_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO users (email) VALUES ('alice@corp.com'), ('bob@corp.com'); \
             INSERT INTO orders (user_id, total) VALUES (1, 42.50), (1, 10.00), (2, 5.00);",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let captured = snapshot::capture(&source_txn, &schema, &config, None)
        .await
        .expect("capture should succeed");
    source_txn.rollback().await.ok();

    assert_eq!(captured.total_rows(), 5);
    assert_eq!(captured.table_count(), 2);

    let path = temp_snapshot_path("basic");
    captured.write_to_file(&path).expect("write snapshot file");

    // Everything from here on deliberately never touches `db.source_client`
    // again — the whole point of the feature is that restore needs no live
    // connection back to the source at all.
    let loaded = SnapshotFile::read_from_file(&path).expect("read snapshot file back");
    assert_eq!(loaded.total_rows(), 5);

    let target_schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&target_schema).unwrap();
    let target_txn = db.target_client.transaction().await.unwrap();
    let summary = snapshot::restore(&target_txn, &target_schema, &plan, &loaded)
        .await
        .expect("restore should succeed");
    target_txn.commit().await.unwrap();

    assert_eq!(summary.total_rows, 5);

    let schema_name = &db.schema_name;
    let row = db
        .target_client
        .query_one(
            &format!("SELECT email FROM \"{schema_name}\".users WHERE id = 1"),
            &[],
        )
        .await
        .unwrap();
    let email: String = row.get(0);
    assert_ne!(
        email, "alice@corp.com",
        "the snapshot must carry the already-masked value, not the real one"
    );

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

    let _ = std::fs::remove_file(&path);
}

#[tokio::test]
async fn backfill_cycle_round_trips_through_a_snapshot() {
    let ddl = "
        CREATE TABLE employees (
            id serial PRIMARY KEY,
            manager_id integer REFERENCES employees(id),
            title text NOT NULL
        );
    ";
    let mut db = CloneFixture::setup("snapshot_backfill", ddl, ddl).await;
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
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let captured = snapshot::capture(&source_txn, &schema, &config, None)
        .await
        .unwrap();
    source_txn.rollback().await.ok();

    let target_schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&target_schema).unwrap();
    let target_txn = db.target_client.transaction().await.unwrap();
    let summary = snapshot::restore(&target_txn, &target_schema, &plan, &captured)
        .await
        .expect("restore of a backfill-cycle table should succeed");
    target_txn.commit().await.unwrap();
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
        "the self-ref manager chain must survive the snapshot round trip exactly"
    );
}

#[tokio::test]
async fn generate_strategy_table_is_rejected_at_capture_time() {
    let mut db = CloneFixture::setup(
        "snapshot_generate_rejected",
        USERS_ORDERS_DDL,
        USERS_ORDERS_DDL,
    )
    .await;
    db.source_client
        .batch_execute("INSERT INTO users (email) VALUES ('a@corp.com');")
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let mut tables = BTreeMap::new();
    tables.insert(
        format!("{}.orders", db.schema_name),
        TableConfig {
            rows: 10,
            strategy: TableStrategy::Generate,
            columns: Default::default(),
            logical_foreign_keys: Default::default(),
        },
    );
    let config = FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    };

    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let err = snapshot::capture(&source_txn, &schema, &config, None)
        .await
        .expect_err("a strategy: generate table must be rejected at capture time");
    source_txn.rollback().await.ok();
    assert!(matches!(err, FeintError::Config(_)));
    assert!(format!("{err}").contains("orders"));
}

#[tokio::test]
async fn subsetting_composes_with_snapshot_capture() {
    let ddl = "
        CREATE TABLE orgs (id serial PRIMARY KEY, name text NOT NULL);
        CREATE TABLE users (
            id serial PRIMARY KEY,
            org_id integer NOT NULL REFERENCES orgs(id),
            email text NOT NULL
        );
    ";
    let mut db = CloneFixture::setup("snapshot_subset", ddl, ddl).await;
    db.source_client
        .batch_execute(
            "INSERT INTO orgs (name) VALUES ('kept'), ('dropped'); \
             INSERT INTO users (org_id, email) VALUES (1, 'a@corp.com'), (1, 'b@corp.com'), (2, 'c@corp.com');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let parsed = parse_root(&schema, "orgs WHERE id = 1").unwrap();
    let subset = compute_subset(&source_txn, &schema, &parsed, &SubsetOptions::default())
        .await
        .unwrap();
    let captured = snapshot::capture(&source_txn, &schema, &config, Some(&subset))
        .await
        .unwrap();
    source_txn.rollback().await.ok();

    assert_eq!(
        captured.total_rows(),
        3,
        "1 org + 2 of its users, not org 2 or its user"
    );

    let target_schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&target_schema).unwrap();
    let target_txn = db.target_client.transaction().await.unwrap();
    snapshot::restore(&target_txn, &target_schema, &plan, &captured)
        .await
        .unwrap();
    target_txn.commit().await.unwrap();

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
}

#[tokio::test]
async fn restore_rejects_a_schema_that_drifted_since_capture() {
    let source_ddl =
        "CREATE TABLE widgets (id serial PRIMARY KEY, name text NOT NULL, color text NOT NULL);";
    let target_ddl = "CREATE TABLE widgets (id serial PRIMARY KEY, name text NOT NULL);";
    let mut db = CloneFixture::setup("snapshot_schema_drift", source_ddl, target_ddl).await;
    db.source_client
        .batch_execute("INSERT INTO widgets (name, color) VALUES ('gizmo', 'red');")
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let captured = snapshot::capture(&source_txn, &schema, &config, None)
        .await
        .unwrap();
    source_txn.rollback().await.ok();

    // Target's `widgets` has no `color` column — the schema drifted since
    // the snapshot was captured.
    let target_schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&target_schema).unwrap();
    let target_txn = db.target_client.transaction().await.unwrap();
    let err = snapshot::restore(&target_txn, &target_schema, &plan, &captured)
        .await
        .expect_err(
            "restoring into a drifted target schema must be rejected, not silently guessed at",
        );
    target_txn.rollback().await.ok();
    assert!(matches!(err, FeintError::Config(_)));
    let message = format!("{err}");
    assert!(message.contains("widgets"), "message: {message}");

    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{}\".widgets", db.schema_name),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, 0, "rejected restore must not write anything");
}
