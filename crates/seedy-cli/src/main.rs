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
    },
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Command::Init {
            database_url,
            config,
        } => commands::init::run(&database_url, &config).await,
        Command::Up {
            database_url,
            config,
            seed,
        } => commands::up::run(&database_url, &config, seed).await,
    }
}
