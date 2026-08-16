mod common;

use std::collections::BTreeMap;

use common::CloneFixture;
use feint_core::config::{FeintConfig, TableConfig};
use feint_core::graph::plan_insertion;
use feint_core::insert;
use feint_core::introspect::introspect;
use feint_core::profile;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

fn config_with_rows(table: &str, rows: u32) -> FeintConfig {
    let mut tables = BTreeMap::new();
    tables.insert(
        table.to_string(),
        TableConfig {
            rows,
            strategy: Default::default(),
            columns: Default::default(),
            logical_foreign_keys: Default::default(),
        },
    );
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    }
}

/// Captures a profile from `db.source_client`'s current data.
/// `CloneFixture` guarantees the source and target sides share the same
/// schema name, which is exactly what a profile needs: it's keyed by
/// schema-qualified table name, the same way `feint.yaml`'s `tables:`
/// keys are.
async fn capture_profile_mut(
    db: &mut CloneFixture,
) -> (feint_core::introspect::Schema, profile::ProfileFile) {
    let schema = db.introspect_source().await;
    let txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let captured = profile::capture(&txn, &schema).await.unwrap();
    txn.rollback().await.ok();
    (schema, captured)
}

async fn target_schema_and_plan(
    db: &CloneFixture,
) -> (
    feint_core::introspect::Schema,
    feint_core::graph::InsertPlan,
) {
    let schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&schema).unwrap();
    (schema, plan)
}

#[tokio::test]
async fn cardinality_profile_reproduces_a_long_tail_instead_of_a_uniform_count() {
    let ddl = "CREATE TABLE users (id serial PRIMARY KEY, name text NOT NULL); \
               CREATE TABLE orders (id serial PRIMARY KEY, user_id integer NOT NULL REFERENCES users(id), total numeric(10,2) NOT NULL);";
    let mut db = CloneFixture::setup("profile_cardinality", ddl, ddl).await;

    db.source_client
        .batch_execute(&format!(
            "INSERT INTO users (name) VALUES {};",
            (1..=20)
                .map(|i| format!("('user{i}')"))
                .collect::<Vec<_>>()
                .join(", ")
        ))
        .await
        .unwrap();
    // One heavily-skewed user (50 orders) among 19 with exactly 1 each —
    // a real "long tail", not just noise around a mean.
    let mut order_values: Vec<String> = (0..50).map(|_| "(1, 1.00)".to_string()).collect();
    order_values.extend((2..=20).map(|u| format!("({u}, 1.00)")));
    db.source_client
        .batch_execute(&format!(
            "INSERT INTO orders (user_id, total) VALUES {}",
            order_values.join(", ")
        ))
        .await
        .unwrap();

    let (_, captured_profile) = capture_profile_mut(&mut db).await;
    let (target_schema, plan) = target_schema_and_plan(&db).await;

    // 200 parents (not 20): with the source's 1-in-20 chance of drawing
    // the heavy bucket per parent, this makes "zero heavy parents drawn"
    // astronomically unlikely, so the test isn't flaky on the RNG.
    let config = config_with_rows(&format!("{}.users", db.schema_name), 200);
    let txn = db.target_client.transaction().await.unwrap();
    let summary = insert::run(
        &txn,
        &target_schema,
        &plan,
        &config,
        Some(&captured_profile),
        |_| {},
    )
    .await
    .unwrap();
    txn.commit().await.unwrap();

    let orders_generated = summary
        .rows_by_table
        .iter()
        .find(|(t, _)| t.ends_with(".orders"))
        .map(|(_, n)| *n)
        .unwrap();
    assert!(
        orders_generated > 200,
        "with ~10 expected heavy parents at 50 orders each, total should be well past 200, got {orders_generated}"
    );

    let schema_name = &db.schema_name;
    let counts: Vec<i64> = db
        .target_client
        .query(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".orders GROUP BY user_id ORDER BY count(*)"
            ),
            &[],
        )
        .await
        .unwrap()
        .iter()
        .map(|r| r.get(0))
        .collect();

    // The histogram only ever contained 1 and 50 — every generated
    // per-parent count must be one of exactly those two values, never
    // something the source distribution didn't actually have.
    assert!(
        counts.iter().all(|&c| c == 1 || c == 50),
        "every per-parent order count must be exactly 1 or 50, got {counts:?}"
    );
    assert!(
        counts.contains(&50),
        "expected at least one heavy (50-order) parent among 200, got {counts:?}"
    );
    assert!(
        counts.contains(&1),
        "expected most parents to be light (1-order), got {counts:?}"
    );
}

#[tokio::test]
async fn null_fraction_is_approximately_reproduced() {
    let ddl = "CREATE TABLE events (id serial PRIMARY KEY, kind text NOT NULL, note text);";
    let mut db = CloneFixture::setup("profile_null", ddl, ddl).await;

    // 80 NULL, 20 non-NULL out of 100.
    let mut values: Vec<&str> = vec!["('x', NULL)"; 80];
    values.extend(vec!["('x', 'present')"; 20]);
    db.source_client
        .batch_execute(&format!(
            "INSERT INTO events (kind, note) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let (_, captured_profile) = capture_profile_mut(&mut db).await;
    let table_profile = captured_profile
        .table(&format!("{}.events", db.schema_name))
        .unwrap();
    assert!(
        (table_profile.null_fractions["note"] - 0.8).abs() < 0.01,
        "captured null fraction should be 0.8, got {}",
        table_profile.null_fractions["note"]
    );

    let (target_schema, plan) = target_schema_and_plan(&db).await;
    let config = config_with_rows(&format!("{}.events", db.schema_name), 500);
    let txn = db.target_client.transaction().await.unwrap();
    insert::run(
        &txn,
        &target_schema,
        &plan,
        &config,
        Some(&captured_profile),
        |_| {},
    )
    .await
    .unwrap();
    txn.commit().await.unwrap();

    let schema_name = &db.schema_name;
    let null_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".events WHERE note IS NULL"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    let fraction = null_count as f64 / 500.0;
    assert!(
        (0.65..=0.93).contains(&fraction),
        "expected roughly 80% NULL (with sampling noise at n=500), got {fraction} ({null_count}/500)"
    );
}

#[tokio::test]
async fn unconfigured_table_defaults_to_the_profiles_row_count() {
    let ddl = "CREATE TABLE widgets (id serial PRIMARY KEY, name text NOT NULL);";
    let mut db = CloneFixture::setup("profile_rowcount", ddl, ddl).await;
    db.source_client
        .batch_execute("INSERT INTO widgets (name) SELECT 'w' || generate_series(1, 37);")
        .await
        .unwrap();

    let (_, captured_profile) = capture_profile_mut(&mut db).await;
    let (target_schema, plan) = target_schema_and_plan(&db).await;

    // With a profile and no explicit `rows:`, the profile's row_count wins.
    let txn = db.target_client.transaction().await.unwrap();
    insert::run(
        &txn,
        &target_schema,
        &plan,
        &empty_config(),
        Some(&captured_profile),
        |_| {},
    )
    .await
    .unwrap();
    txn.commit().await.unwrap();
    let schema_name = &db.schema_name;
    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".widgets"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        count, 37,
        "unconfigured table should default to the profile's row_count"
    );
}

#[tokio::test]
async fn no_profile_keeps_the_ordinary_fixed_default() {
    let ddl = "CREATE TABLE widgets (id serial PRIMARY KEY, name text NOT NULL);";
    let db = CloneFixture::setup("profile_rowcount_none", ddl, ddl).await;
    let (target_schema, plan) = target_schema_and_plan(&db).await;

    let mut target_client = db.target_client;
    let txn = target_client.transaction().await.unwrap();
    insert::run(&txn, &target_schema, &plan, &empty_config(), None, |_| {})
        .await
        .unwrap();
    txn.commit().await.unwrap();

    let count: i64 = target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{}\".widgets", db.schema_name),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        count,
        feint_core::config::DEFAULT_ROWS as i64,
        "with no profile at all, an unconfigured table keeps the ordinary fixed default"
    );
}

#[tokio::test]
async fn explicit_rows_config_still_wins_over_the_profile() {
    let ddl = "CREATE TABLE widgets (id serial PRIMARY KEY, name text NOT NULL);";
    let mut db = CloneFixture::setup("profile_rowcount_explicit", ddl, ddl).await;
    db.source_client
        .batch_execute("INSERT INTO widgets (name) SELECT 'w' || generate_series(1, 37);")
        .await
        .unwrap();

    let (_, captured_profile) = capture_profile_mut(&mut db).await;
    let (target_schema, plan) = target_schema_and_plan(&db).await;
    let config = config_with_rows(&format!("{}.widgets", db.schema_name), 5);

    let txn = db.target_client.transaction().await.unwrap();
    insert::run(
        &txn,
        &target_schema,
        &plan,
        &config,
        Some(&captured_profile),
        |_| {},
    )
    .await
    .unwrap();
    txn.commit().await.unwrap();

    let schema_name = &db.schema_name;
    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".widgets"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        count, 5,
        "an explicit rows: in feint.yaml must still win over the profile"
    );
}

#[tokio::test]
async fn profile_driven_generation_is_deterministic() {
    let ddl = "CREATE TABLE users (id serial PRIMARY KEY, name text NOT NULL); \
               CREATE TABLE orders (id serial PRIMARY KEY, user_id integer NOT NULL REFERENCES users(id));";
    let mut source_db = CloneFixture::setup("profile_determinism_source", ddl, ddl).await;
    source_db
        .source_client
        .batch_execute(
            "INSERT INTO users (name) VALUES ('a'), ('b'); \
             INSERT INTO orders (user_id) VALUES (1), (1), (1), (2);",
        )
        .await
        .unwrap();
    let (_, captured_profile) = capture_profile_mut(&mut source_db).await;

    let mut totals = Vec::new();
    for i in 0..2 {
        let db = CloneFixture::setup(&format!("profile_determinism_run_{i}"), ddl, ddl).await;
        let (target_schema, plan) = target_schema_and_plan(&db).await;
        let config = config_with_rows(&format!("{}.users", db.schema_name), 30);
        let mut target_client = db.target_client;
        let txn = target_client.transaction().await.unwrap();
        let summary = insert::run(
            &txn,
            &target_schema,
            &plan,
            &config,
            Some(&captured_profile),
            |_| {},
        )
        .await
        .unwrap();
        txn.commit().await.ok();
        totals.push(summary.total_rows);
    }

    assert_eq!(
        totals[0], totals[1],
        "same seed, same profile, same config must generate the same total row count both times"
    );
}
