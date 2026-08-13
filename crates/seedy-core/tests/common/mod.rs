//! Shared integration-test harness: one Postgres container per test
//! binary process (not per test — container startup dominates otherwise),
//! with each test isolating itself into its own schema so tests can run
//! concurrently without stepping on each other.

use std::sync::OnceLock;

use seedy_core::config::SeedyConfig;
use seedy_core::introspect::Schema;
use seedy_core::{graph, insert};
use testcontainers::runners::AsyncRunner;
use testcontainers::{ContainerAsync, ImageExt};
use testcontainers_modules::postgres::Postgres;
use tokio::sync::OnceCell;
use tokio_postgres::{Client, NoTls};

static CONTAINER: OnceCell<ContainerAsync<Postgres>> = OnceCell::const_new();
static PORT: OnceLock<u16> = OnceLock::new();

async fn shared_port() -> u16 {
    if let Some(&p) = PORT.get() {
        return p;
    }
    let container = CONTAINER
        .get_or_init(|| async {
            // The crate's default tag (11-alpine) predates several
            // catalog columns seedy relies on (e.g. `pg_attribute
            // .attgenerated`, added in PG12) — pin a modern version.
            Postgres::default()
                .with_tag("16-alpine")
                .start()
                .await
                .expect("start postgres testcontainer (is Docker running?)")
        })
        .await;
    let port = container
        .get_host_port_ipv4(5432)
        .await
        .expect("mapped port");
    let _ = PORT.set(port);
    port
}

pub struct TestDb {
    pub client: Client,
    pub schema_name: String,
}

impl TestDb {
    /// Spin up (or reuse) the shared container, create a fresh schema
    /// named after the test, and run `ddl` against it with that schema
    /// first on the search_path.
    pub async fn setup(test_name: &str, ddl: &str) -> Self {
        let port = shared_port().await;
        let conn =
            format!("host=127.0.0.1 port={port} user=postgres password=postgres dbname=postgres");
        let (client, connection) = tokio_postgres::connect(&conn, NoTls)
            .await
            .expect("connect");
        tokio::spawn(async move {
            let _ = connection.await;
        });

        let schema_name = format!("test_{test_name}");
        client
            .batch_execute(&format!(
                "DROP SCHEMA IF EXISTS \"{schema_name}\" CASCADE; CREATE SCHEMA \"{schema_name}\";"
            ))
            .await
            .expect("create test schema");
        client
            .batch_execute(&format!("SET search_path TO \"{schema_name}\", public"))
            .await
            .expect("set search_path");
        client.batch_execute(ddl).await.unwrap_or_else(|e| {
            panic!("fixture DDL failed for `{test_name}`: {e}");
        });

        Self {
            client,
            schema_name,
        }
    }

    pub async fn introspect(&self) -> Schema {
        seedy_core::introspect::introspect(&self.client, std::slice::from_ref(&self.schema_name))
            .await
            .expect("introspect")
    }

    /// Run the full generate+insert pipeline with `rows` rows per table,
    /// inside its own transaction, and commit. Panics (failing the test)
    /// on any error — callers that expect a specific error should call
    /// `graph::plan_insertion` / `insert::run` directly instead.
    pub async fn generate(&mut self, schema: &Schema, rows: u32) -> insert::RunSummary {
        let config = seedy_test_config(schema, rows);
        let plan = graph::plan_insertion(schema).expect("insertion plan");
        let txn = self.client.transaction().await.expect("begin txn");
        let summary = insert::run(&txn, schema, &plan, &config, |_| {})
            .await
            .expect("seedy up run");
        txn.commit().await.expect("commit");
        summary
    }

    /// Generic FK-integrity check: for every FK in the schema, assert
    /// there are zero rows whose (non-null) FK columns don't match some
    /// row in the referenced table. Works for any schema shape, so every
    /// fixture test gets this assertion for free.
    pub async fn assert_no_orphans(&self, schema: &Schema) {
        for table in &schema.tables {
            for fk in &table.foreign_keys {
                let join = fk
                    .columns
                    .iter()
                    .zip(&fk.ref_columns)
                    .map(|(c, r)| format!("c.\"{c}\" = p.\"{r}\""))
                    .collect::<Vec<_>>()
                    .join(" AND ");
                let not_null = fk
                    .columns
                    .iter()
                    .map(|c| format!("c.\"{c}\" IS NOT NULL"))
                    .collect::<Vec<_>>()
                    .join(" AND ");
                let sql = format!(
                    "SELECT count(*) FROM \"{}\".\"{}\" c LEFT JOIN \"{}\".\"{}\" p ON {join} \
                     WHERE {not_null} AND p.\"{}\" IS NULL",
                    table.id.schema,
                    table.id.name,
                    fk.ref_table.schema,
                    fk.ref_table.name,
                    fk.ref_columns[0]
                );
                let row = self
                    .client
                    .query_one(&sql, &[])
                    .await
                    .expect("orphan check query");
                let count: i64 = row.get(0);
                assert_eq!(
                    count,
                    0,
                    "found {count} orphaned rows in `{}` for FK `{}` -> `{}`",
                    table.id.qualified(),
                    fk.name,
                    fk.ref_table.qualified()
                );
            }
        }
    }
}

fn seedy_test_config(schema: &Schema, rows: u32) -> SeedyConfig {
    let mut config = SeedyConfig::from_schema(schema);
    for table_config in config.tables.values_mut() {
        table_config.rows = rows;
    }
    config
}
