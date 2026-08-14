# seedy

A single binary for Postgres test data. Generate synthetic data from nothing, clone a real database with sensitive columns masked, or mask a database's own sensitive columns in place.

No ORM. No config server. No Docker stack. It reads your schema and writes rows.

seedy understands foreign keys, enums, arrays, JSONB, UUIDs, domains, and cyclic references. It never guesses wrong about your constraints. If a run succeeds, your data is valid.

Every run is deterministic. Same seed, same input, same output, every time. A masked column always maps the same source row to the same fake value.

## Quick demo

```
$ seedy init postgres://localhost/myapp

6 tables
5 foreign keys
0 enums
0 JSONB columns

Sensitive fields detected:
  users.email          email
  users.phone          phone
  payments.card_last4  potential_identifier

Generated seedy.yaml

$ seedy plan postgres://localhost/myapp

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

$ seedy up postgres://localhost/myapp

Generating...

600 rows generated in 0.4s
All constraints valid
All foreign keys valid
0 production values used

$ seedy clone postgres://prod-host/myapp postgres://localhost/myapp_dev --root "organizations WHERE id = 42"

Subset: 219 rows across 6 tables

219 rows cloned in 0.6s
All constraints valid
All foreign keys valid
Primary keys and foreign keys preserved from source

$ seedy mask postgres://localhost/myapp_stage --yes

Tables and columns to mask:
  public.users: email (fake), phone (fake), ssn (fake)

Masking...

234 rows masked
Row counts unchanged on every table
Primary keys and foreign keys untouched
```

## Install

You need Rust and Cargo. Get them from [rustup.rs](https://rustup.rs) if you don't have them.

Build from source:

```
git clone <this-repo>
cd seedy
cargo build --release
```

The binary is at `target/release/seedy`. Put it on your `PATH`, or run it directly.

## Quick start

```
seedy init postgres://localhost/myapp
seedy plan postgres://localhost/myapp
seedy up postgres://localhost/myapp
```

`init` reads your schema and writes a `seedy.yaml` config.

`plan` shows what will happen: the table dependency order and how many rows each table gets. It never touches the database.

`up` generates the data and inserts it, inside one transaction. If anything fails, nothing is written.

## What it does today

**Generate**: `seedy init` / `plan` / `up`. Builds synthetic data from your schema, nothing real involved.

**Clone**: `seedy clone`. Copies real rows from a source database to a target database, keeping keys intact and masking sensitive columns. Add `--root` to copy only a subset instead of the whole database.

**Mask**: `seedy mask`. Rewrites a single database's own sensitive columns in place. No second database. This is the right tool when a database already got a full copy from somewhere else (a cloud snapshot restore, most commonly) and now needs its own PII scrubbed. Batched, resumable if interrupted, with a dry run and a confirmation step before it writes anything.

`clone` needs a live connection to both databases at once. There's no separate "snapshot to a file, restore it later" step yet. See `DOCS.md` for the full roadmap.

## Full docs

See [DOCS.md](DOCS.md) for the complete command reference, the `seedy.yaml` format, supported Postgres features, and known limitations.

## License

MIT. See [LICENSE](LICENSE).
