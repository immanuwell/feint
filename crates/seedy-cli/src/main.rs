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
        /// Subset root, e.g. "public.organizations WHERE id = 42". Omit to clone the whole database.
        #[arg(long)]
        root: Option<String>,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Mask sensitive columns of a database in place. Row values only — no schema change, no row insert/delete.
    Mask {
        /// Postgres connection URL to mask in place.
        database_url: String,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "seedy.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
        /// Rows per UPDATE batch.
        #[arg(long, default_value_t = 5000)]
        batch_size: usize,
        /// Report what would be masked and how many rows, without writing anything.
        #[arg(long)]
        dry_run: bool,
        /// Skip the interactive confirmation prompt.
        #[arg(long)]
        yes: bool,
        /// Continue a previous interrupted run from its checkpoint.
        #[arg(long)]
        resume: bool,
        /// Stop after this many batches (across all tables), leaving a valid checkpoint to
        /// --resume from later. Useful for pacing a very large run. Unlimited if omitted.
        #[arg(long)]
        max_batches: Option<usize>,
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
        Command::Mask {
            database_url,
            config,
            schemas,
            batch_size,
            dry_run,
            yes,
            resume,
            max_batches,
        } => {
            commands::mask::run(
                &database_url,
                &config,
                &schemas,
                batch_size,
                dry_run,
                yes,
                resume,
                max_batches,
            )
            .await
        }
    }
}
