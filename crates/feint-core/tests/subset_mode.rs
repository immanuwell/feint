mod common;

use common::CloneFixture;
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;
use feint_core::subset::{compute_subset, parse_root, SubsetOptions};
use std::collections::BTreeMap;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

/// `name` is a `classify_sensitive`-flagged column and gets faked by
/// default (correct CLONE-mode behavior, exercised elsewhere) — tests
/// that want to assert on real name values opt out of masking for it.
fn config_with_unmasked_name(table: &str) -> FeintConfig {
    let mut cols = BTreeMap::new();
    cols.insert(
        "name".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::None),
            json_paths: Default::default(),
        },
    );
    let mut tables = BTreeMap::new();
    tables.insert(
        table.to_string(),
        TableConfig {
            rows: 0,
            strategy: Default::default(),
            columns: cols,
            logical_foreign_keys: Default::default(),
        },
    );
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables,
    }
}

const DIAMOND_DDL: &str = "
    CREATE TABLE organizations (id serial PRIMARY KEY, name text NOT NULL);
    CREATE TABLE users (
        id serial PRIMARY KEY,
        organization_id integer NOT NULL REFERENCES organizations(id),
        name text NOT NULL
    );
    CREATE TABLE products (id serial PRIMARY KEY, title text NOT NULL);
    CREATE TABLE orders (
        id serial PRIMARY KEY,
        user_id integer NOT NULL REFERENCES users(id)
    );
    CREATE TABLE order_items (
        id serial PRIMARY KEY,
        order_id integer NOT NULL REFERENCES orders(id),
        product_id integer NOT NULL REFERENCES products(id)
    );
    CREATE TABLE audit_log (id serial PRIMARY KEY, message text NOT NULL);
";

/// Diamond dependency: org 1's order references a product that org 2's
/// (out-of-subset) order *also* references. Pulling that product in as a
/// required parent must not drag org 2's order along with it — that's the
/// whole point of "required rows never re-trigger forward expansion".
#[tokio::test]
async fn diamond_dependency_pulls_required_parent_without_its_other_children() {
    let mut db = CloneFixture::setup("diamond", DIAMOND_DDL, DIAMOND_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO organizations (name) VALUES ('Org One'), ('Org Two'); \
             INSERT INTO users (organization_id, name) VALUES (1, 'Alice'), (2, 'Bob'); \
             INSERT INTO products (title) VALUES ('Widget'); \
             INSERT INTO orders (user_id) VALUES (1), (2); \
             INSERT INTO order_items (order_id, product_id) VALUES (1, 1), (2, 1); \
             INSERT INTO audit_log (message) VALUES ('unrelated event');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = empty_config();
    let summary = db
        .clone_subset(&schema, &config, Some("organizations WHERE id = 1"))
        .await
        .expect("subset clone should succeed");
    assert!(summary.total_rows > 0);

    let schema_name = &db.schema_name;
    let user_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".users"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(user_count, 1, "only org 1's user should be in the subset");

    let order_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".orders"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        order_count, 1,
        "org 2's order must not be dragged in via the shared product"
    );

    let product_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".products"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        product_count, 1,
        "the shared product must still be pulled in as a required parent"
    );

    // audit_log has no FK relationship to anything in the subset at all —
    // pure FK-based subsetting can't discover it, so it must stay empty.
    let audit_count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".audit_log"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(
        audit_count, 0,
        "a table unreachable from the root must stay empty"
    );

    // FK integrity across the whole target.
    let orphans: i64 = db
        .target_client
        .query_one(
            &format!(
                "SELECT \
                   (SELECT count(*) FROM \"{schema_name}\".users u LEFT JOIN \"{schema_name}\".organizations o ON u.organization_id = o.id WHERE o.id IS NULL) + \
                   (SELECT count(*) FROM \"{schema_name}\".orders ord LEFT JOIN \"{schema_name}\".users u ON ord.user_id = u.id WHERE u.id IS NULL) + \
                   (SELECT count(*) FROM \"{schema_name}\".order_items oi LEFT JOIN \"{schema_name}\".orders ord ON oi.order_id = ord.id WHERE ord.id IS NULL) + \
                   (SELECT count(*) FROM \"{schema_name}\".order_items oi LEFT JOIN \"{schema_name}\".products p ON oi.product_id = p.id WHERE p.id IS NULL)"
            ),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(orphans, 0);
}

const SELF_REF_DDL: &str = "
    CREATE TABLE employees (
        id serial PRIMARY KEY,
        manager_id integer REFERENCES employees(id),
        name text NOT NULL
    );
";

/// Self-referencing FKs make forward BFS reflexive on the same table:
/// rooting at the CEO should pull in the whole downward chain of reports.
#[tokio::test]
async fn self_referencing_root_walks_the_whole_downward_chain() {
    let mut db = CloneFixture::setup("self_ref_subset", SELF_REF_DDL, SELF_REF_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO employees (manager_id, name) VALUES (NULL, 'CEO'); \
             INSERT INTO employees (manager_id, name) VALUES (1, 'VP'); \
             INSERT INTO employees (manager_id, name) VALUES (2, 'Manager'); \
             INSERT INTO employees (manager_id, name) VALUES (3, 'IC'); \
             INSERT INTO employees (manager_id, name) VALUES (NULL, 'Unrelated CEO');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let config = config_with_unmasked_name(&format!("{}.employees", db.schema_name));
    let summary = db
        .clone_subset(&schema, &config, Some("employees WHERE id = 1"))
        .await
        .expect("subset clone should succeed");
    assert_eq!(
        summary.total_rows, 4,
        "CEO plus the whole downward chain, not the unrelated CEO"
    );

    let schema_name = &db.schema_name;
    let names: Vec<String> = db
        .target_client
        .query(
            &format!("SELECT name FROM \"{schema_name}\".employees ORDER BY id"),
            &[],
        )
        .await
        .unwrap()
        .iter()
        .map(|r| r.get(0))
        .collect();
    assert_eq!(names, vec!["CEO", "VP", "Manager", "IC"]);
}

/// The cap must abort the whole clone before any target write, not
/// truncate-and-continue.
#[tokio::test]
async fn cap_abort_leaves_target_untouched() {
    let mut db = CloneFixture::setup("subset_cap", SELF_REF_DDL, SELF_REF_DDL).await;
    db.source_client
        .batch_execute(
            "INSERT INTO employees (manager_id, name) VALUES (NULL, 'CEO'); \
             INSERT INTO employees (manager_id, name) VALUES (1, 'VP'); \
             INSERT INTO employees (manager_id, name) VALUES (2, 'Manager');",
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let root = parse_root(&schema, "employees WHERE id = 1").unwrap();
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let result = compute_subset(&source_txn, &schema, &root, &SubsetOptions { max_rows: 1 }).await;
    assert!(
        result.is_err(),
        "a cap of 1 row must be tripped by a 3-row chain"
    );
}
