//! End-to-end smoke test: runs the actual compiled `feint` binary against
//! a throwaway Postgres container, exercising `init` then `up` exactly as
//! a user would from a shell.

use assert_cmd::Command;
use testcontainers::runners::AsyncRunner;
use testcontainers::ImageExt;
use testcontainers_modules::postgres::Postgres;
use tokio_postgres::NoTls;

#[tokio::test]
async fn init_then_up_smoke_test() {
    let container = Postgres::default()
        .with_tag("16-alpine")
        .start()
        .await
        .expect("start postgres testcontainer (is Docker running?)");
    let port = container
        .get_host_port_ipv4(5432)
        .await
        .expect("mapped port");
    let url = format!("postgres://postgres:postgres@127.0.0.1:{port}/postgres");

    let (client, connection) = tokio_postgres::connect(&url, NoTls).await.expect("connect");
    tokio::spawn(async move {
        let _ = connection.await;
    });
    client
        .batch_execute(
            "CREATE TABLE authors (id serial PRIMARY KEY, name text NOT NULL); \
             CREATE TABLE books (id serial PRIMARY KEY, author_id integer NOT NULL REFERENCES authors(id), title text NOT NULL);",
        )
        .await
        .expect("create smoke-test schema");

    let config_path = std::env::temp_dir().join(format!("feint_smoke_{}.yaml", std::process::id()));

    let init_output = Command::cargo_bin("feint")
        .unwrap()
        .args(["init", &url, "--config"])
        .arg(&config_path)
        .output()
        .expect("run feint init");
    assert!(
        init_output.status.success(),
        "feint init failed: {}",
        String::from_utf8_lossy(&init_output.stderr)
    );
    let init_stdout = String::from_utf8_lossy(&init_output.stdout);
    assert!(
        init_stdout.contains("2 tables"),
        "init stdout: {init_stdout}"
    );
    assert!(
        config_path.exists(),
        "feint init did not write {config_path:?}"
    );

    let up_output = Command::cargo_bin("feint")
        .unwrap()
        .args(["up", &url, "--config"])
        .arg(&config_path)
        .output()
        .expect("run feint up");
    assert!(
        up_output.status.success(),
        "feint up failed: {}",
        String::from_utf8_lossy(&up_output.stderr)
    );
    let up_stdout = String::from_utf8_lossy(&up_output.stdout);
    assert!(
        up_stdout.contains("rows generated"),
        "up stdout: {up_stdout}"
    );
    assert!(
        up_stdout.contains("All foreign keys valid"),
        "up stdout: {up_stdout}"
    );

    let row = client
        .query_one("SELECT count(*) FROM authors", &[])
        .await
        .expect("count authors");
    let authors: i64 = row.get(0);
    assert_eq!(authors, 100, "expected default 100 rows in authors");

    let orphans = client
        .query_one(
            "SELECT count(*) FROM books b LEFT JOIN authors a ON b.author_id = a.id WHERE a.id IS NULL",
            &[],
        )
        .await
        .expect("orphan check");
    let orphan_count: i64 = orphans.get(0);
    assert_eq!(orphan_count, 0, "found orphaned books.author_id references");

    let _ = std::fs::remove_file(&config_path);
}
