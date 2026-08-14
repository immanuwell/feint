//! A single, narrated pass over every "nasty" Postgres schema fixture,
//! printing a report meant to be pasted straight into a README or a
//! terminal recording. `nasty_schemas.rs` is the real, parallelized,
//! per-fixture test suite — this file re-runs the same fixtures serially
//! purely to produce one clean, ordered transcript.
//!
//! Run it with: `cargo test --test correctness_demo -- --nocapture`

mod common;

use common::TestDb;
use feint_core::graph::plan_insertion;

const GENERATE_FIXTURES: &[(&str, &str)] = &[
    (
        "composite_fk",
        include_str!("fixtures/schemas/composite_fk.sql"),
    ),
    (
        "self_ref_fk",
        include_str!("fixtures/schemas/self_ref_fk.sql"),
    ),
    (
        "cycle_nullable",
        include_str!("fixtures/schemas/cycle_nullable.sql"),
    ),
    (
        "cycle_deferred",
        include_str!("fixtures/schemas/cycle_deferred.sql"),
    ),
    ("enums", include_str!("fixtures/schemas/enums.sql")),
    ("domains", include_str!("fixtures/schemas/domains.sql")),
    ("arrays", include_str!("fixtures/schemas/arrays.sql")),
    ("jsonb", include_str!("fixtures/schemas/jsonb.sql")),
    ("citext", include_str!("fixtures/schemas/citext.sql")),
    ("inet_cidr", include_str!("fixtures/schemas/inet_cidr.sql")),
    ("uuid_pk", include_str!("fixtures/schemas/uuid_pk.sql")),
    (
        "identity_serial",
        include_str!("fixtures/schemas/identity_serial.sql"),
    ),
    (
        "partitioned",
        include_str!("fixtures/schemas/partitioned.sql"),
    ),
];

#[tokio::test]
async fn correctness_demo() {
    println!();
    println!("Nasty Postgres schema correctness check");
    println!("========================================");

    let mut checks = 0usize;

    for (name, ddl) in GENERATE_FIXTURES {
        let mut db = TestDb::setup(name, ddl).await;
        let schema = db.introspect().await;
        let summary = db.generate(&schema, 20).await;
        db.assert_no_orphans(&schema).await;
        let rows: u64 = summary.rows_by_table.iter().map(|(_, n)| n).sum();
        println!("✓ {name:<26} {rows:>4} rows generated, 0 constraint violations");
        checks += 1;
    }

    {
        let db = TestDb::setup(
            "cycle_hard_unsatisfiable",
            include_str!("fixtures/schemas/cycle_hard_unsatisfiable.sql"),
        )
        .await;
        let schema = db.introspect().await;
        assert!(
            plan_insertion(&schema).is_err(),
            "expected a NOT NULL, non-deferrable FK cycle to be rejected before any insert"
        );
        println!(
            "✓ {:<26} correctly rejected before any write",
            "cycle_hard_unsatisfiable"
        );
        checks += 1;
    }

    {
        let db = TestDb::setup(
            "check_constraints",
            include_str!("fixtures/schemas/check_constraints.sql"),
        )
        .await;
        let schema = db.introspect().await;
        let has_checks = schema
            .tables
            .iter()
            .any(|t| !t.check_constraints.is_empty());
        assert!(has_checks, "expected CHECK constraints to be introspected");
        println!(
            "✓ {:<26} CHECK constraints introspected and annotated",
            "check_constraints"
        );
        checks += 1;
    }

    println!();
    println!("{checks}/{checks} nasty schemas handled correctly");
    println!("0 constraint violations");
    println!();
}
