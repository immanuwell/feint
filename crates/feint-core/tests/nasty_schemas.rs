mod common;

use common::TestDb;
use feint_core::config::FeintConfig;
use feint_core::graph::plan_insertion;
use feint_core::introspect::TypeKind;
use rstest::rstest;

#[rstest]
#[case::composite_fk("composite_fk", include_str!("fixtures/schemas/composite_fk.sql"))]
#[case::self_ref_fk("self_ref_fk", include_str!("fixtures/schemas/self_ref_fk.sql"))]
#[case::self_ref_fk_not_null(
    "self_ref_fk_not_null",
    include_str!("fixtures/schemas/self_ref_fk_not_null.sql")
)]
#[case::self_ref_fk_multi_table(
    "self_ref_fk_multi_table",
    include_str!("fixtures/schemas/self_ref_fk_multi_table.sql")
)]
#[case::cycle_nullable("cycle_nullable", include_str!("fixtures/schemas/cycle_nullable.sql"))]
#[case::cycle_deferred("cycle_deferred", include_str!("fixtures/schemas/cycle_deferred.sql"))]
#[case::deferred_mixed_non_deferrable_order(
    "deferred_mixed_non_deferrable_order",
    include_str!("fixtures/schemas/deferred_mixed_non_deferrable_order.sql")
)]
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

/// Twenty's real shape: a cyclic group lands in `InsertGroup::Deferred`
/// because *some* internal edge is deferrable, but two of the group's
/// other edges are NOT DEFERRABLE and form a hard cycle between
/// themselves — `SET CONSTRAINTS ALL DEFERRED` can't defer a constraint
/// that was never declared DEFERRABLE, so no write order can satisfy
/// both non-deferrable edges at once. `plan_insertion` itself succeeds
/// (routing to `Deferred`, since it only checks "any edge deferrable"),
/// but `up`/`generate` must still reject this with a clear error rather
/// than a raw, uninformative FK-violation from Postgres partway through
/// a batch.
#[tokio::test]
async fn deferred_group_with_a_hard_non_deferrable_subcycle_is_rejected_at_generate_time() {
    let mut db = TestDb::setup(
        "deferred_hard_subcycle",
        include_str!("fixtures/schemas/deferred_hard_subcycle_unsatisfiable.sql"),
    )
    .await;
    let schema = db.introspect().await;
    let plan = plan_insertion(&schema).expect("plan_insertion should succeed (routes to Deferred)");
    let config = feint_core::config::FeintConfig::from_schema(&schema);
    let txn = db.client.transaction().await.expect("begin txn");
    let result = feint_core::insert::run(&txn, &schema, &plan, &config, None, |_| {}).await;
    let Err(err) = result else {
        panic!(
            "expected the hard non-deferrable sub-cycle between `a` and `b` to be rejected with a \
             clear error rather than a raw Postgres FK-violation"
        );
    };
    let msg = err.to_string();
    assert!(
        msg.contains("no valid write order"),
        "expected a clear write-order error, got: {msg}"
    );
}

#[tokio::test]
async fn enum_array_elements_are_introspected_and_generated_as_enum_values() {
    let mut db = TestDb::setup(
        "enum_array_elements",
        include_str!("fixtures/schemas/enums.sql"),
    )
    .await;
    let schema = db.introspect().await;
    let people = schema
        .tables
        .iter()
        .find(|table| table.id.name == "people")
        .expect("people table");
    let recent_moods = people.column("recent_moods").expect("recent_moods column");
    assert_eq!(
        recent_moods.type_kind,
        TypeKind::Array {
            elem_type: "mood".to_string(),
            elem_kind: Box::new(TypeKind::Enum(vec![
                "sad".to_string(),
                "ok".to_string(),
                "happy".to_string(),
            ])),
        }
    );

    db.generate(&schema, 20).await;
    let invalid: i64 = db
        .client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{}\".people p \
                 WHERE EXISTS (SELECT 1 FROM unnest(p.recent_moods) mood \
                               WHERE mood NOT IN ('sad', 'ok', 'happy'))",
                db.schema_name
            ),
            &[],
        )
        .await
        .expect("query generated enum arrays")
        .get(0);
    assert_eq!(invalid, 0, "generated an undeclared enum-array element");
}

#[tokio::test]
async fn tsvector_columns_receive_valid_nonempty_vectors() {
    let mut db = TestDb::setup(
        "tsvector_generation",
        "CREATE TABLE searchable_documents (\
             id serial PRIMARY KEY, \
             document_vectors tsvector NOT NULL\
         ); \
         CREATE TABLE document_comments (\
             id serial PRIMARY KEY, \
             document_id integer NOT NULL REFERENCES searchable_documents(id)\
         );",
    )
    .await;
    let schema = db.introspect().await;

    db.generate(&schema, 20).await;
    let empty_vectors: i64 = db
        .client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{}\".searchable_documents \
                 WHERE length(document_vectors::text) = 0",
                db.schema_name
            ),
            &[],
        )
        .await
        .expect("query generated tsvectors")
        .get(0);
    assert_eq!(empty_vectors, 0, "generated an empty tsvector");
}

#[tokio::test]
async fn unreferenced_server_assigned_only_table_inserts_every_planned_row() {
    let mut db = TestDb::setup(
        "unreferenced_server_assigned_only",
        "CREATE TABLE standalone_ids (id serial PRIMARY KEY);",
    )
    .await;
    let schema = db.introspect().await;

    let summary = db.generate(&schema, 20).await;
    assert_eq!(summary.total_rows, 20);
    let actual: i64 = db
        .client
        .query_one(
            &format!("SELECT count(*) FROM \"{}\".standalone_ids", db.schema_name),
            &[],
        )
        .await
        .expect("count generated standalone ids")
        .get(0);
    assert_eq!(actual, 20, "reported rows were not actually inserted");
}

#[tokio::test]
async fn referenced_server_assigned_only_table_populates_the_fk_pool() {
    let mut db = TestDb::setup(
        "referenced_server_assigned_only",
        "CREATE TABLE parent_ids (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY); \
         CREATE TABLE children (\
             id serial PRIMARY KEY, \
             parent_id bigint NOT NULL REFERENCES parent_ids(id)\
         );",
    )
    .await;
    let schema = db.introspect().await;

    let summary = db.generate(&schema, 20).await;
    assert_eq!(summary.total_rows, 40);
    db.assert_no_orphans(&schema).await;
    let actual: i64 = db
        .client
        .query_one(
            &format!("SELECT count(*) FROM \"{}\".parent_ids", db.schema_name),
            &[],
        )
        .await
        .expect("count generated parent ids")
        .get(0);
    assert_eq!(
        actual, 20,
        "server-assigned keys were not returned and pooled"
    );
}

#[tokio::test]
async fn geometric_columns_receive_valid_values_for_every_builtin_type() {
    let mut db = TestDb::setup(
        "geometric_types",
        "CREATE TABLE geometry_samples (\
             id serial PRIMARY KEY, \
             location point NOT NULL, \
             boundary line NOT NULL, \
             segment lseg NOT NULL, \
             bounds box NOT NULL, \
             route path NOT NULL, \
             area polygon NOT NULL, \
             radius circle NOT NULL\
         ); \
         CREATE TABLE geometry_references (\
             id serial PRIMARY KEY, \
             sample_id integer NOT NULL REFERENCES geometry_samples(id)\
         );",
    )
    .await;
    let schema = db.introspect().await;

    let summary = db.generate(&schema, 20).await;
    assert_eq!(summary.total_rows, 40);
    let actual: i64 = db
        .client
        .query_one(
            &format!(
                "SELECT count(*) FROM \"{}\".geometry_samples \
                 WHERE location IS NOT NULL AND boundary IS NOT NULL \
                   AND segment IS NOT NULL AND bounds IS NOT NULL \
                   AND route IS NOT NULL AND area IS NOT NULL AND radius IS NOT NULL",
                db.schema_name
            ),
            &[],
        )
        .await
        .expect("query generated geometric values")
        .get(0);
    assert_eq!(actual, 20);
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
