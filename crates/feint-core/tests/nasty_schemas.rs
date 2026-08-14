mod common;

use common::TestDb;
use feint_core::config::FeintConfig;
use feint_core::graph::plan_insertion;
use rstest::rstest;

#[rstest]
#[case::composite_fk("composite_fk", include_str!("fixtures/schemas/composite_fk.sql"))]
#[case::self_ref_fk("self_ref_fk", include_str!("fixtures/schemas/self_ref_fk.sql"))]
#[case::cycle_nullable("cycle_nullable", include_str!("fixtures/schemas/cycle_nullable.sql"))]
#[case::cycle_deferred("cycle_deferred", include_str!("fixtures/schemas/cycle_deferred.sql"))]
#[case::enums("enums", include_str!("fixtures/schemas/enums.sql"))]
#[case::domains("domains", include_str!("fixtures/schemas/domains.sql"))]
#[case::arrays("arrays", include_str!("fixtures/schemas/arrays.sql"))]
#[case::jsonb("jsonb", include_str!("fixtures/schemas/jsonb.sql"))]
#[case::citext("citext", include_str!("fixtures/schemas/citext.sql"))]
#[case::inet_cidr("inet_cidr", include_str!("fixtures/schemas/inet_cidr.sql"))]
#[case::uuid_pk("uuid_pk", include_str!("fixtures/schemas/uuid_pk.sql"))]
#[case::identity_serial("identity_serial", include_str!("fixtures/schemas/identity_serial.sql"))]
#[case::partitioned("partitioned", include_str!("fixtures/schemas/partitioned.sql"))]
#[tokio::test]
async fn nasty_schema_generates_cleanly(#[case] name: &str, #[case] ddl: &str) {
    let mut db = TestDb::setup(name, ddl).await;
    let schema = db.introspect().await;
    assert!(
        !schema.tables.is_empty(),
        "fixture `{name}` introspected zero tables"
    );

    let rows = 20u32;
    let summary = db.generate(&schema, rows).await;
    assert_eq!(
        summary.rows_by_table.len(),
        schema.tables.len(),
        "fixture `{name}`: not every table got an insertion group"
    );
    for (table_name, count) in &summary.rows_by_table {
        assert_eq!(
            *count, rows as u64,
            "fixture `{name}`: table `{table_name}` planned/inserted row count mismatch"
        );
    }

    db.assert_no_orphans(&schema).await;

    for table in &schema.tables {
        let sql = format!(
            "SELECT count(*) FROM \"{}\".\"{}\"",
            table.id.schema, table.id.name
        );
        let row = db.client.query_one(&sql, &[]).await.unwrap();
        let count: i64 = row.get(0);
        assert_eq!(
            count as u64, rows as u64,
            "fixture `{name}`: table `{}` actual DB row count mismatch",
            table.id.name
        );
    }
}

#[tokio::test]
async fn hard_unsatisfiable_cycle_is_rejected_at_planning_time() {
    let db = TestDb::setup(
        "cycle_hard_unsatisfiable",
        include_str!("fixtures/schemas/cycle_hard_unsatisfiable.sql"),
    )
    .await;
    let schema = db.introspect().await;
    let result = plan_insertion(&schema);
    assert!(
        result.is_err(),
        "expected a NOT NULL, non-deferrable FK cycle to be rejected before any insert is attempted"
    );
}

#[tokio::test]
async fn check_constraints_are_introspected_and_annotated_in_yaml() {
    let db = TestDb::setup(
        "check_constraints",
        include_str!("fixtures/schemas/check_constraints.sql"),
    )
    .await;
    let schema = db.introspect().await;
    let products = schema
        .tables
        .iter()
        .find(|t| t.id.name == "products")
        .expect("products table");
    assert_eq!(
        products.check_constraints.len(),
        2,
        "expected two CHECK constraints on `products`"
    );

    let config = FeintConfig::from_schema(&schema);
    let yaml = config.to_annotated_yaml(&schema);
    assert!(
        yaml.contains("CHECK constraints"),
        "annotated yaml is missing the CHECK-constraint comment header"
    );
    assert!(
        yaml.contains("price"),
        "annotated yaml is missing the `price` check definition"
    );

    let reparsed: FeintConfig =
        serde_yaml_ng::from_str(&yaml).expect("annotated yaml (with comments) must still parse");
    assert_eq!(reparsed.tables.len(), config.tables.len());
}
