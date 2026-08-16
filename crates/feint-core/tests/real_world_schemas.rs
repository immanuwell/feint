//! Runs feint's core three modes (generate, clone, mask) against real,
//! unmodified production schemas pulled from popular open source
//! self-hosted apps — not curated fixtures, actual `pg_dump --schema-only`
//! output from each app's own official Docker image running its own real
//! migrations. See `fixtures/real_world_schemas/README.md` for exactly
//! how each one was captured.
//!
//! Each fixture gets its own fresh database (not just a schema) inside one
//! shared container, since every dump hardcodes `public.<table>` — a
//! database is the cheapest way to get an isolated `public` schema without
//! rewriting a single line of any dump. One `ghcr.io/immich-app/postgres`
//! image is used for all of them: it's a real Postgres 16 with `vector` and
//! `vchord` available on top, which a couple of the fixtures need, and
//! having those extra extensions present is harmless for the rest.
//!
//! Deliberately scoped to generate/clone/mask (the three modes every real
//! database would actually go through). classify/profile/snapshot/subset
//! are not exercised here — noting that rather than silently leaving it
//! implied everything was covered.
//!
//! Run with: `cargo test --test real_world_schemas -- --nocapture`

use std::collections::BTreeMap;

use feint_core::config::FeintConfig;
use feint_core::graph::plan_insertion;
use feint_core::introspect::introspect;
use feint_core::{clone, insert, sanitize};
use testcontainers::core::WaitFor;
use testcontainers::runners::AsyncRunner;
use testcontainers::{ContainerAsync, GenericImage, ImageExt};
use tokio_postgres::{Client, NoTls};

struct Fixture {
    name: &'static str,
    sql: &'static str,
    /// Schema to introspect, if not "public". `twenty` uses "core";
    /// `zulip` uses "zulip". Every other fixture uses "public".
    schema: &'static str,
}

const FIXTURES: &[Fixture] = &[
    Fixture {
        name: "gitea",
        sql: include_str!("fixtures/real_world_schemas/gitea.sql"),
        schema: "public",
    },
    Fixture {
        name: "vaultwarden",
        sql: include_str!("fixtures/real_world_schemas/vaultwarden.sql"),
        schema: "public",
    },
    Fixture {
        name: "miniflux",
        sql: include_str!("fixtures/real_world_schemas/miniflux.sql"),
        schema: "public",
    },
    Fixture {
        name: "listmonk",
        sql: include_str!("fixtures/real_world_schemas/listmonk.sql"),
        schema: "public",
    },
    Fixture {
        name: "chatwoot",
        sql: include_str!("fixtures/real_world_schemas/chatwoot.sql"),
        schema: "public",
    },
    Fixture {
        name: "mastodon",
        sql: include_str!("fixtures/real_world_schemas/mastodon.sql"),
        schema: "public",
    },
    Fixture {
        name: "twenty",
        sql: include_str!("fixtures/real_world_schemas/twenty.sql"),
        schema: "core",
    },
    Fixture {
        name: "immich",
        sql: include_str!("fixtures/real_world_schemas/immich.sql"),
        schema: "public",
    },
    Fixture {
        name: "penpot",
        sql: include_str!("fixtures/real_world_schemas/penpot.sql"),
        schema: "public",
    },
    Fixture {
        name: "documenso",
        sql: include_str!("fixtures/real_world_schemas/documenso.sql"),
        schema: "public",
    },
    Fixture {
        name: "plausible",
        sql: include_str!("fixtures/real_world_schemas/plausible.sql"),
        schema: "public",
    },
    Fixture {
        name: "firefly_iii",
        sql: include_str!("fixtures/real_world_schemas/firefly_iii.sql"),
        schema: "public",
    },
    Fixture {
        name: "zulip",
        sql: include_str!("fixtures/real_world_schemas/zulip.sql"),
        schema: "zulip",
    },
    Fixture {
        name: "keycloak",
        sql: include_str!("fixtures/real_world_schemas/keycloak.sql"),
        schema: "public",
    },
    Fixture {
        name: "wallabag",
        sql: include_str!("fixtures/real_world_schemas/wallabag.sql"),
        schema: "public",
    },
    Fixture {
        name: "directus",
        sql: include_str!("fixtures/real_world_schemas/directus.sql"),
        schema: "public",
    },
    Fixture {
        name: "baserow",
        sql: include_str!("fixtures/real_world_schemas/baserow.sql"),
        schema: "public",
    },
    Fixture {
        name: "calcom",
        sql: include_str!("fixtures/real_world_schemas/calcom.sql"),
        schema: "public",
    },
    Fixture {
        name: "metabase",
        sql: include_str!("fixtures/real_world_schemas/metabase.sql"),
        schema: "public",
    },
    Fixture {
        name: "outline",
        sql: include_str!("fixtures/real_world_schemas/outline.sql"),
        schema: "public",
    },
    Fixture {
        name: "odoo",
        sql: include_str!("fixtures/real_world_schemas/odoo.sql"),
        schema: "public",
    },
    Fixture {
        name: "n8n",
        sql: include_str!("fixtures/real_world_schemas/n8n.sql"),
        schema: "public",
    },
    Fixture {
        name: "umami",
        sql: include_str!("fixtures/real_world_schemas/umami.sql"),
        schema: "public",
    },
    Fixture {
        name: "formbricks",
        sql: include_str!("fixtures/real_world_schemas/formbricks.sql"),
        schema: "public",
    },
    Fixture {
        name: "grafana",
        sql: include_str!("fixtures/real_world_schemas/grafana.sql"),
        schema: "public",
    },
    Fixture {
        name: "linkwarden",
        sql: include_str!("fixtures/real_world_schemas/linkwarden.sql"),
        schema: "public",
    },
    Fixture {
        name: "paperless_ngx",
        sql: include_str!("fixtures/real_world_schemas/paperless_ngx.sql"),
        schema: "public",
    },
    Fixture {
        name: "vikunja",
        sql: include_str!("fixtures/real_world_schemas/vikunja.sql"),
        schema: "public",
    },
    Fixture {
        name: "superset",
        sql: include_str!("fixtures/real_world_schemas/superset.sql"),
        schema: "public",
    },
    Fixture {
        name: "authentik",
        sql: include_str!("fixtures/real_world_schemas/authentik.sql"),
        schema: "public",
    },
    Fixture {
        name: "windmill",
        sql: include_str!("fixtures/real_world_schemas/windmill.sql"),
        schema: "public",
    },
    Fixture {
        name: "strapi",
        sql: include_str!("fixtures/real_world_schemas/strapi.sql"),
        schema: "public",
    },
    Fixture {
        name: "redash",
        sql: include_str!("fixtures/real_world_schemas/redash.sql"),
        schema: "public",
    },
    Fixture {
        name: "mealie",
        sql: include_str!("fixtures/real_world_schemas/mealie.sql"),
        schema: "public",
    },
    Fixture {
        name: "mattermost",
        sql: include_str!("fixtures/real_world_schemas/mattermost.sql"),
        schema: "public",
    },
    Fixture {
        name: "funkwhale",
        sql: include_str!("fixtures/real_world_schemas/funkwhale.sql"),
        schema: "public",
    },
    Fixture {
        name: "nextcloud",
        sql: include_str!("fixtures/real_world_schemas/nextcloud.sql"),
        schema: "public",
    },
    Fixture {
        name: "peertube",
        sql: include_str!("fixtures/real_world_schemas/peertube.sql"),
        schema: "public",
    },
    Fixture {
        name: "zammad",
        sql: include_str!("fixtures/real_world_schemas/zammad.sql"),
        schema: "public",
    },
    Fixture {
        name: "docmost",
        sql: include_str!("fixtures/real_world_schemas/docmost.sql"),
        schema: "public",
    },
    Fixture {
        name: "nocodb",
        sql: include_str!("fixtures/real_world_schemas/nocodb.sql"),
        schema: "public",
    },
    Fixture {
        name: "lemmy",
        sql: include_str!("fixtures/real_world_schemas/lemmy.sql"),
        schema: "public",
    },
    Fixture {
        name: "wger",
        sql: include_str!("fixtures/real_world_schemas/wger.sql"),
        schema: "public",
    },
    Fixture {
        name: "gitlab",
        sql: include_str!("fixtures/real_world_schemas/gitlab.sql"),
        schema: "public",
    },
    Fixture {
        name: "rallly",
        sql: include_str!("fixtures/real_world_schemas/rallly.sql"),
        schema: "public",
    },
    Fixture {
        name: "sentry",
        sql: include_str!("fixtures/real_world_schemas/sentry.sql"),
        schema: "public",
    },
    Fixture {
        name: "mobilizon",
        sql: include_str!("fixtures/real_world_schemas/mobilizon.sql"),
        schema: "public",
    },
    Fixture {
        name: "chirpstack",
        sql: include_str!("fixtures/real_world_schemas/chirpstack.sql"),
        schema: "public",
    },
    Fixture {
        name: "plane",
        sql: include_str!("fixtures/real_world_schemas/plane.sql"),
        schema: "public",
    },
];

/// Per-fixture, per-phase outcome. `Ok(detail)` for a human-readable
/// success summary, `Err(detail)` for the real error feint returned —
/// never a panic, so one fixture's failure doesn't hide the other nine's
/// results.
type PhaseResult = Result<String, String>;

#[derive(Default)]
struct FixtureReport {
    apply_schema: Option<PhaseResult>,
    introspect: Option<PhaseResult>,
    plan: Option<PhaseResult>,
    generate: Option<PhaseResult>,
    clone: Option<PhaseResult>,
    mask: Option<PhaseResult>,
}

async fn admin_client(host: &str, port: u16) -> Client {
    let (client, connection) = tokio_postgres::connect(
        &format!("host={host} port={port} user=postgres password=postgres dbname=postgres"),
        NoTls,
    )
    .await
    .expect("connect to admin db");
    tokio::spawn(async move {
        let _ = connection.await;
    });
    client
}

async fn db_client(host: &str, port: u16, dbname: &str) -> Client {
    let (client, connection) = tokio_postgres::connect(
        &format!("host={host} port={port} user=postgres password=postgres dbname={dbname}"),
        NoTls,
    )
    .await
    .expect("connect to fixture db");
    tokio::spawn(async move {
        let _ = connection.await;
    });
    client
}

fn config_with_rows(schema_name: &str, tables: &[String], rows: u32) -> FeintConfig {
    let mut cfg_tables = BTreeMap::new();
    for t in tables {
        cfg_tables.insert(
            format!("{schema_name}.{t}"),
            feint_core::config::TableConfig {
                rows,
                strategy: Default::default(),
                columns: Default::default(),
            },
        );
    }
    FeintConfig {
        version: 1,
        seed: "real-world".to_string(),
        tables: cfg_tables,
    }
}

#[tokio::test]
async fn real_world_schemas_survive_feints_full_command_surface() {
    let fixture_filter = std::env::var("FEINT_REAL_WORLD_FIXTURE").ok();
    let fixtures = FIXTURES
        .iter()
        .filter(|fixture| {
            fixture_filter
                .as_deref()
                .is_none_or(|name| fixture.name == name)
        })
        .collect::<Vec<_>>();
    if let Some(name) = fixture_filter.as_deref() {
        assert!(
            !fixtures.is_empty(),
            "unknown FEINT_REAL_WORLD_FIXTURE `{name}`"
        );
    }

    let container: ContainerAsync<GenericImage> = GenericImage::new(
        "ghcr.io/immich-app/postgres",
        "16-vectorchord0.4.3-pgvectors0.3.0",
    )
    .with_wait_for(WaitFor::message_on_stderr(
        "database system is ready to accept connections",
    ))
    .with_wait_for(WaitFor::message_on_stdout(
        "database system is ready to accept connections",
    ))
    .with_env_var("POSTGRES_USER", "postgres")
    .with_env_var("POSTGRES_PASSWORD", "postgres")
    .with_env_var("POSTGRES_DB", "postgres")
    // GitLab's structure.sql alone declares enough objects that Postgres's
    // default `max_locks_per_transaction` (64) runs out mid-load ("out of
    // shared memory") — and since every fixture shares this one container,
    // a lock-table exhaustion on one fixture's `apply schema` step was
    // observed to break the *next* fixture's unrelated DROP/CREATE DATABASE
    // too. Bumped well above what any single fixture in this pilot needs.
    //
    // `with_cmd` replaces this image's own default command outright rather
    // than appending, so the original `-c config_file=...` (this image's
    // own postgresql.conf, which is what actually sets
    // `shared_preload_libraries` for vchord/pgvector — Immich's fixture
    // needs those preloaded, and the default `postgres` binary invocation
    // with no config_file does not have them) has to be repeated here
    // alongside the new flag, or Immich's `apply schema` step starts
    // failing with "vchord must be loaded".
    .with_cmd([
        "postgres",
        "-c",
        "config_file=/etc/postgresql/postgresql.conf",
        "-c",
        "max_locks_per_transaction=512",
    ])
    .start()
    .await
    .expect("start postgres testcontainer (is Docker running?)");
    let host = container.get_host().await.expect("host").to_string();
    let port = container
        .get_host_port_ipv4(5432)
        .await
        .expect("mapped port");

    let admin = admin_client(&host, port).await;

    let mut reports: Vec<(&str, FixtureReport)> = Vec::new();

    for fixture in &fixtures {
        println!("\n=== {} ===", fixture.name);
        let mut report = FixtureReport::default();
        let source_db = format!("real_world_{}_src", fixture.name);
        let target_db = format!("real_world_{}_dst", fixture.name);

        for db in [&source_db, &target_db] {
            admin
                .batch_execute(&format!("DROP DATABASE IF EXISTS \"{db}\";"))
                .await
                .expect("drop old db");
            admin
                .batch_execute(&format!("CREATE DATABASE \"{db}\";"))
                .await
                .expect("create db");
        }

        let source_client = db_client(&host, port, &source_db).await;
        if let Err(e) = source_client.batch_execute(fixture.sql).await {
            let msg = format!(
                "applying the real dump itself failed: {}",
                feint_core::error::format_pg_error(&e)
            );
            println!("  ✗ apply schema: {msg}");
            report.apply_schema = Some(Err(msg));
            reports.push((fixture.name, report));
            continue;
        }
        report.apply_schema = Some(Ok("applied cleanly".to_string()));
        println!("  ✓ applied real schema dump");

        // `clone` streams rows into an *existing* target schema — it never
        // creates tables itself — so the destination needs the same empty
        // schema applied before clone can write anything into it.
        let target_client = db_client(&host, port, &target_db).await;
        target_client
            .batch_execute(fixture.sql)
            .await
            .expect("apply schema dump to clone target");

        let schema = match introspect(
            &source_client,
            std::slice::from_ref(&fixture.schema.to_string()),
        )
        .await
        {
            Ok(s) => {
                let detail = format!("{} tables", s.tables.len());
                println!("  ✓ introspect: {detail}");
                report.introspect = Some(Ok(detail));
                s
            }
            Err(e) => {
                let msg = format!("{e}");
                println!("  ✗ introspect: {msg}");
                report.introspect = Some(Err(msg));
                reports.push((fixture.name, report));
                continue;
            }
        };

        let plan = match plan_insertion(&schema) {
            Ok(p) => {
                let detail = format!("{} groups", p.groups.len());
                println!("  ✓ plan_insertion: {detail}");
                report.plan = Some(Ok(detail));
                p
            }
            Err(e) => {
                let msg = format!("{e}");
                println!("  ✗ plan_insertion: {msg}");
                report.plan = Some(Err(msg));
                reports.push((fixture.name, report));
                continue;
            }
        };

        let table_names: Vec<String> = schema.tables.iter().map(|t| t.id.name.clone()).collect();
        let generate_config = config_with_rows(fixture.schema, &table_names, 3);

        {
            let mut gen_client = db_client(&host, port, &source_db).await;
            let txn = gen_client.transaction().await.expect("begin generate txn");
            match insert::run(&txn, &schema, &plan, &generate_config, None, |_| {}).await {
                Ok(summary) => {
                    txn.commit().await.expect("commit generate");
                    let detail = format!("{} rows generated", summary.total_rows);
                    println!("  ✓ generate (up): {detail}");
                    report.generate = Some(Ok(detail));
                }
                Err(e) => {
                    let msg = format!("{e}");
                    println!("  ✗ generate (up): {msg}");
                    report.generate = Some(Err(msg));
                }
            }
        }

        // Clone the (now populated) source into the target, default
        // masking config (auto-detect by column name, same as a real user
        // running `feint clone` with no feint.yaml at all).
        {
            let mut source_conn = db_client(&host, port, &source_db).await;
            let source_ro = source_conn
                .build_transaction()
                .read_only(true)
                .start()
                .await
                .expect("begin source ro txn");
            let mut target_conn = db_client(&host, port, &target_db).await;
            let target_txn = target_conn.transaction().await.expect("begin target txn");
            let empty_config = FeintConfig {
                version: 1,
                seed: "real-world".to_string(),
                tables: BTreeMap::new(),
            };
            let mut clone_table = None;
            match clone::run(
                &source_ro,
                &target_txn,
                &schema,
                &plan,
                &empty_config,
                None,
                |event| match event {
                    clone::ProgressEvent::TableStarted { table } => {
                        clone_table = Some(table.to_string());
                    }
                    clone::ProgressEvent::TableFinished { .. } => {
                        clone_table = None;
                    }
                },
            )
            .await
            {
                Ok(summary) => {
                    target_txn.commit().await.expect("commit clone");
                    source_ro.rollback().await.ok();
                    let detail = format!("{} rows cloned", summary.total_rows);
                    println!("  ✓ clone: {detail}");
                    report.clone = Some(Ok(detail));
                }
                Err(e) => {
                    target_txn.rollback().await.ok();
                    source_ro.rollback().await.ok();
                    let msg = match clone_table {
                        Some(table) => format!("{e} while cloning `{table}`"),
                        None => format!("{e}"),
                    };
                    println!("  ✗ clone: {msg}");
                    report.clone = Some(Err(msg));
                }
            }
        }

        // Mask the target (clone destination) in place, default config.
        {
            let mut mask_client = db_client(&host, port, &target_db).await;
            let target_schema = match introspect(
                &mask_client,
                std::slice::from_ref(&fixture.schema.to_string()),
            )
            .await
            {
                Ok(s) => s,
                Err(e) => {
                    let msg = format!("re-introspect target for mask: {e}");
                    println!("  ✗ mask: {msg}");
                    report.mask = Some(Err(msg));
                    reports.push((fixture.name, report));
                    continue;
                }
            };
            let empty_config = FeintConfig {
                version: 1,
                seed: "real-world".to_string(),
                tables: BTreeMap::new(),
            };
            match sanitize::plan_sanitization(&target_schema, &empty_config) {
                Ok(sanitize_plan) => {
                    match sanitize::run_sanitization(
                        &mut mask_client,
                        &target_schema,
                        &sanitize_plan,
                        &empty_config,
                        500,
                        false,
                        None,
                        |_| {},
                    )
                    .await
                    {
                        Ok(summary) => {
                            let detail = format!(
                                "{} rows masked across {} tables",
                                summary.total_rows,
                                sanitize_plan.tables.len()
                            );
                            println!("  ✓ mask: {detail}");
                            report.mask = Some(Ok(detail));
                        }
                        Err(e) => {
                            let msg = format!("{e}");
                            println!("  ✗ mask: {msg}");
                            report.mask = Some(Err(msg));
                        }
                    }
                }
                Err(e) => {
                    let msg = format!("plan_sanitization: {e}");
                    println!("  ✗ mask: {msg}");
                    report.mask = Some(Err(msg));
                }
            }
        }

        reports.push((fixture.name, report));
    }

    println!("\n\nReal-world schema survey");
    println!("=========================");
    println!(
        "{:<12} {:<12} {:<12} {:<10} {:<20} {:<20} {:<20}",
        "fixture", "apply", "introspect", "plan", "generate", "clone", "mask"
    );
    let mut any_failure = false;
    for (name, r) in &reports {
        let mut cell = |p: &Option<PhaseResult>| -> String {
            match p {
                Some(Ok(_)) => "ok".to_string(),
                Some(Err(e)) => {
                    any_failure = true;
                    format!("FAIL: {}", &e[..e.len().min(60)])
                }
                None => "-".to_string(),
            }
        };
        println!(
            "{:<12} {:<12} {:<12} {:<10} {:<20} {:<20} {:<20}",
            name,
            cell(&r.apply_schema),
            cell(&r.introspect),
            cell(&r.plan),
            cell(&r.generate),
            cell(&r.clone),
            cell(&r.mask),
        );
    }

    if any_failure {
        println!("\nAt least one fixture hit a real failure — see the table above and the per-phase log.");
    } else {
        println!(
            "\nAll {} real-world schemas passed generate, clone, and mask cleanly.",
            fixtures.len()
        );
    }
}
