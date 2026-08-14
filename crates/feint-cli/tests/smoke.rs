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

/// End-to-end fail-closed masking: `feint classify` writes and checks a
/// lockfile, and `feint mask --strict` refuses to run against a database
/// whose schema has drifted from it, all through the real compiled
/// binary rather than the library API directly.
#[tokio::test]
async fn classify_strict_fail_closed_smoke_test() {
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
        .batch_execute("CREATE TABLE users (id serial PRIMARY KEY, email text NOT NULL);")
        .await
        .expect("create smoke-test schema");

    let config_path = std::env::temp_dir().join(format!(
        "feint_strict_smoke_config_{}.yaml",
        std::process::id()
    ));
    let lockfile_path = std::env::temp_dir().join(format!(
        "feint_strict_smoke_lock_{}.yaml",
        std::process::id()
    ));
    let _ = std::fs::remove_file(&lockfile_path);

    // No lockfile yet: --check must fail closed rather than pass by
    // default, and must say why.
    let check_before_write = Command::cargo_bin("feint")
        .unwrap()
        .args(["classify", &url, "--check", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint classify --check");
    assert!(
        !check_before_write.status.success(),
        "classify --check must fail with no lockfile yet"
    );

    // Approve the current classification.
    let write_output = Command::cargo_bin("feint")
        .unwrap()
        .args(["classify", &url, "--write", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint classify --write");
    assert!(
        write_output.status.success(),
        "feint classify --write failed: {}",
        String::from_utf8_lossy(&write_output.stderr)
    );
    assert!(
        lockfile_path.exists(),
        "classify --write did not write the lockfile"
    );

    // Freshly approved: --check passes, and mask --strict is allowed to run.
    let check_after_write = Command::cargo_bin("feint")
        .unwrap()
        .args(["classify", &url, "--check", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint classify --check");
    assert!(
        check_after_write.status.success(),
        "classify --check should pass right after --write: {}",
        String::from_utf8_lossy(&check_after_write.stderr)
    );

    let mask_before_drift = Command::cargo_bin("feint")
        .unwrap()
        .args(["mask", &url, "--strict", "--yes", "--resume", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint mask --strict");
    assert!(
        mask_before_drift.status.success(),
        "mask --strict should succeed against an approved, undrifted schema: {}",
        String::from_utf8_lossy(&mask_before_drift.stderr)
    );

    // A new column shows up, unreviewed — the schema-drift scenario the
    // whole feature exists for.
    client
        .batch_execute("ALTER TABLE users ADD COLUMN ssn text")
        .await
        .expect("add drifting column");

    let check_after_drift = Command::cargo_bin("feint")
        .unwrap()
        .args(["classify", &url, "--check", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint classify --check");
    assert!(
        !check_after_drift.status.success(),
        "classify --check must fail once a new sensitive-looking column appears"
    );
    // The per-column diff (which names the drifted column) is printed to
    // stdout; the terminal failure message goes to stderr.
    let check_stdout = String::from_utf8_lossy(&check_after_drift.stdout);
    assert!(
        check_stdout.contains("ssn"),
        "classify --check stdout should mention the drifted column: {check_stdout}"
    );

    let mask_after_drift = Command::cargo_bin("feint")
        .unwrap()
        .args(["mask", &url, "--strict", "--yes", "--resume", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint mask --strict");
    assert!(
        !mask_after_drift.status.success(),
        "mask --strict must refuse to run once the schema has drifted from the lockfile"
    );

    // Re-approve, and the same run now succeeds.
    let rewrite_output = Command::cargo_bin("feint")
        .unwrap()
        .args(["classify", &url, "--write", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint classify --write");
    assert!(rewrite_output.status.success());

    let mask_after_reapproval = Command::cargo_bin("feint")
        .unwrap()
        .args(["mask", &url, "--strict", "--yes", "--resume", "--config"])
        .arg(&config_path)
        .args(["--lockfile"])
        .arg(&lockfile_path)
        .output()
        .expect("run feint mask --strict");
    assert!(
        mask_after_reapproval.status.success(),
        "mask --strict should succeed once the drifted column has been consciously re-approved: {}",
        String::from_utf8_lossy(&mask_after_reapproval.stderr)
    );

    let _ = std::fs::remove_file(&config_path);
    let _ = std::fs::remove_file(&lockfile_path);
}
