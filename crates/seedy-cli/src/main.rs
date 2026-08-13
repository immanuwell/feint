mod commands;
mod ui;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(
    name = "seedy",
    version,
    about = "Deterministic, Postgres-native synthetic test data"
)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Connect to a Postgres database, introspect its schema, and write a seedy.yaml config.
    Init {
        /// Postgres connection URL, e.g. postgres://user:pass@localhost/mydb
        database_url: String,
        /// Where to write the generated config.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Show the FK dependency tree, insertion order, and row estimates without touching the database.
    Plan {
        /// Postgres connection URL to introspect.
        database_url: String,
        /// Config file to read row counts from, if present.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Generate deterministic synthetic data per seedy.yaml and insert it.
    Up {
        /// Postgres connection URL to insert into.
        database_url: String,
        /// Config file to read.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Override the seed from seedy.yaml.
        #[arg(long)]
        seed: Option<String>,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Clone a database, preserving keys and masking sensitive columns.
    Clone {
        /// Postgres connection URL to read from. Only ever queried with SELECT.
        source_url: String,
        /// Postgres connection URL to write into.
        target_url: String,
        /// Subset root, e.g. "public.organizations WHERE id = 42". Not implemented yet.
        #[arg(long)]
        root: Option<String>,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Command::Init {
            database_url,
            config,
            schemas,
        } => commands::init::run(&database_url, &config, &schemas).await,
        Command::Plan {
            database_url,
            config,
            schemas,
        } => commands::plan::run(&database_url, &config, &schemas).await,
        Command::Up {
            database_url,
            config,
            seed,
            schemas,
        } => commands::up::run(&database_url, &config, seed, &schemas).await,
        Command::Clone {
            source_url,
            target_url,
            root,
            config,
            schemas,
        } => commands::clone::run(&source_url, &target_url, root, &config, &schemas).await,
    }
}
