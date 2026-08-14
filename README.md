# feint

[![CI](https://github.com/immanuwell/feint/actions/workflows/ci.yml/badge.svg)](https://github.com/immanuwell/feint/actions/workflows/ci.yml)

A single binary for Postgres test data. Generate synthetic data from nothing, clone a real database with sensitive columns masked, mask a database's own sensitive columns in place, or migrate a config from another tool.

No ORM. No config server. No Docker stack. It reads your schema and writes rows.

No Postgres extension to install, either. feint connects like any client and does everything from there, so it runs unmodified against managed Postgres that won't grant superuser: RDS, Aurora, Cloud SQL, Neon. Extension-based masking tools (PostgreSQL Anonymizer is the well known one) cannot be installed on those at all.

feint understands foreign keys, enums, arrays, JSONB, UUIDs, domains, and cyclic references. It never guesses wrong about your constraints. If a run succeeds, your data is valid.

Every run is deterministic. Same seed, same input, same output, every time. A masked column always maps the same source row to the same fake value, whether you reach that row through `clone` or `mask`, today or next month. See [Deterministic identity](DOCS.md#deterministic-identity).

## Quick demo

```
$ feint init postgres://localhost/myapp

6 tables
5 foreign keys
0 enums
0 JSONB columns

Sensitive fields detected:
  users.email          email
  users.phone          phone
  payments.card_last4  potential_identifier

Generated feint.yaml

$ feint plan postgres://localhost/myapp

users
├── memberships
├── orders
│   └── payments
└── profiles

Insertion order:
  1. public.users (100 rows)
  2. public.profiles (100 rows)
  3. public.orders (100 rows)
  4. public.payments (100 rows)
  5. public.memberships (100 rows)

Estimated 500 rows total

$ feint up postgres://localhost/myapp

Generating...

600 rows generated in 0.4s
All constraints valid
All foreign keys valid
0 production values used

$ feint clone postgres://prod-host/myapp postgres://localhost/myapp_dev --root "organizations WHERE id = 42"

Subset: 219 rows across 6 tables

219 rows cloned in 0.6s
All constraints valid
All foreign keys valid
Primary keys and foreign keys preserved from source

$ feint mask postgres://localhost/myapp_stage --yes

Tables and columns to mask:
  public.users: email (fake), phone (fake), ssn (fake)

Masking...

234 rows masked
Row counts unchanged on every table
Primary keys and foreign keys untouched
```

## Correctness

Most generators break on real-world Postgres schemas: composite keys, self-referencing tables, FK cycles, enums, domains, arrays, JSONB, citext, partitioned tables. feint's test suite runs against all of them, in a real Postgres container, every time:

```
$ cargo test --test correctness_demo -- --nocapture

Nasty Postgres schema correctness check
========================================
✓ composite_fk                 60 rows generated, 0 constraint violations
✓ self_ref_fk                  20 rows generated, 0 constraint violations
✓ cycle_nullable               40 rows generated, 0 constraint violations
✓ cycle_deferred               40 rows generated, 0 constraint violations
✓ enums                        20 rows generated, 0 constraint violations
✓ domains                      20 rows generated, 0 constraint violations
✓ arrays                       20 rows generated, 0 constraint violations
✓ jsonb                        20 rows generated, 0 constraint violations
✓ citext                       20 rows generated, 0 constraint violations
✓ inet_cidr                    20 rows generated, 0 constraint violations
✓ uuid_pk                      20 rows generated, 0 constraint violations
✓ identity_serial              60 rows generated, 0 constraint violations
✓ partitioned                  20 rows generated, 0 constraint violations
✓ cycle_hard_unsatisfiable   correctly rejected before any write
✓ check_constraints          CHECK constraints introspected and annotated

15/15 nasty schemas handled correctly
0 constraint violations
```

That's a real, reproducible test run, not a marketing number. Clone the repo and run the command yourself (needs Docker). See [Supported Postgres features](DOCS.md#supported-postgres-features) for what each case covers and why it's there.

## Install

Linux and macOS, prebuilt binary:

```
curl -fsSL https://raw.githubusercontent.com/immanuwell/feint/main/install.sh | sh
```

Installs to `~/.local/bin`. Set `FEINT_VERSION=X.Y.Z` to pin a version instead of the latest release.

Or build from source (needs Rust and Cargo, get them from [rustup.rs](https://rustup.rs)):

```
git clone https://github.com/immanuwell/feint.git
cd feint
cargo build --release
```

The binary is at `target/release/feint`. Put it on your `PATH`, or run it directly.

## Quick start

```
feint init postgres://localhost/myapp
feint plan postgres://localhost/myapp
feint up postgres://localhost/myapp
```

`init` reads your schema and writes a `feint.yaml` config.

`plan` shows what will happen: the table dependency order and how many rows each table gets. It never touches the database.

`up` generates the data and inserts it, inside one transaction. If anything fails, nothing is written.

## What it does today

**Generate**: `feint init` / `plan` / `up`. Builds synthetic data from your schema, nothing real involved.

**Clone**: `feint clone`. Copies real rows from a source database to a target database, keeping keys intact and masking sensitive columns. Add `--root` to copy only a subset instead of the whole database.

**Mask**: `feint mask`. Rewrites a single database's own sensitive columns in place. No second database. This is the right tool when a database already got a full copy from somewhere else (a cloud snapshot restore, most commonly) and now needs its own PII scrubbed. Batched, resumable if interrupted, with a dry run and a confirmation step before it writes anything, and a post-mask verification pass that re-checks the result before calling it done. Add `--strict` to refuse the run outright if the schema has drifted from an approved classification lockfile, so a new column nobody reviewed fails the run instead of quietly passing through unmasked.

**Classify**: `feint classify`. Reports which columns look sensitive and what they'd be masked as, and checks that against a committed lockfile so schema drift fails loudly instead of silently. `--write` approves the current classification, `--check` is the CI gate. See [Fail-closed masking](DOCS.md#fail-closed-masking---strict).

**Migrate**: `feint migrate snaplet` / `feint migrate neosync`. Converts a Snaplet Seed or Neosync config into a starting `feint.yaml`. Best effort, prints what converted and what needs a manual look.

**Policy**: `feint policy list` / `feint policy apply`. Ready-made masking rules for a data domain (PII, healthcare, payments), written into your config instead of typed by hand. Never touches a primary or foreign key, never overwrites a `mask:` you already set.

`clone` needs a live connection to both databases at once. There's no separate "snapshot to a file, restore it later" step yet. See `DOCS.md` for the full roadmap.

## Full docs

See [DOCS.md](DOCS.md) for the complete command reference, the `feint.yaml` format, supported Postgres features, and known limitations.

## License

MIT. See [LICENSE](LICENSE).
