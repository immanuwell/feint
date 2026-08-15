use thiserror::Error;

/// `tokio_postgres::Error`'s own `Display` is a fixed, generic phrase per
/// error kind ("db error", "error communicating with the server", ...) —
/// the real Postgres-side detail (message, hint, position) lives on the
/// `DbError` reachable only via `.as_db_error()` / `.source()`, not in the
/// top-level `Display` output. Surfacing only the generic phrase here
/// would mean every real database error (a constraint violation, a bad
/// cast, anything) shows up to a user as a useless "database error: db
/// error" with no indication of what actually went wrong.
pub fn format_pg_error(e: &tokio_postgres::Error) -> String {
    match e.as_db_error() {
        Some(db_err) => {
            let mut msg = format!("{} ({})", db_err.message(), db_err.code().code());
            if let Some(detail) = db_err.detail() {
                msg.push_str(&format!(" — {detail}"));
            }
            if let Some(hint) = db_err.hint() {
                msg.push_str(&format!(" — hint: {hint}"));
            }
            msg
        }
        None => e.to_string(),
    }
}

#[derive(Debug, Error)]
pub enum FeintError {
    #[error("database error: {}", format_pg_error(.0))]
    Db(#[from] tokio_postgres::Error),

    #[error("pool error: {0}")]
    Pool(#[from] deadpool_postgres::PoolError),

    #[error("pool build error: {0}")]
    PoolBuild(#[from] deadpool_postgres::BuildError),

    #[error("config error: {0}")]
    Config(String),

    #[error("yaml error: {0}")]
    Yaml(#[from] serde_yaml_ng::Error),

    #[error("io error: {0}")]
    Io(#[from] std::io::Error),

    #[error(
        "unsatisfiable foreign-key cycle among tables [{tables}] via constraints [{constraints}]: \
         every FK in the cycle is NOT NULL and non-deferrable. Fix by making one FK nullable or \
         declaring it DEFERRABLE."
    )]
    UnsatisfiableCycle { tables: String, constraints: String },

    #[error("unsupported type: {0}")]
    UnsupportedType(String),

    #[error("generation error: {0}")]
    Generation(String),
}

pub type Result<T> = std::result::Result<T, FeintError>;
