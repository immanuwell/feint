//! Proves the guarantee documented in DOCS.md under "Deterministic
//! identity": the same seed applied to the same real row produces the
//! same fake value, whether that row is reached through `clone`
//! (source DB -> target DB) or through `mask` (one DB, in place).
//!
//! This mirrors the real-world shape: a snapshot-restore workflow
//! produces a database with the same schema name and the same rows as
//! the source, whether you `clone` from the original or `mask` a
//! restored copy of it. Both paths key their masking off the row's real
//! primary key, so they must agree.

mod common;

use common::{CloneFixture, TestDb};
use feint_core::config::{ColumnConfig, FeintConfig, TableConfig};
use feint_core::mask::MaskStrategy;
use feint_core::sanitize::{self, ProgressEvent};
use std::collections::BTreeMap;

const USERS_DDL: &str = "
    CREATE TABLE users (
        id serial PRIMARY KEY,
        email text NOT NULL,
        name text NOT NULL
    );
";

const SEED: &str = "identity-check";

fn mask_config(table: &str) -> FeintConfig {
    let mut cols = BTreeMap::new();
    cols.insert(
        "email".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Fake),
            json_paths: Default::default(),
        },
    );
    cols.insert(
        "name".to_string(),
        ColumnConfig {
            generator: None,
            mask: Some(MaskStrategy::Fake),
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
        },
    );
    FeintConfig {
        version: 1,
        seed: SEED.to_string(),
        tables,
    }
}

const SEED_ROWS: &str = "INSERT INTO users (email, name) VALUES \
    ('alice@corp.com', 'Alice Thompson'), \
    ('bob@corp.com', 'Bob Nguyen'), \
    ('carol@corp.com', 'Carol Diaz');";

#[tokio::test]
async fn same_seed_same_row_masks_identically_via_clone_and_via_mask_in_place() {
    // Path 1: clone (source -> target), masking as it streams.
    let mut clone_db = CloneFixture::setup("cross_mode_identity", USERS_DDL, USERS_DDL).await;
    clone_db
        .source_client
        .batch_execute(SEED_ROWS)
        .await
        .unwrap();
    let schema = clone_db.introspect_source().await;
    let config = mask_config(&format!("{}.users", clone_db.schema_name));
    clone_db
        .clone(&schema, &config)
        .await
        .expect("clone should succeed");

    let cloned_rows = clone_db
        .target_client
        .query(
            &format!(
                "SELECT id, email, name FROM \"{}\".users ORDER BY id",
                clone_db.schema_name
            ),
            &[],
        )
        .await
        .unwrap();

    // Path 2: an independently-restored copy of the same data, masked
    // in place. Same schema name as the clone fixture on purpose — a
    // real snapshot restore preserves the schema name too.
    let mut stage_db = TestDb::setup("cross_mode_identity", USERS_DDL).await;
    stage_db.client.batch_execute(SEED_ROWS).await.unwrap();
    let stage_schema = stage_db.introspect().await;
    let stage_plan = sanitize::plan_sanitization(&stage_schema, &config).unwrap();
    sanitize::run_sanitization(
        &mut stage_db.client,
        &stage_schema,
        &stage_plan,
        &config,
        100,
        false,
        None,
        |_: ProgressEvent| {},
    )
    .await
    .unwrap();

    let staged_rows = stage_db
        .client
        .query("SELECT id, email, name FROM users ORDER BY id", &[])
        .await
        .unwrap();

    assert_eq!(cloned_rows.len(), 3);
    assert_eq!(staged_rows.len(), 3);

    for (cloned, staged) in cloned_rows.iter().zip(staged_rows.iter()) {
        let id: i32 = cloned.get(0);
        assert_eq!(id, staged.get::<_, i32>(0));

        let cloned_email: String = cloned.get(1);
        let staged_email: String = staged.get(1);
        let cloned_name: String = cloned.get(2);
        let staged_name: String = staged.get(2);

        assert_eq!(
            cloned_email, staged_email,
            "user {id}: clone and mask must agree on the masked email"
        );
        assert_eq!(
            cloned_name, staged_name,
            "user {id}: clone and mask must agree on the masked name"
        );
        assert_ne!(cloned_email, "", "masked email should not be empty");
    }

    // And prove it actually masked something, not just passed values through.
    assert_ne!(
        cloned_rows[0].get::<_, String>(1),
        "alice@corp.com",
        "email should have been replaced, not passed through"
    );
}
