# seedy docs

This is the full reference for seedy. For a quick overview, see [README.md](README.md).

## What seedy is

seedy is a command line tool for Postgres. It reads your database schema and generates realistic, valid test data.

It has two commands that touch your data: `init` and `up`. A third command, `plan`, only reads your schema. It never writes anything.

Today seedy only generates synthetic data. It does not connect to a production database, copy real rows, or mask real values. That is a planned second mode, not built yet. See [Roadmap](#roadmap).

## Install

Requirements: Rust and Cargo (get them from rustup.rs), and access to a Postgres database.

```
git clone <this-repo>
cd seedy
cargo build --release
```

The binary is at `target/release/seedy`.

## Commands

### seedy init

```
seedy init <DATABASE_URL> [--config <PATH>] [--schema <NAME>]...
```

Connects to the database, reads the schema, and writes a config file.

- `<DATABASE_URL>` is a normal Postgres connection string, for example `postgres://user:pass@localhost/mydb`.
- `--config <PATH>` sets where to write the config. Default is `seedy.yaml` in the current directory.
- `--schema <NAME>` sets which schema to read. Default is `public`. Pass it more than once to read more than one schema.

`init` prints a short report: table count, foreign key count, enum count, JSONB column count, any cyclic dependencies found, any CHECK constraints found, and a list of columns that look like they hold sensitive data (see [Sensitive field detection](#sensitive-field-detection)).

It then writes the config file. It does not insert any data.

### seedy plan

```
seedy plan <DATABASE_URL> [--config <PATH>] [--schema <NAME>]...
```

Reads the schema and shows what `seedy up` would do, without touching the database.

It prints:

- The foreign key dependency tree. A table listed under another table means it has a foreign key pointing at it.
- The insertion order: which table gets filled first, second, and so on, and how many rows each one gets.
- Which groups of tables have a foreign key cycle, and how seedy plans to resolve it.
- The total number of rows across all tables.
- A count of columns that look sensitive.

If a `seedy.yaml` file exists at the given `--config` path, `plan` uses its row counts. If not, it uses the default row count for every table.

### seedy up

```
seedy up <DATABASE_URL> [--config <PATH>] [--seed <SEED>] [--schema <NAME>]...
```

Generates data and inserts it.

- `--config <PATH>` sets which config file to read. Default is `seedy.yaml`.
- `--seed <SEED>` overrides the seed value from the config file for this run.
- `--schema <NAME>` sets which schema to read, same as `init` and `plan`.

The whole run happens inside one database transaction. If any row fails to insert, for example a CHECK constraint rejects a generated value, the entire transaction rolls back. Nothing is left half-written.

On success, `up` prints the total row count, the time taken, and confirms that constraints and foreign keys were satisfied.

## The seedy.yaml file

`init` writes a file like this:

```yaml
version: 1
seed: default
tables:
  public.users:
    rows: 100
  public.orders:
    rows: 500
```

You can edit it by hand before running `up`.

- `seed` is any string. Changing it changes every generated value. Keeping it the same gives you the same data every time.
- Each table under `tables:` has a `rows` count. Set it to however many rows you want.
- Table names are `schema.table`, for example `public.users`.

### Overriding a column's generator

Add a `columns:` block under a table to force a specific generator for a column:

```yaml
version: 1
seed: default
tables:
  public.users:
    rows: 100
    columns:
      email:
        generator: email
      status:
        generator: bool
```

Built in generator names: `email`, `phone`, `first_name`, `last_name`, `person_name`, `bool`, `int2_range`, `int4_range`, `int8_range`, `decimal`, `float4`, `float8`, `uuid`, `timestamp`, `timestamptz`, `date`, `json_object`, `bytea`, `inet`, `lorem_word`.

### CHECK constraint comments

If a table has CHECK constraints, `init` adds them as comments above that table in the config file, so you can see them while editing. Comments are just for you to read. seedy does not parse them, and they are dropped if you regenerate the file.

## How generation works

For each column, seedy picks a generator in this order:

1. An explicit `generator:` in `seedy.yaml`, if you set one.
2. A guess based on the column name. For example a column named `email` or containing `email` gets the email generator. A column ending in `_name` gets a person name generator.
3. A guess based on the column type. A `uuid` column gets a UUID. An `int4` column gets a random integer. A `timestamptz` column gets a random recent timestamp. And so on.

If none of these apply and the column type is one seedy does not understand, and the column is `NOT NULL`, `up` fails with a clear error naming the column. You then add an explicit `generator:` override for it.

### Determinism

Every value seedy generates comes from a random number generator seeded from a hash of four things: your `seed`, the table name, the column name, and the row's position. Same inputs, same hash, same value. This means:

- Running `seedy up` twice with the same seed against the same empty schema produces byte for byte identical data.
- Changing the seed changes every value, but running the new seed twice again gives you that new set of values every time.
- This does not deduplicate or diff against existing rows. Running `up` twice without truncating the tables first adds a second copy of the data.

## Foreign keys and cycles

seedy builds a dependency graph from your foreign keys and inserts tables in the right order: a referenced table always gets its rows before the table that references it.

### Composite foreign keys

If a foreign key spans more than one column, seedy samples a full matching row from the referenced table, not each column independently. This avoids generating column combinations that never actually appeared together.

### Self references and cycles

Some schemas have a table that references itself, like an `employees` table with a `manager_id` column pointing back at `employees.id`. Some schemas have two or more tables that reference each other in a loop.

seedy resolves these in one of three ways, in this order:

1. **Deferred.** If the foreign key is declared `DEFERRABLE`, seedy plans out every row's key up front, wires up the references, and lets Postgres check the constraint at commit time instead of at insert time.
2. **Null then backfill.** If the foreign key column is nullable, seedy inserts the row with that column set to null, then runs an `UPDATE` afterward once every row in the cycle exists.
3. **Error.** If the foreign key is `NOT NULL` and not `DEFERRABLE`, there is no safe way to insert it. seedy stops and prints an error naming the exact tables and constraints involved, before writing anything. Fix this by making the column nullable or marking the constraint `DEFERRABLE`.

## Supported Postgres features

| Feature | Support |
|---|---|
| Composite foreign keys | Yes |
| Self referencing foreign keys | Yes |
| Foreign key cycles | Yes, see above |
| Enums | Yes, picks a random declared value |
| Domains | Yes, generates a value for the underlying base type |
| Arrays | Yes, generates a short array of the element type |
| JSONB and JSON | Yes, generates a small JSON object |
| UUID primary keys | Yes, generated client side so `--seed` stays reproducible even when the column has a `DEFAULT gen_random_uuid()` |
| Serial and identity columns | Yes, left for Postgres to assign, then read back |
| Partitioned tables | Yes, seedy inserts into the parent table and lets Postgres route rows to partitions |
| citext, inet, cidr | Yes, but through a generic text value rather than a purpose built generator |
| CHECK constraints | Detected and shown as a warning and as comments in `seedy.yaml`, but not validated ahead of time. If a generated value fails a check, the whole run rolls back cleanly with an error |
| Composite types | Not supported. If a column has one and is `NOT NULL`, `up` fails with an error until you add an explicit override |

## Sensitive field detection

`seedy init` looks at your column names and flags ones that look like they hold personal data: emails, phone numbers, names, dates of birth, addresses, IP addresses, card numbers, SSNs, and similar identifiers.

This is informational only. seedy never touches real data in this mode, everything it generates is synthetic from the start. The point of the banner is to show you, before you generate anything, which columns it noticed and how they will be filled in.

This detection is based on column name patterns only. It does not know what the table is about. A column named `name` on a `users` table and a column named `name` on an `organizations` table are treated the same way right now, which is not always correct. Use an explicit `generator:` override in `seedy.yaml` if a guess is wrong.

## Known limitations

- CHECK constraints are not validated before insert. seedy relies on the transaction rolling back cleanly if one fails.
- Composite types (custom `CREATE TYPE ... AS (...)` structs) have no generator yet.
- citext, inet, and cidr columns use a generic fallback rather than a purpose built generator.
- The column name heuristic does not know what a table represents, only the column name.
- The whole run is one transaction. This is correct and safe, but it is not built for generating millions of rows yet.
- There is no way to avoid duplicate data on a second `up` run against the same tables. Truncate first if you want a clean set.

## Development

Requirements: Rust, Cargo, and Docker (for the test suite, which spins up real Postgres containers).

```
cargo build --workspace
cargo test --workspace
cargo clippy --workspace --all-targets
cargo fmt
```

The test suite includes:

- Unit tests for the value encoding, the dependency graph, and the generators.
- Integration tests that create real schemas in a throwaway Postgres container and check the results: composite keys, cycles, enums, arrays, JSONB, citext, partitioned tables, and more.
- A smoke test that runs the actual compiled binary through `init` and `up`.

## Roadmap

Not built yet:

- **Clone mode.** Connect to a production database, copy a subset of it (for example, one customer and everything that belongs to them), and mask sensitive columns while copying, instead of generating everything from scratch.
- **A shared identity layer across modes.** The same source row should map to the same fake identity every time, whether it comes from a fresh `generate` run or a masked `clone` run, so fixtures and snapshots stay consistent with each other.
- **Migration helpers** for teams moving from Snaplet or Neosync.
- **Table aware sensitive field detection**, so a `name` column is treated differently on a `users` table versus an `organizations` table.

## License

MIT. See [LICENSE](LICENSE).
