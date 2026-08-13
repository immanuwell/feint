# seedy

A single binary that connects to Postgres and generates realistic test data for you.

No ORM. No config server. No Docker stack. It reads your schema and writes rows.

seedy understands foreign keys, enums, arrays, JSONB, UUIDs, domains, and cyclic references. It never guesses wrong about your constraints. If a run succeeds, your data is valid.

Every run is deterministic. Same seed, same schema, same output, every time.

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

seedy generates synthetic data from your schema. That's it, for now.

It does not yet connect to a production database, subset real data, or mask real values. That mode is planned but not built. See `DOCS.md` for the full roadmap.

## Full docs

See [DOCS.md](DOCS.md) for the complete command reference, the `seedy.yaml` format, supported Postgres features, and known limitations.

## License

MIT. See [LICENSE](LICENSE).
