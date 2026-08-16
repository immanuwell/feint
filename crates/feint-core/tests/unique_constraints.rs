//! Regression coverage for two real-world-schema-pilot findings:
//!
//! 1. Introspection only read `pg_constraint`, missing a bare
//!    `CREATE UNIQUE INDEX` (no backing constraint) — extremely common in
//!    Rails/TypeORM-style migrations (Listmonk's `idx_roles`, Mastodon's
//!    `idx_on_account_id_target_account_id_...`).
//! 2. GENERATE mode sampled FK values independently per row with no
//!    awareness of the table's own UNIQUE constraints, so a composite or
//!    single-column UNIQUE FK could collide at random (Miniflux's
//!    `integrations.user_id`, Listmonk's `roles` table).
//!
//! Both were found via `real_world_schemas.rs`, testing against real
//! open-source apps' own schemas — see that file's doc comment.

mod common;

use common::TestDb;
use std::collections::HashSet;

/// `idx_ab` is a bare `CREATE UNIQUE INDEX`, not an `ADD CONSTRAINT UNIQUE`
/// — introspection must still surface it. `idx_a_partial` (a partial
/// index) and `idx_lower_c` (an expression index) must NOT be surfaced:
/// neither maps to a simple "this column set is globally unique" rule.
#[tokio::test]
async fn bare_unique_index_is_introspected_but_partial_and_expression_indexes_are_not() {
    let db = TestDb::setup(
        "bare_unique_index",
        "CREATE TABLE t (
            id serial primary key,
            a int not null,
            b int not null,
            c text
        );
        CREATE UNIQUE INDEX idx_ab ON t (a, b);
        CREATE UNIQUE INDEX idx_a_partial ON t (a) WHERE b > 0;
        CREATE UNIQUE INDEX idx_lower_c ON t (lower(c));",
    )
    .await;
    let schema = db.introspect().await;
    let table = schema
        .tables
        .iter()
        .find(|t| t.id.name == "t")
        .expect("table t");

    let names: Vec<&str> = table
        .unique_constraints
        .iter()
        .map(|c| c.name.as_str())
        .collect();
    assert!(names.contains(&"idx_ab"), "missing idx_ab in {names:?}");
    assert!(
        !names.contains(&"idx_a_partial"),
        "partial index leaked into unique_constraints: {names:?}"
    );
    assert!(
        !names.contains(&"idx_lower_c"),
        "expression index leaked into unique_constraints: {names:?}"
    );

    let ab = table
        .unique_constraints
        .iter()
        .find(|c| c.name == "idx_ab")
        .unwrap();
    assert_eq!(ab.columns, vec!["a".to_string(), "b".to_string()]);
    assert!(!ab.is_primary);
}

/// Simple-group table (no self-reference): a composite `UNIQUE
/// (parent_a_id, parent_b_id)` over two independent FKs. Naive
/// per-row-independent sampling would eventually collide; GENERATE mode
/// must retry instead of crashing on a duplicate-key error, and every
/// generated row must actually respect the constraint.
#[tokio::test]
async fn simple_group_avoids_colliding_on_a_composite_unique_fk() {
    let mut db = TestDb::setup(
        "simple_unique_fk",
        "CREATE TABLE parents (id serial primary key, name text not null);
        CREATE TABLE children (
            id serial primary key,
            parent_a_id int not null references parents(id),
            parent_b_id int not null references parents(id)
        );
        CREATE UNIQUE INDEX idx_children_ab ON children (parent_a_id, parent_b_id);",
    )
    .await;
    let schema = db.introspect().await;
    db.generate(&schema, 3).await; // 3 parents => 9 possible (a,b) pairs

    let rows = db
        .client
        .query("SELECT parent_a_id, parent_b_id FROM children", &[])
        .await
        .expect("query children");
    assert_eq!(rows.len(), 3, "expected 3 children rows");
    let pairs: HashSet<(i32, i32)> = rows.iter().map(|r| (r.get(0), r.get(1))).collect();
    assert_eq!(
        pairs.len(),
        rows.len(),
        "found duplicate (parent_a_id, parent_b_id) pairs — the unique constraint was violated"
    );
}

/// When the pool genuinely can't satisfy the constraint (more rows
/// requested than distinct pairs available), GENERATE mode must fail with
/// a clear, actionable error — not a raw Postgres duplicate-key crash.
#[tokio::test]
async fn simple_group_reports_a_clear_error_when_the_pool_is_too_small() {
    use feint_core::config::FeintConfig;
    use feint_core::error::FeintError;
    use feint_core::graph::plan_insertion;

    let mut db = TestDb::setup(
        "unique_fk_exhausted",
        "CREATE TABLE parents (id serial primary key, name text not null);
        CREATE TABLE children (
            id serial primary key,
            parent_a_id int not null references parents(id),
            parent_b_id int not null references parents(id)
        );
        CREATE UNIQUE INDEX idx_children_ab ON children (parent_a_id, parent_b_id);",
    )
    .await;
    let schema = db.introspect().await;

    let mut config = FeintConfig::from_schema(&schema);
    config
        .tables
        .get_mut(&format!("{}.parents", db.schema_name))
        .expect("parents in config")
        .rows = 2;
    config
        .tables
        .get_mut(&format!("{}.children", db.schema_name))
        .expect("children in config")
        .rows = 10; // only 2*2=4 distinct (a,b) pairs possible

    let plan = plan_insertion(&schema).expect("insertion plan");
    let txn = db.client.transaction().await.expect("begin txn");
    let err = match feint_core::insert::run(&txn, &schema, &plan, &config, None, |_| {}).await {
        Ok(_) => panic!("expected a clear config error, not a raw crash"),
        Err(e) => e,
    };
    txn.rollback().await.ok();
    assert!(
        matches!(err, FeintError::Config(_)),
        "expected FeintError::Config, got {err:?}"
    );
    let msg = err.to_string();
    assert!(
        msg.contains("UNIQUE"),
        "error message should mention UNIQUE constraints: {msg}"
    );
    assert!(
        msg.contains("foreign key") && msg.contains("referenced table"),
        "a UNIQUE constraint made entirely of FK columns should get the \
         referenced-table-needs-more-rows advice: {msg}"
    );
}

/// Metabase's real shape: `UNIQUE (is_active)` on a plain `boolean`
/// column — no foreign key at all, so the exhaustion error's old
/// "the referenced table(s) likely don't have enough distinct rows"
/// advice was actively misleading (there is no referenced table; the
/// column's own type caps it at 2 non-null distinct values).
#[tokio::test]
async fn non_fk_unique_column_reports_its_own_cardinality_cap_not_a_referenced_table() {
    use feint_core::config::FeintConfig;
    use feint_core::error::FeintError;
    use feint_core::graph::plan_insertion;

    let mut db = TestDb::setup(
        "unique_boolean_exhausted",
        "CREATE TABLE source_replacement_run (
            id serial primary key,
            is_active boolean not null unique
        );",
    )
    .await;
    let schema = db.introspect().await;

    let mut config = FeintConfig::from_schema(&schema);
    config
        .tables
        .get_mut(&format!("{}.source_replacement_run", db.schema_name))
        .expect("table in config")
        .rows = 3; // only 2 distinct boolean values possible

    let plan = plan_insertion(&schema).expect("insertion plan");
    let txn = db.client.transaction().await.expect("begin txn");
    let err = match feint_core::insert::run(&txn, &schema, &plan, &config, None, |_| {}).await {
        Ok(_) => panic!("expected a clear config error, not a raw crash"),
        Err(e) => e,
    };
    txn.rollback().await.ok();
    assert!(
        matches!(err, FeintError::Config(_)),
        "expected FeintError::Config, got {err:?}"
    );
    let msg = err.to_string();
    assert!(
        !msg.contains("referenced table"),
        "a non-FK UNIQUE column must not get referenced-table advice, which is \
         nonsensical when there is no referenced table: {msg}"
    );
    assert!(
        msg.contains("is_active") && msg.contains("own declared type"),
        "expected the message to name the column and explain its own cardinality \
         cap: {msg}"
    );
}

/// Backfill-group table (Listmonk's `roles` shape): a nullable
/// self-referencing FK (`parent_id -> roles.id`, backfilled via UPDATE
/// after the initial null-first insert) combined with an external NOT
/// NULL FK (`list_id -> lists.id`) under one composite UNIQUE constraint.
/// The backfill UPDATE pass — not just the initial insert — must also
/// avoid colliding on the pair.
#[tokio::test]
async fn backfill_group_avoids_colliding_on_a_composite_unique_fk() {
    let mut db = TestDb::setup(
        "backfill_unique_fk",
        "CREATE TABLE lists (id serial primary key, name text not null);
        CREATE TABLE roles (
            id serial primary key,
            parent_id int references roles(id),
            list_id int not null references lists(id)
        );
        CREATE UNIQUE INDEX idx_roles_pl ON roles (parent_id, list_id);",
    )
    .await;
    let schema = db.introspect().await;
    db.generate(&schema, 5).await; // 5 lists, up to 5 possible parents => plenty of room

    let rows = db
        .client
        .query(
            "SELECT parent_id, list_id FROM roles WHERE parent_id IS NOT NULL",
            &[],
        )
        .await
        .expect("query roles");
    let pairs: HashSet<(i32, i32)> = rows.iter().map(|r| (r.get(0), r.get(1))).collect();
    assert_eq!(
        pairs.len(),
        rows.len(),
        "found duplicate (parent_id, list_id) pairs after backfill — the unique constraint was violated"
    );
}
