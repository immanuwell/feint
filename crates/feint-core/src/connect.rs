//! Shared connection helper honoring `sslmode` from the connection URL.
//!
//! Every feint command used to hardcode `tokio_postgres::connect(url,
//! NoTls)`, unconditionally. Many managed Postgres instances (notably RDS
//! with a publicly-accessible endpoint) generate a `pg_hba.conf` that
//! requires an encrypted (`hostssl`) connection — even over an
//! already-encrypted SSH tunnel, since the requirement is enforced at the
//! Postgres wire-protocol layer, independent of the transport underneath
//! it. Without this module, feint could not connect to that class of
//! database at all, for any command.

use std::sync::Arc;

use rustls::client::danger::{HandshakeSignatureValid, ServerCertVerified, ServerCertVerifier};
use rustls::crypto::{verify_tls12_signature, verify_tls13_signature, CryptoProvider};
use rustls::pki_types::{CertificateDer, ServerName, UnixTime};
use rustls::{ClientConfig, DigitallySignedStruct, SignatureScheme};
use tokio_postgres::config::SslMode;
use tokio_postgres::{Client, Config};
use tokio_postgres_rustls::MakeRustlsConnect;

use crate::error::{FeintError, Result};

/// A `rustls` server certificate verifier that unconditionally accepts
/// whatever certificate and hostname the server presents, while still
/// performing genuine handshake signature verification (rustls's own
/// official pattern for this — see `examples/src/bin/tlsclient-mio.rs` in
/// the rustls repo). This is the rustls equivalent of native-tls's
/// `danger_accept_invalid_certs(true)` + `danger_accept_invalid_hostnames(true)`:
/// the connection is still encrypted and the server must still prove it
/// holds the private key for whatever certificate it sent, but the
/// certificate's trust chain and hostname are never checked.
#[derive(Debug)]
struct NoCertVerification(CryptoProvider);

impl ServerCertVerifier for NoCertVerification {
    fn verify_server_cert(
        &self,
        _end_entity: &CertificateDer<'_>,
        _intermediates: &[CertificateDer<'_>],
        _server_name: &ServerName<'_>,
        _ocsp_response: &[u8],
        _now: UnixTime,
    ) -> std::result::Result<ServerCertVerified, rustls::Error> {
        Ok(ServerCertVerified::assertion())
    }

    fn verify_tls12_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        verify_tls12_signature(
            message,
            cert,
            dss,
            &self.0.signature_verification_algorithms,
        )
    }

    fn verify_tls13_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        verify_tls13_signature(
            message,
            cert,
            dss,
            &self.0.signature_verification_algorithms,
        )
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        self.0.signature_verification_algorithms.supported_schemes()
    }
}

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
        .map_err(|e| FeintError::Config(format!("invalid database URL: {e}")))?;

    match config.get_ssl_mode() {
        SslMode::Disable => {
            let (client, connection) = config.connect(tokio_postgres::NoTls).await?;
            spawn_connection(connection);
            Ok(client)
        }
        SslMode::Prefer | SslMode::Require => {
            let provider = rustls::crypto::ring::default_provider();
            let tls_config = ClientConfig::builder_with_provider(Arc::new(provider.clone()))
                .with_safe_default_protocol_versions()
                .map_err(|e| FeintError::Config(format!("failed to build TLS connector: {e}")))?
                .dangerous()
                .with_custom_certificate_verifier(Arc::new(NoCertVerification(provider)))
                .with_no_client_auth();
            let connector = MakeRustlsConnect::new(tls_config);
            let (client, connection) = config.connect(connector).await?;
            spawn_connection(connection);
            Ok(client)
        }
        other => Err(FeintError::Config(format!(
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
