mod common;

use std::collections::BTreeMap;

use common::{CloneFixture, TestDb};
use feint_core::config::FeintConfig;
use feint_core::graph::plan_insertion;
use feint_core::introspect::introspect;
use feint_core::snapshot;

fn empty_config() -> FeintConfig {
    FeintConfig {
        version: 1,
        seed: "default".to_string(),
        tables: BTreeMap::new(),
    }
}

/// Comfortably past the old chunked-`INSERT` ceiling (500 rows per
/// statement, `MAX_BATCH_ROWS` in `insert.rs`) — the old path would have
/// needed 40+ separate `INSERT` statements for this; the `COPY` path
/// needs one stream, flushed in 5,000-row chunks internally.
const VOLUME: usize = 20_000;

#[tokio::test]
async fn clone_handles_row_counts_well_beyond_the_old_batch_chunk_size() {
    let ddl =
        "CREATE TABLE events (id serial PRIMARY KEY, kind text NOT NULL, amount integer NOT NULL);";
    let mut db = CloneFixture::setup("copy_volume_clone", ddl, ddl).await;

    let values: Vec<String> = (0..VOLUME)
        .map(|i| format!("('kind{}', {i})", i % 7))
        .collect();
    db.source_client
        .batch_execute(&format!(
            "INSERT INTO events (kind, amount) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let summary = db
        .clone(&schema, &empty_config())
        .await
        .expect("clone should handle this row count in one COPY stream");
    assert_eq!(summary.total_rows, VOLUME as u64);

    let schema_name = &db.schema_name;
    let count: i64 = db
        .target_client
        .query_one(
            &format!("SELECT count(*) FROM \"{schema_name}\".events"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, VOLUME as i64);

    // Not just a count: every row's value must have actually landed
    // correctly, not been truncated, duplicated, or corrupted mid-stream.
    let checksum: i64 = db
        .target_client
        .query_one(
            &format!("SELECT sum(amount) FROM \"{schema_name}\".events"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    let expected: i64 = (0..VOLUME as i64).sum();
    assert_eq!(checksum, expected);

    let sample = db
        .target_client
        .query_one(
            &format!("SELECT kind, amount FROM \"{schema_name}\".events WHERE id = 12345"),
            &[],
        )
        .await
        .unwrap();
    let kind: String = sample.get(0);
    let amount: i32 = sample.get(1);
    assert_eq!(kind, "kind3"); // 12344 % 7 == 3, id is 1-indexed so row 12345 has amount 12344
    assert_eq!(amount, 12344);
}

#[tokio::test]
async fn special_characters_survive_a_real_copy_round_trip() {
    let ddl = "CREATE TABLE notes (id serial PRIMARY KEY, body text, tags text[]);";
    let mut db = CloneFixture::setup("copy_special_chars", ddl, ddl).await;

    // Deliberately exercises every character COPY's text format treats
    // specially (tab, newline, carriage return, backslash) plus non-ASCII
    // text and a NULL, inserted as real Postgres values (not string
    // literals feint has to parse) so this proves the encode -> COPY ->
    // Postgres-parses-it-back round trip, not just the encoder in
    // isolation.
    db.source_client
        .execute(
            "INSERT INTO notes (body, tags) VALUES ($1, $2), ($3, $4), ($5, $6)",
            &[
                &"line one\nline two\ttabbed\r\nwindows-style",
                &vec!["a,b", "c\"d"],
                &"backslash \\ and unicode caf\u{e9} \u{1f600}",
                &vec!["x\\y"],
                &Option::<String>::None,
                &Option::<Vec<String>>::None,
            ],
        )
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    db.clone(&schema, &empty_config())
        .await
        .expect("clone should succeed");

    let schema_name = &db.schema_name;
    let rows = db
        .target_client
        .query(
            &format!("SELECT body, tags FROM \"{schema_name}\".notes ORDER BY id"),
            &[],
        )
        .await
        .unwrap();

    let body1: String = rows[0].get(0);
    let tags1: Vec<String> = rows[0].get(1);
    assert_eq!(body1, "line one\nline two\ttabbed\r\nwindows-style");
    assert_eq!(tags1, vec!["a,b".to_string(), "c\"d".to_string()]);

    let body2: String = rows[1].get(0);
    let tags2: Vec<String> = rows[1].get(1);
    assert_eq!(body2, "backslash \\ and unicode caf\u{e9} \u{1f600}");
    assert_eq!(tags2, vec!["x\\y".to_string()]);

    let body3: Option<String> = rows[2].get(0);
    let tags3: Option<Vec<String>> = rows[2].get(1);
    assert_eq!(body3, None);
    assert_eq!(tags3, None);
}

#[tokio::test]
async fn generate_mode_pads_an_unreferenced_leaf_table_at_volume() {
    let mut db = TestDb::setup(
        "copy_volume_generate",
        "CREATE TABLE events (id serial PRIMARY KEY, payload text NOT NULL);",
    )
    .await;
    let schema = db.introspect().await;
    let summary = db.generate(&schema, VOLUME as u32).await;
    assert_eq!(summary.total_rows, VOLUME as u64);

    let count: i64 = db
        .client
        .query_one("SELECT count(*) FROM events", &[])
        .await
        .unwrap()
        .get(0);
    assert_eq!(count, VOLUME as i64);

    // Real per-row generation, not a degenerate "every row identical" bug
    // — the exact failure mode the post-mask verification pass (verify.rs)
    // watches for in a different context.
    let distinct: i64 = db
        .client
        .query_one("SELECT count(DISTINCT payload) FROM events", &[])
        .await
        .unwrap()
        .get(0);
    assert!(
        distinct > VOLUME as i64 / 2,
        "expected mostly-distinct generated payloads, got {distinct} distinct out of {VOLUME}"
    );
}

#[tokio::test]
async fn snapshot_restore_handles_volume_through_a_real_file() {
    let ddl = "CREATE TABLE events (id serial PRIMARY KEY, amount integer NOT NULL);";
    let mut db = CloneFixture::setup("copy_volume_snapshot", ddl, ddl).await;

    let values: Vec<String> = (0..VOLUME).map(|i| format!("({i})")).collect();
    db.source_client
        .batch_execute(&format!(
            "INSERT INTO events (amount) VALUES {}",
            values.join(", ")
        ))
        .await
        .unwrap();

    let schema = db.introspect_source().await;
    let source_txn = db
        .source_client
        .build_transaction()
        .read_only(true)
        .start()
        .await
        .unwrap();
    let captured = snapshot::capture(&source_txn, &schema, &empty_config(), None)
        .await
        .unwrap();
    source_txn.rollback().await.ok();
    assert_eq!(captured.total_rows(), VOLUME as u64);

    let path = std::env::temp_dir().join(format!(
        "feint-copy-volume-snapshot-{}.bin",
        std::process::id()
    ));
    captured.write_to_file(&path).unwrap();
    let loaded = snapshot::SnapshotFile::read_from_file(&path).unwrap();

    let target_schema = introspect(&db.target_client, std::slice::from_ref(&db.schema_name))
        .await
        .unwrap();
    let plan = plan_insertion(&target_schema).unwrap();
    let target_txn = db.target_client.transaction().await.unwrap();
    let summary = snapshot::restore(&target_txn, &target_schema, &plan, &loaded)
        .await
        .expect("restore should handle this row count in one COPY stream");
    target_txn.commit().await.unwrap();
    assert_eq!(summary.total_rows, VOLUME as u64);

    let schema_name = &db.schema_name;
    let checksum: i64 = db
        .target_client
        .query_one(
            &format!("SELECT sum(amount) FROM \"{schema_name}\".events"),
            &[],
        )
        .await
        .unwrap()
        .get(0);
    let expected: i64 = (0..VOLUME as i64).sum();
    assert_eq!(checksum, expected);

    let _ = std::fs::remove_file(&path);
}
