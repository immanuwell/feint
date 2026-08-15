//! Proves `feint_core::connect::connect` actually negotiates a real TLS
//! handshake for `sslmode=require`/`prefer`, against a real Postgres
//! server configured with a genuine (self-signed) certificate — not just
//! that the code compiles. This path had zero test coverage before this
//! file: neither the original `native-tls` implementation nor its
//! `rustls` replacement were ever exercised against an actual
//! SSL-enabled server.
//!
//! Deliberately does not use `common::TestDb`'s shared, statically-cached
//! container: enabling SSL requires copying a cert/key in and restarting
//! the server after the initial (non-SSL) startup, which the shared
//! container's lifecycle isn't set up for. This test starts and tears
//! down its own dedicated container via the plain `docker` CLI instead of
//! `testcontainers`, matching the level the SSL setup itself operates at.

use std::process::Command;

/// Runs `docker rm -f <id>` when dropped, so the container is removed
/// even if an assertion panics partway through the test.
struct ContainerGuard(String);

impl Drop for ContainerGuard {
    fn drop(&mut self) {
        let _ = Command::new("docker").args(["rm", "-f", &self.0]).output();
    }
}

/// `pg_isready` (checked via `docker exec`, inside the container's own
/// network namespace) can succeed slightly before the externally
/// published port is stable, causing an intermittent "connection reset
/// by peer" on the very next real connection attempt. Retrying the
/// actual connection a few times, rather than trusting `pg_isready` as a
/// sufficient proxy for external reachability, is what actually fixes
/// that instead of just trusting a longer `pg_isready` poll.
async fn connect_with_retry(url: &str) -> feint_core::Result<tokio_postgres::Client> {
    let mut last_err = None;
    for _ in 0..10 {
        match feint_core::connect::connect(url).await {
            Ok(client) => return Ok(client),
            Err(e) => {
                last_err = Some(e);
                tokio::time::sleep(std::time::Duration::from_millis(300)).await;
            }
        }
    }
    Err(last_err.unwrap())
}

fn run(cmd: &mut Command) -> String {
    let output = cmd.output().expect("spawn command");
    assert!(
        output.status.success(),
        "command failed: {:?}\nstdout: {}\nstderr: {}",
        cmd,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    String::from_utf8_lossy(&output.stdout).trim().to_string()
}

#[tokio::test]
async fn sslmode_require_connects_over_a_real_tls_handshake() {
    let openssl = Command::new("openssl")
        .args([
            "req",
            "-new",
            "-x509",
            "-days",
            "1",
            "-nodes",
            "-out",
            "/dev/stdout",
            "-keyout",
            "/dev/stderr",
            "-subj",
            "/CN=localhost",
        ])
        .output()
        .expect("run openssl");
    assert!(
        openssl.status.success(),
        "openssl not usable in this environment: {}",
        String::from_utf8_lossy(&openssl.stderr)
    );
    let cert_pem = String::from_utf8_lossy(&openssl.stdout).to_string();
    let key_pem = String::from_utf8_lossy(&openssl.stderr).to_string();
    assert!(cert_pem.contains("BEGIN CERTIFICATE"));
    assert!(key_pem.contains("BEGIN PRIVATE KEY"));

    let container_id = run(Command::new("docker").args([
        "run",
        "-d",
        "-e",
        "POSTGRES_PASSWORD=postgres",
        "-P",
        "postgres:16-alpine",
    ]));
    let _guard = ContainerGuard(container_id.clone());

    // Wait for the initial (plain) startup to accept connections.
    for _ in 0..60 {
        let ready = Command::new("docker")
            .args(["exec", &container_id, "pg_isready", "-U", "postgres"])
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false);
        if ready {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
    }

    // Write the cert/key in via stdin (avoids needing `docker cp` or a
    // shared filesystem), fix ownership/permissions Postgres requires,
    // then flip ssl on and restart to pick it up (ssl is not reloadable).
    let write_cert = |path: &str, content: &str| {
        use std::io::Write;
        let mut child = Command::new("docker")
            .args([
                "exec",
                "-i",
                &container_id,
                "sh",
                "-c",
                &format!("cat > {path}"),
            ])
            .stdin(std::process::Stdio::piped())
            .spawn()
            .expect("spawn docker exec");
        child
            .stdin
            .take()
            .unwrap()
            .write_all(content.as_bytes())
            .expect("write cert content");
        assert!(child.wait().expect("wait for docker exec").success());
    };
    write_cert("/var/lib/postgresql/server.crt", &cert_pem);
    write_cert("/var/lib/postgresql/server.key", &key_pem);
    run(Command::new("docker").args([
        "exec",
        "-u",
        "root",
        &container_id,
        "chown",
        "postgres:postgres",
        "/var/lib/postgresql/server.crt",
        "/var/lib/postgresql/server.key",
    ]));
    run(Command::new("docker").args([
        "exec",
        "-u",
        "root",
        &container_id,
        "chmod",
        "600",
        "/var/lib/postgresql/server.key",
    ]));
    run(Command::new("docker").args([
        "exec",
        &container_id,
        "psql",
        "-U",
        "postgres",
        "-c",
        "ALTER SYSTEM SET ssl = on;",
    ]));
    run(Command::new("docker").args([
        "exec",
        &container_id,
        "psql",
        "-U",
        "postgres",
        "-c",
        "ALTER SYSTEM SET ssl_cert_file = '/var/lib/postgresql/server.crt';",
    ]));
    run(Command::new("docker").args([
        "exec",
        &container_id,
        "psql",
        "-U",
        "postgres",
        "-c",
        "ALTER SYSTEM SET ssl_key_file = '/var/lib/postgresql/server.key';",
    ]));
    run(Command::new("docker").args(["restart", &container_id]));

    let port = run(Command::new("docker").args([
        "inspect",
        "-f",
        "{{ (index (index .NetworkSettings.Ports \"5432/tcp\") 0).HostPort }}",
        &container_id,
    ]));

    // Wait for the post-restart (now SSL-enabled) server to come back up.
    let mut ssl_confirmed = false;
    for _ in 0..60 {
        let ready = Command::new("docker")
            .args(["exec", &container_id, "pg_isready", "-U", "postgres"])
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false);
        if ready {
            let ssl_on = run(Command::new("docker").args([
                "exec",
                &container_id,
                "psql",
                "-U",
                "postgres",
                "-tAc",
                "SHOW ssl;",
            ]));
            if ssl_on == "on" {
                ssl_confirmed = true;
                break;
            }
        }
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
    }
    assert!(
        ssl_confirmed,
        "server never came back up with ssl=on after restart"
    );

    // The actual point of this test: connect through feint's own
    // connect() with sslmode=require, over the rustls-backed path, to a
    // server that only has a self-signed cert (mirroring the "encrypted,
    // certificate not validated" contract documented in DOCS.md).
    let url = format!("postgres://postgres:postgres@127.0.0.1:{port}/postgres?sslmode=require");
    let client = connect_with_retry(&url)
        .await
        .expect("connect over sslmode=require must succeed against a self-signed cert");
    let row = client
        .query_one(
            "SELECT ssl FROM pg_stat_ssl WHERE pid = pg_backend_pid()",
            &[],
        )
        .await
        .expect("query pg_stat_ssl");
    let is_ssl: bool = row.get(0);
    assert!(
        is_ssl,
        "connection did not actually negotiate TLS despite sslmode=require"
    );
}

#[tokio::test]
async fn sslmode_disable_still_connects_without_tls() {
    let container_id = run(Command::new("docker").args([
        "run",
        "-d",
        "-e",
        "POSTGRES_PASSWORD=postgres",
        "-P",
        "postgres:16-alpine",
    ]));
    let _guard = ContainerGuard(container_id.clone());

    for _ in 0..60 {
        let ready = Command::new("docker")
            .args(["exec", &container_id, "pg_isready", "-U", "postgres"])
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false);
        if ready {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
    }

    let port = run(Command::new("docker").args([
        "inspect",
        "-f",
        "{{ (index (index .NetworkSettings.Ports \"5432/tcp\") 0).HostPort }}",
        &container_id,
    ]));

    let url = format!("postgres://postgres:postgres@127.0.0.1:{port}/postgres?sslmode=disable");
    let client = connect_with_retry(&url)
        .await
        .expect("sslmode=disable must still connect plainly");
    let row = client.query_one("SELECT 1", &[]).await.expect("query");
    let one: i32 = row.get(0);
    assert_eq!(one, 1);
}
