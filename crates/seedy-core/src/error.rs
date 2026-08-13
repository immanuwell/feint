use thiserror::Error;

#[derive(Debug, Error)]
pub enum SeedyError {
    #[error("database error: {0}")]
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

pub type Result<T> = std::result::Result<T, SeedyError>;
