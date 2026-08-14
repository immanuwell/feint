mod commands;
mod ui;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(
    name = "feint",
    version,
    about = "Deterministic, Postgres-native synthetic test data"
)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Connect to a Postgres database, introspect its schema, and write a feint.yaml config.
    Init {
        /// Postgres connection URL, e.g. postgres://user:pass@localhost/mydb
        database_url: String,
        /// Where to write the generated config.
        #[arg(long, default_value = "feint.yaml")]
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
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Generate deterministic synthetic data per feint.yaml and insert it.
    Up {
        /// Postgres connection URL to insert into.
        database_url: String,
        /// Config file to read.
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Override the seed from feint.yaml.
        #[arg(long)]
        seed: Option<String>,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
        /// A file written by `feint profile`: generate row counts, null rates, and per-parent
        /// child counts matching a real database's captured shape instead of a uniform default.
        #[arg(long)]
        profile: Option<std::path::PathBuf>,
    },
    /// Capture row counts, null rates, and foreign-key cardinality from a real database for
    /// `up --profile` to generate against. Reads only aggregate counts and ratios, never a row's
    /// actual values.
    Profile {
        /// Postgres connection URL to profile. Only ever queried with aggregate SELECTs.
        database_url: String,
        /// Where to write the profile file.
        #[arg(long)]
        output: std::path::PathBuf,
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
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
        /// Fail closed: refuse to run unless the live schema's column classification exactly
        /// matches the approved lockfile. Run `feint classify --write` first to create one.
        #[arg(long)]
        strict: bool,
        /// Classification lockfile to check against when --strict is set.
        #[arg(long, default_value = feint_core::classify::DEFAULT_LOCKFILE)]
        lockfile: std::path::PathBuf,
    },
    /// Capture a clone-shaped, masked read of a database into a file, no target database needed yet.
    Snapshot {
        /// Postgres connection URL to read from. Only ever queried with SELECT.
        source_url: String,
        /// Where to write the snapshot file.
        #[arg(long)]
        output: std::path::PathBuf,
        /// Subset root, e.g. "public.organizations WHERE id = 42". Omit to snapshot the whole database.
        #[arg(long)]
        root: Option<String>,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
    },
    /// Load a snapshot file into a target database. The target's own schema decides insertion
    /// order and foreign-key handling — no live connection to the original source is needed.
    Restore {
        /// Path to a file written by `feint snapshot`.
        snapshot_file: std::path::PathBuf,
        /// Postgres connection URL to write into.
        target_url: String,
    },
    /// Mask sensitive columns of a database in place. Row values only — no schema change, no row insert/delete.
    Mask {
        /// Postgres connection URL to mask in place.
        database_url: String,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "feint.yaml")]
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
        /// Skip the post-mask verification pass (re-checks masked values match the strategy
        /// that was applied). On by default; skip only if the extra queries are too costly.
        #[arg(long)]
        skip_verify: bool,
        /// Fail closed: refuse to run unless the live schema's column classification exactly
        /// matches the approved lockfile. Run `feint classify --write` first to create one.
        #[arg(long)]
        strict: bool,
        /// Classification lockfile to check against when --strict is set.
        #[arg(long, default_value = feint_core::classify::DEFAULT_LOCKFILE)]
        lockfile: std::path::PathBuf,
        /// Print a single JSON summary to stdout instead of the human-readable report, for
        /// scripts and CI to parse. See DOCS.md's CI section for the shape and exit-code contract.
        #[arg(long)]
        json: bool,
    },
    /// Report which columns look sensitive and what they'd be masked as, and check that against
    /// a committed lockfile so schema drift (a new column nobody classified) fails loudly.
    Classify {
        /// Postgres connection URL to introspect.
        database_url: String,
        /// Config file with masking overrides, if present.
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
        /// Lockfile to read/write.
        #[arg(long, default_value = feint_core::classify::DEFAULT_LOCKFILE)]
        lockfile: std::path::PathBuf,
        /// Approve the current classification: write it to the lockfile.
        #[arg(long)]
        write: bool,
        /// Exit non-zero if the lockfile is missing or the schema has drifted from it. For CI.
        #[arg(long)]
        check: bool,
        /// Print a single JSON summary to stdout instead of the human-readable report.
        #[arg(long)]
        json: bool,
    },
    /// Convert another tool's config to feint.yaml. Best effort — review the report before using the output.
    Migrate {
        #[command(subcommand)]
        tool: MigrateTool,
    },
    /// Prebuilt masking policy templates for common data domains (PII, healthcare, payments).
    Policy {
        #[command(subcommand)]
        action: PolicyAction,
    },
}

#[derive(Subcommand)]
enum PolicyAction {
    /// List the available policy templates.
    List,
    /// Apply a policy template's mask overrides to a config file.
    Apply {
        /// Policy name, e.g. pii, healthcare, payments. See `feint policy list`.
        name: String,
        /// Postgres connection URL to introspect.
        database_url: String,
        /// Config file to update, or create if it doesn't exist.
        #[arg(long, default_value = "feint.yaml")]
        config: std::path::PathBuf,
        /// Schema(s) to introspect. Repeat to include more than one.
        #[arg(long = "schema", default_value = "public")]
        schemas: Vec<String>,
        /// Overwrite columns that already have an explicit mask: set.
        #[arg(long)]
        force: bool,
    },
}

#[derive(Subcommand)]
enum MigrateTool {
    /// Convert a Snaplet Seed `seed.config.ts` (and optionally `seed.ts`) to feint.yaml.
    Snaplet {
        /// Path to seed.config.ts.
        config_ts: std::path::PathBuf,
        /// Path to seed.ts, if you have custom generators to detect.
        #[arg(long)]
        seed_ts: Option<std::path::PathBuf>,
        /// Where to write the converted config.
        #[arg(long, default_value = "feint.yaml")]
        output: std::path::PathBuf,
    },
    /// Convert a Neosync Job export (GetJob API response, JSON) to feint.yaml.
    Neosync {
        /// Path to the Job export JSON.
        job_json: std::path::PathBuf,
        /// Where to write the converted config.
        #[arg(long, default_value = "feint.yaml")]
        output: std::path::PathBuf,
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
            profile,
        } => commands::up::run(&database_url, &config, seed, &schemas, profile.as_deref()).await,
        Command::Profile {
            database_url,
            output,
            schemas,
        } => commands::profile::run(&database_url, &output, &schemas).await,
        Command::Clone {
            source_url,
            target_url,
            root,
            config,
            schemas,
            strict,
            lockfile,
        } => {
            commands::clone::run(
                &source_url,
                &target_url,
                root,
                &config,
                &schemas,
                strict,
                &lockfile,
            )
            .await
        }
        Command::Snapshot {
            source_url,
            output,
            root,
            config,
            schemas,
        } => commands::snapshot::run(&source_url, &output, root, &config, &schemas).await,
        Command::Restore {
            snapshot_file,
            target_url,
        } => commands::restore::run(&snapshot_file, &target_url).await,
        Command::Mask {
            database_url,
            config,
            schemas,
            batch_size,
            dry_run,
            yes,
            resume,
            max_batches,
            skip_verify,
            strict,
            lockfile,
            json,
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
                skip_verify,
                strict,
                &lockfile,
                json,
            )
            .await
        }
        Command::Classify {
            database_url,
            config,
            schemas,
            lockfile,
            write,
            check,
            json,
        } => {
            commands::classify::run(
                &database_url,
                &config,
                &schemas,
                &lockfile,
                write,
                check,
                json,
            )
            .await
        }
        Command::Migrate { tool } => match tool {
            MigrateTool::Snaplet {
                config_ts,
                seed_ts,
                output,
            } => commands::migrate::run_snaplet(&config_ts, seed_ts.as_deref(), &output).await,
            MigrateTool::Neosync { job_json, output } => {
                commands::migrate::run_neosync(&job_json, &output).await
            }
        },
        Command::Policy { action } => match action {
            PolicyAction::List => {
                commands::policy::list();
                Ok(())
            }
            PolicyAction::Apply {
                name,
                database_url,
                config,
                schemas,
                force,
            } => commands::policy::apply(&name, &database_url, &config, &schemas, force).await,
        },
    }
}
