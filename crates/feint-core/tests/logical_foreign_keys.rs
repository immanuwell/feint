//! Regression coverage for the "trigger-based relationships" real-world-
//! schema-pilot finding: Chatwoot's `conversations.account_id` has no
//! PostgreSQL FK to `accounts.id` at all, but an app-level trigger pair
//! (one on `accounts` that creates a per-account sequence, one on
//! `conversations` that calls `nextval` on it, keyed by `account_id`)
//! depends on `account_id` actually pointing at an existing account.
//! Without a real FK, GENERATE mode samples an unrelated integer and the
//! `conversations` trigger fails on a sequence that was never created —
//! see STATUS.md's "trigger-based relationships" item.
//!
//! `logical_foreign_keys:` in `feint.yaml` lets a user declare the
//! relationship by hand so RefPool samples a real, existing `accounts.id`
//! for `account_id`, exactly as if a real FK constraint existed.

mod common;

use common::TestDb;
use feint_core::config::{FeintConfig, LogicalForeignKey, TableConfig, TableStrategy};
use feint_core::graph::plan_insertion;
use std::collections::BTreeMap;

/// Chatwoot's real shape, minimized: an `AFTER INSERT` trigger on
/// `accounts` creates a per-account sequence; a `BEFORE INSERT` trigger on
/// `conversations` calls `nextval` on the sequence named after its own
/// (undeclared) `account_id`. Both tables and both trigger functions are
/// created inside the test's own schema, which is on `search_path`, so an
/// unqualified `CREATE SEQUENCE`/`nextval` inside the trigger bodies
/// resolves there.
const DDL: &str = "
    CREATE TABLE accounts (id serial primary key, name text not null);

    CREATE FUNCTION accounts_after_insert_row_tr() RETURNS trigger AS $$
    BEGIN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS conv_dpid_seq_%s', NEW.id);
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER accounts_after_insert
        AFTER INSERT ON accounts
        FOR EACH ROW EXECUTE FUNCTION accounts_after_insert_row_tr();

    CREATE TABLE conversations (
        id serial primary key,
        account_id integer not null,
        display_id integer
    );

    CREATE FUNCTION conversations_before_insert_row_tr() RETURNS trigger AS $$
    BEGIN
        NEW.display_id := nextval('conv_dpid_seq_' || NEW.account_id);
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER conversations_before_insert
        BEFORE INSERT ON conversations
        FOR EACH ROW EXECUTE FUNCTION conversations_before_insert_row_tr();
";

fn plain_config(db: &TestDb, rows: u32) -> FeintConfig {
    let mut tables = BTreeMap::new();
    for name in ["accounts", "conversations"] {
        tables.insert(
            format!("{}.{name}", db.schema_name),
            TableConfig {
                rows,
                strategy: TableStrategy::default(),
                columns: BTreeMap::new(),
                logical_foreign_keys: Vec::new(),
            },
        );
    }
    FeintConfig {
        version: 1,
        seed: "logical-fk-test".to_string(),
        tables,
    }
}

/// Reproduces the real bug first: with no logical FK declared,
/// `account_id` is generated independently of `accounts.id`, so the
/// `conversations` trigger's `nextval` on a sequence that was never
/// created for that (unrelated) id fails — a real Postgres error, not a
/// feint one, exactly matching what the Chatwoot survey fixture hit.
#[tokio::test]
async fn without_a_logical_fk_the_trigger_dependent_insert_fails() {
    let mut db = TestDb::setup("logical_fk_missing", DDL).await;
    let schema = db.introspect().await;

    let accounts = schema
        .tables
        .iter()
        .find(|t| t.id.name == "conversations")
        .expect("conversations table");
    assert!(
        accounts.foreign_keys.is_empty(),
        "conversations must have zero real FKs, matching Chatwoot's actual schema"
    );

    let config = plain_config(&db, 3);
    let plan = plan_insertion(&schema).expect("insertion plan");
    let txn = db.client.transaction().await.expect("begin txn");
    let err = match feint_core::insert::run(&txn, &schema, &plan, &config, None, |_| {}).await {
        Ok(_) => panic!("generation should fail without the logical FK"),
        Err(e) => e,
    };
    txn.rollback().await.ok();
    let msg = format!("{err}");
    assert!(
        msg.contains("conv_dpid_seq") || msg.to_lowercase().contains("does not exist"),
        "expected a real Postgres 'sequence does not exist' error, got: {msg}"
    );
}

/// With the logical FK declared, `account_id` is sampled from real,
/// already-inserted `accounts.id` values — exactly like a real FK would
/// — so the trigger's sequence always exists, and generation succeeds
/// end to end.
#[tokio::test]
async fn a_declared_logical_fk_makes_the_trigger_dependent_insert_succeed() {
    let mut db = TestDb::setup("logical_fk_declared", DDL).await;
    let mut schema = db.introspect().await;

    let mut config = plain_config(&db, 5);
    config
        .tables
        .get_mut(&format!("{}.conversations", db.schema_name))
        .expect("conversations in config")
        .logical_foreign_keys
        .push(LogicalForeignKey {
            columns: vec!["account_id".to_string()],
            ref_table: format!("{}.accounts", db.schema_name),
            ref_columns: vec!["id".to_string()],
        });

    feint_core::config::apply_logical_foreign_keys(&mut schema, &config)
        .expect("logical FK should merge cleanly");

    let conversations = schema
        .tables
        .iter()
        .find(|t| t.id.name == "conversations")
        .expect("conversations table");
    assert_eq!(
        conversations.foreign_keys.len(),
        1,
        "the logical FK should have been merged into the real foreign_keys list"
    );

    let plan = plan_insertion(&schema).expect("insertion plan");
    let txn = db.client.transaction().await.expect("begin txn");
    let summary = feint_core::insert::run(&txn, &schema, &plan, &config, None, |_| {})
        .await
        .expect("generation should succeed with the logical FK declared");
    txn.commit().await.expect("commit");

    let rows_for = |table: &str| -> u64 {
        summary
            .rows_by_table
            .iter()
            .find(|(name, _)| name == table)
            .map(|(_, n)| *n)
            .unwrap_or_else(|| panic!("no rows_by_table entry for {table}"))
    };
    assert_eq!(rows_for(&format!("{}.accounts", db.schema_name)), 5);
    assert_eq!(rows_for(&format!("{}.conversations", db.schema_name)), 5);

    // Every account_id conversations ended up with must be a real,
    // existing accounts.id — proving RefPool actually sampled instead of
    // generating an unrelated value.
    let rows = db
        .client
        .query(
            &format!(
                "SELECT c.account_id FROM \"{}\".conversations c \
                 LEFT JOIN \"{}\".accounts a ON a.id = c.account_id \
                 WHERE a.id IS NULL",
                db.schema_name, db.schema_name
            ),
            &[],
        )
        .await
        .expect("query orphans");
    assert!(
        rows.is_empty(),
        "found conversations.account_id values with no matching accounts.id row"
    );
}
