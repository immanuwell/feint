//! Shared connection helper honoring `sslmode` from the connection URL.
//!
//! Every seedy command used to hardcode `tokio_postgres::connect(url,
//! NoTls)`, unconditionally. Many managed Postgres instances (notably RDS
//! with a publicly-accessible endpoint) generate a `pg_hba.conf` that
//! requires an encrypted (`hostssl`) connection — even over an
//! already-encrypted SSH tunnel, since the requirement is enforced at the
//! Postgres wire-protocol layer, independent of the transport underneath
//! it. Without this module, seedy could not connect to that class of
//! database at all, for any command.

use native_tls::TlsConnector as NativeTlsConnector;
use postgres_native_tls::MakeTlsConnector;
use tokio_postgres::config::SslMode;
use tokio_postgres::{Client, Config};

use crate::error::{Result, SeedyError};

/// Connect to Postgres, honoring `sslmode` from `database_url`.
///
/// - `disable` (or no `sslmode` at all): plain, unencrypted TCP — the
///   historical behavior, still the right default for a local dev
///   database.
/// - `require` / `prefer`: encrypted, but the server's certificate is
///   **not** validated against a CA or hostname. This matches Postgres's
///   own `sslmode=require` semantics exactly (encryption without
///   verification) — the same trade-off an operator already accepts
///   connecting through an SSH tunnel or an EC2 jump host whose address
///   never matches the server's certificate anyway.
/// - `verify-ca` / `verify-full`: not implemented yet. Returns a clear
///   error rather than silently downgrading to an unverified connection,
///   which would be a silent security regression instead of a loud one.
pub async fn connect(database_url: &str) -> Result<Client> {
    let config: Config = database_url
        .parse()
        .map_err(|e| SeedyError::Config(format!("invalid database URL: {e}")))?;

    match config.get_ssl_mode() {
        SslMode::Disable => {
            let (client, connection) = config.connect(tokio_postgres::NoTls).await?;
            spawn_connection(connection);
            Ok(client)
        }
        SslMode::Prefer | SslMode::Require => {
            let connector = NativeTlsConnector::builder()
                .danger_accept_invalid_certs(true)
                .danger_accept_invalid_hostnames(true)
                .build()
                .map_err(|e| SeedyError::Config(format!("failed to build TLS connector: {e}")))?;
            let connector = MakeTlsConnector::new(connector);
            let (client, connection) = config.connect(connector).await?;
            spawn_connection(connection);
            Ok(client)
        }
        other => Err(SeedyError::Config(format!(
            "sslmode {other:?} is not supported yet. Use `sslmode=require` for an encrypted \
             connection (the common case for managed Postgres like RDS), or omit sslmode / use \
             `disable` for a plain local connection."
        ))),
    }
}

fn spawn_connection<S, T>(connection: tokio_postgres::Connection<S, T>)
where
    S: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin + Send + 'static,
    T: tokio_postgres::tls::TlsStream + Unpin + Send + 'static,
{
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {e}");
        }
    });
}
