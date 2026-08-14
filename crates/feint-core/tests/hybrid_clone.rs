mod common;

use std::collections::BTreeMap;

use common::CloneFixture;
use feint_core::config::{FeintConfig, TableConfig, TableStrategy};
use feint_core::FeintError;

fn config_with_strategy(table: &str, rows: u32, strategy: TableStrategy) -> FeintConfig {
    let mut tables = BTreeMap::new();
    tables.insert(
        table.to_string(),
        TableConfig {
            rows,
            strategy,
            columns: Default::default(),
        },
    );
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    }
}

const USERS_EVENTS_DDL: &str = "
    CREATE TABLE users (
        id serial PRIMARY KEY,
        email text NOT NULL
    );
    CREATE TABLE events (
        id serial PRIMARY KEY,
        user_id integer NOT NULL REFERENCES users(id),
        payload text NOT NULL
    );
";

#[tokio::test]
async fn generate_strategy_table_is_padded_with_synthetic_rows_referencing_real_masked_parents() {
    let mut db = CloneFixture::setup("hybrid_basic", USERS_EVENTS_DDL, USERS_EVENTS_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO users (email) VALUES \
                ('alice@corp.com'), ('bob@corp.com'), ('carol@corp.com'), \
                ('dave@corp.com'), ('erin@corp.com'); \
             INSERT INTO events (user_id, payload) VALUES (1, 'source-only, must be ignored');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = config_with_strategy(
        &format!("{}.events", db.schema_name),
        20,
        TableStrategy::Generate,
    );
    let summary = db
        .clone(&schema, &config)
        .await
        .expect("hybrid clone should succeed");

    // users wasn't mentioned in the config at all, so it stays `mask` by
    // default: all 5 real rows, cloned and masked, exactly like plain
    // `clone` today.
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
    assert_eq!(users, 5, "mask-strategy table clones every real row");

    let real_email_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".users WHERE email LIKE '%@corp.com'"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        real_email_count, 0,
        "mask-strategy table must still mask sensitive columns in a hybrid run"
    );

    // events is `strategy: generate, rows: 20` — the target must have
    // exactly 20 rows, not the 1 real row that existed in source, proving
    // the real source row was never read at all.
    let events: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".events"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        events, 20,
        "generate-strategy table must be padded to its configured `rows:`, ignoring source"
    );

    let source_only_payload: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".events WHERE payload = 'source-only, must be ignored'"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        source_only_payload, 0,
        "a generate-strategy table's real source row must never be read"
    );

    // Every synthetic event's user_id must point at a real (masked) user
    // that actually exists on target — this is the core hybrid guarantee:
    // fabricated child rows referencing real parent keys.
    let orphans: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".events e \
                 LEFT JOIN \"{schema_name}\".users u ON e.user_id = u.id WHERE u.id IS NULL"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        orphans, 0,
        "every generated event must reference a real user"
    );

    assert_eq!(summary.total_rows, 25, "5 real users + 20 generated events");
}

#[tokio::test]
async fn mask_table_referencing_a_generate_table_is_rejected_before_any_write() {
    let ddl = "
        CREATE TABLE parents (id serial PRIMARY KEY);
        CREATE TABLE children (
            id serial PRIMARY KEY,
            parent_id integer NOT NULL REFERENCES parents(id)
        );
    ";
    let mut db = CloneFixture::setup("hybrid_direction_rejected", ddl, ddl).await;
    db.source_client
        .batch_execute(
            "INSERT INTO parents DEFAULT VALUES; INSERT INTO children (parent_id) VALUES (1);",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    // parents is `generate`; children keeps the default `mask` and still
    // has a real foreign key pointing at parents — exactly the unsound
    // combination `validate_hybrid_config` exists to catch.
    let config = config_with_strategy(
        &format!("{}.parents", db.schema_name),
        5,
        TableStrategy::Generate,
    );

    let err = db
        .clone(&schema, &config)
        .await
        .expect_err("a mask table referencing a generate table must be rejected");
    assert!(matches!(err, FeintError::Config(_)));
    let message = format!("{err}");
    assert!(message.contains("children"), "message: {message}");
    assert!(message.contains("parents"), "message: {message}");

    let schema_name = &db.schema_name;
    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".parents"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, 0, "rejected config must not write anything");
}

#[tokio::test]
async fn mixed_strategy_within_one_foreign_key_cycle_is_rejected() {
    let ddl = "
        CREATE TABLE a (id serial PRIMARY KEY, b_id integer);
        CREATE TABLE b (id serial PRIMARY KEY, a_id integer);
        ALTER TABLE a ADD CONSTRAINT a_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id) DEFERRABLE INITIALLY DEFERRED;
        ALTER TABLE b ADD CONSTRAINT b_a_id_fkey FOREIGN KEY (a_id) REFERENCES a(id);
    ";
    let mut db = CloneFixture::setup("hybrid_cycle_mixed_rejected", ddl, ddl).await;

    let schema = db.introspect_source().await;
    // `a` and `b` form one FK cycle (resolved as a Deferred group). `a` is
    // `generate`, `b` stays the default `mask` — mixing strategies inside
    // one cycle isn't supported.
    let config = config_with_strategy(&format!("{}.a", db.schema_name), 3, TableStrategy::Generate);

    let err = db
        .clone(&schema, &config)
        .await
        .expect_err("mixed strategy within one FK cycle must be rejected");
    assert!(matches!(err, FeintError::Config(_)));
    let message = format!("{err}");
    assert!(message.contains("cycle"), "message: {message}");
}

#[tokio::test]
async fn subsetting_composes_with_a_generate_strategy_table() {
    // `--root` only changes which real (mask-strategy) rows get pulled
    // from source; a generate-strategy table always synthesizes its full
    // configured `rows:` regardless of the subset.
    let ddl = "
        CREATE TABLE orgs (id serial PRIMARY KEY, name text NOT NULL);
        CREATE TABLE users (
            id serial PRIMARY KEY,
            org_id integer NOT NULL REFERENCES orgs(id),
            email text NOT NULL
        );
        CREATE TABLE events (
            id serial PRIMARY KEY,
            user_id integer NOT NULL REFERENCES users(id),
            payload text NOT NULL
        );
    ";
    let mut db = CloneFixture::setup("hybrid_subset", ddl, ddl).await;
    db.source_client
        .batch_execute(
            "INSERT INTO orgs (name) VALUES ('kept'), ('dropped'); \
             INSERT INTO users (org_id, email) VALUES (1, 'a@corp.com'), (1, 'b@corp.com'), (2, 'c@corp.com');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = config_with_strategy(
        &format!("{}.events", db.schema_name),
        10,
        TableStrategy::Generate,
    );
    db.clone_subset(&schema, &config, Some("orgs WHERE id = 1"))
        .await
        .expect("hybrid clone with --root should succeed");

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
    assert_eq!(users, 2, "only org 1's two users are in the subset");

    let events: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".events"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        events, 10,
        "generate-strategy table ignores the subset entirely"
    );

    let orphans: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{schema_name}\".events e \
                 LEFT JOIN \"{schema_name}\".users u ON e.user_id = u.id WHERE u.id IS NULL"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        orphans, 0,
        "generated events must only reference the subsetted users that actually got cloned"
    );
}
