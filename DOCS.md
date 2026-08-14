# seedy docs

This is the full reference for seedy. For a quick overview, see [README.md](README.md).

## What seedy is

seedy is a command line tool for Postgres. It has three modes.

**Generate** reads your database schema and generates realistic, synthetic test data from nothing. Commands: `init`, `plan`, `up`.

**Clone** reads a real source database and writes a copy into a target database, keeping the same primary keys and foreign keys, and masking sensitive columns as it goes. Command: `clone`.

**Mask** rewrites a database's own sensitive columns in place, on that same database, no second database involved. Command: `mask`. This is for a workflow clone can't cover: a database that already got a full physical copy from somewhere else (a cloud snapshot restore is the common case), and now needs its own PII scrubbed before anyone treats it as safe to use.

Alongside the three modes, `seedy migrate` converts another tool's config (Snaplet Seed, Neosync) into a starting `seedy.yaml`, so switching tools doesn't mean starting from a blank file.

`plan` only reads your schema, it never writes anything. `migrate` only reads a config file, never a database. `init`, `up`, `clone`, and `mask` all touch a database.

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

### seedy clone

```
seedy clone <SOURCE_URL> <TARGET_URL> [--root "<table> WHERE <condition>"] [--config <PATH>] [--schema <NAME>]...
```

Reads real rows from `SOURCE_URL` and writes them into `TARGET_URL`, masking sensitive columns as configured (see [Masking](#masking)).

- `<SOURCE_URL>` is only ever read from. seedy opens it as a read only transaction at the database level, not just by convention.
- `<TARGET_URL>` is written to, inside one transaction. If anything fails, the whole thing rolls back and the target is left exactly as it was.
- `--root "<table> WHERE <condition>"` clones a subset instead of the whole database. See [Subsetting](#subsetting). Without `--root`, seedy clones every table.
- `--config <PATH>` reads masking overrides from a `seedy.yaml` file, if one exists. The `rows:` field in that file is ignored by `clone`, it only matters for `up`.
- `--schema <NAME>` sets which schema to read from source, same as the other commands.

Primary keys and foreign keys are preserved exactly as they are on the source. This means:

- The target tables must already exist with a matching schema before you run `clone`. seedy does not create tables.
- If you run `clone` twice into the same target without clearing it first, the second run fails on duplicate keys.
- Sequences and identity columns on the target are advanced past whatever was just inserted, so a normal insert afterward does not collide.

On success, `clone` prints the row count per table and confirms that keys were preserved.

### seedy mask

```
seedy mask <DATABASE_URL> [--config <PATH>] [--schema <NAME>]... [--batch-size N] [--dry-run] [--yes] [--resume] [--max-batches N]
```

Rewrites a single database's own sensitive columns in place. One connection, read and write. No second database, no key remapping, no row inserted or deleted, ever, only `UPDATE` on existing columns.

This is for a case `clone` does not cover: a database that already has a full, real copy of your data through some other means, most commonly a cloud provider's own snapshot-and-restore mechanism (see [Mask-in-place and a snapshot-restore workflow](#mask-in-place-and-a-snapshot-restore-workflow) below). By the time seedy could get involved, the data already exists, unmasked, on one database. `clone` streams and masks between two databases; `mask` scrubs one database that already has everything.

- `<DATABASE_URL>` is both read from and written to.
- `--config <PATH>` reads masking overrides from `seedy.yaml`, same format and same strategies as `clone` (see [Masking](#masking)). The default is the same too: a column that looks sensitive gets `fake`, everything else passes through.
- `--batch-size N` sets rows per `UPDATE` batch. Default 5000. Rows are processed in primary-key order, in batches, each batch its own transaction, not the whole table in one transaction.
- `--dry-run` reports which tables and columns would be touched, and how many rows, without writing anything. This is the recommended first step, always, before a real run.
- `--yes` skips the interactive confirmation prompt. Without it, `mask` prints the exact target and table/column list and asks you to type "yes" before writing anything. Needed for scripted or CI use.
- `--resume` continues a previous run that stopped partway through (crashed, was killed, or hit `--max-batches`), picking up exactly where it left off. Without `--resume`, a run refuses to start at all if it finds unfinished progress from an earlier attempt. You have to choose to continue it, seedy will not guess.
- `--max-batches N` stops the whole run after N batches, leaving a valid, resumable checkpoint. Useful for pacing a very large run across more than one invocation. Unlimited if omitted.

`mask` tracks its own progress in a small table it creates on the target, `_seedy_mask_checkpoint`, one row per table it has touched. This is what makes `--resume` safe: each batch's `UPDATE` and its checkpoint update commit together, in the same transaction, so a row is read and masked exactly once, ever, no matter how many times a run gets interrupted and resumed. This matters specifically for the `hash` strategy, which is keyed off a column's real value. Re-masking an already-masked row would hash the masked output instead of the original, which is exactly what the checkpoint is there to prevent.

Before and after masking each table, `mask` checks the row count is unchanged. `mask` only ever runs `UPDATE`. A row-count mismatch is a hard error, not a warning, since it would mean something else wrote to the table while masking was running.

On success, `mask` prints the row count masked per table and confirms row counts and keys were untouched.

### seedy migrate

```
seedy migrate snaplet <CONFIG_TS> [--seed-ts <PATH>] [--output <PATH>]
seedy migrate neosync <JOB_JSON> [--output <PATH>]
```

Converts another tool's config into a `seedy.yaml`, as a starting point. Best effort, not a full translation. Both prompt through what got converted, what needs manual review, and why, so nothing is silently dropped or guessed.

**`seedy migrate snaplet <CONFIG_TS>`** reads a Snaplet Seed `seed.config.ts` file.

- Literal table names in its `select` array become `tables:` entries in the output.
- A glob pattern (`"public.*"`) or an exclude entry (`"!archive*"`) cannot become a literal table list on its own. These are reported as notes instead, telling you to run `seedy init` and adjust the result by hand.
- `--seed-ts <PATH>` also reads a `seed.ts` file, if you have one, and looks for `seed.<model>(...)` calls. These are Snaplet's custom per-row generator functions, arbitrary TypeScript, and cannot be mechanically converted. Every model with one is reported as needing manual review, listing which table it affects.
- `--output <PATH>` sets where the converted file is written. Default `seedy.yaml`.

**`seedy migrate neosync <JOB_JSON>`** reads a Neosync Job export, the JSON body returned by Neosync's `GetJob` API call. Neosync has no static config file on disk the way Snaplet does. Jobs live in Neosync's own database and are reached through its UI or API, so you need to export one first.

- Each column mapping with a transformer becomes a `mask:` (and, where seedy has a matching generator, a `generator:`) entry.
- Some transformers map exactly (an email transformer becomes `mask: fake, generator: email`; a SHA-256 hash transformer becomes `mask: hash`).
- Some map approximately: seedy's closest strategy is used, but the shape will not match exactly (Neosync's categorical transformer picks from a fixed value set, which is not carried over). These are still written to the output, flagged with a note explaining the gap.
- Custom code (JavaScript transformers, user-defined transformers) has no seedy equivalent and is reported as needing manual review, not written to the output.

Neither converter touches a database. Both only read the input file and write a `seedy.yaml`. Run `seedy plan` against your actual database afterward to check the result matches your real schema before running `up`, `clone`, or `mask` with it.

## Masking

`clone` and `mask` share the same masking logic and the same `seedy.yaml` format.

By default, both look at each column's name using the same detection as [Sensitive field detection](#sensitive-field-detection). If a column looks sensitive, it gets replaced with a deterministic fake value. Everything else is copied or left through unchanged.

"Deterministic" means the same source row always produces the same fake value, every time you run `clone` or `mask`, as long as the seed stays the same. This is not random noise, it is a stable, repeatable substitute.

You can override the strategy per column in `seedy.yaml`:

```yaml
version: 1
seed: default
tables:
  public.users:
    rows: 0
    columns:
      email:
        mask: hash
      phone:
        mask: redact
      internal_notes:
        mask: none
```

Strategies:

- `fake`. Deterministic synthetic replacement. This is the default for columns that look sensitive.
- `hash`. A deterministic one-way hash of the real value. Only works on text-like columns (text, varchar, citext). The result looks like `masked_a1b2c3...` and cannot be reversed back to the original value.
- `redact`. A fixed placeholder. NULL if the column allows NULL, otherwise a fixed value like `0` or `REDACTED` depending on the column type.
- `none`. Copies the real value through unchanged. Use this to turn off masking for a column the name-based detection got wrong.

A NULL value always stays NULL, no matter what strategy is set on the column.

Two rules are enforced and cannot be overridden:

- **A primary key column or a foreign key column can never be masked.** For `clone`, this is what lets keys carry over unchanged without rewriting every reference. For `mask`, it's even more important: there is no separate untouched copy to fall back to if a key gets corrupted in place. seedy rejects a config that tries to mask one of these columns before touching any database.
- **`redact` cannot be used on a column with a unique constraint** (other than the primary key). A fixed placeholder on every row would violate uniqueness. Use `hash` or `fake` there instead, both vary per row.

`mask` has one further requirement `clone` does not: a table with a column to mask must have a primary key. Masking needs a stable, ordered key to batch and checkpoint against. A table with a sensitive-looking column and no primary key is rejected with a clear error rather than skipped silently. Set `mask: none` on that column explicitly if you want to leave it alone.

## Subsetting

`--root "<table> WHERE <condition>"` clones only the rows that belong to a starting condition, instead of the whole database.

Example:

```
seedy clone $PROD_URL $DEV_URL --root "organizations WHERE id = 42"
```

This finds organization 42, then works outward in two steps:

1. **Everything that belongs to it.** Any row in another table with a foreign key pointing at an included row gets pulled in too, and this repeats outward. If organization 42 has users, and those users have orders, the users and orders are included.
2. **Everything it needs to exist.** Once step 1 is done, seedy looks at every included row's own foreign keys and pulls in whatever parent rows are required, so nothing points at a row that isn't there. If an order references a product, that product is pulled in.

Step 2 does not repeat step 1. A product pulled in because one order needs it does not bring along every other order that happens to reference the same product. This is what keeps the subset from growing into the whole database.

A table with no foreign key connection to anything in the subset is left empty on the target. Pure foreign-key-based subsetting cannot discover a table your application only looks up by, say, a hardcoded list, if nothing in the subset actually references it.

There is a safety cap on total row count. If a `--root` condition expands too far (a self-referencing table, like an org chart, is the usual cause), seedy stops and writes nothing to the target, rather than silently copying a partial, broken subset.

The condition after `WHERE` is passed straight through to your source database as SQL. It is not restricted to simple equality, you can write anything Postgres accepts in a WHERE clause.

## Mask-in-place and a snapshot-restore workflow

A common way teams refresh a lower environment (staging, a scratch database, a local copy) from production is entirely outside seedy: a cloud provider's own snapshot-and-restore mechanism copies the whole database at the storage level, into a new, temporarily-named instance, and only afterward is that instance renamed or repointed to take over the "staging" identifier. This is often preferred over a logical dump/restore because it barely touches the live source, doesn't depend on network throughput between the two environments, and sidesteps client/server version mismatches.

That workflow has no masking step by default. It's a block-level copy, so whatever the source has, the restored instance has too, in full, unmasked, the moment the restore finishes.

`seedy mask` is meant to be one new step inserted into that existing workflow, in one specific place: **after the restore finishes and is verified, but before the restored instance takes over the environment's real identifier or receives any live traffic.**

```
1. Snapshot the source.
2. Restore the snapshot into a new, temporarily-named instance.
3. Verify the restore (size, schema, freshness).
3.5  <-- seedy mask runs here, against the temporary instance's own connection string
4. Cut the new instance over to the environment's real identifier / DNS name.
5. (whatever else the workflow already does: credential reset, state reconciliation, traffic verification)
```

The ordering is the point. If masking happened after step 4 instead, the identifier that the rest of your system treats as "safe to use" would hold real, unmasked data for however long the masking run takes. Even if nobody happens to query it in that window, it's still sitting there. Masking before the cutover means the identifier the environment actually points at never, at any point, holds unmasked data.

Two things worth knowing before wiring this in:

- **`seedy mask` only ever needs one connection string.** It has no awareness of snapshots, cloud APIs, or which instance is "temporary" versus "real". From its side, this is just "mask this one Postgres database." Getting the right connection string to it, and only the right one, is entirely the operator's (or the surrounding script's) responsibility. Treat the target as if it might be a mistake waiting to happen: `--dry-run` first, review what it says it will touch, then a real run.
- **Check your database's TLS requirements before the first attempt.** Some managed Postgres services require an encrypted connection even when you're already tunneling through SSH, since the requirement is enforced by Postgres itself, not by the transport underneath. Pass `sslmode=require` in the connection string if a plain connection is refused with something like "no pg_hba.conf entry ... no encryption."

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

This applies the same way in `clone`. The only difference is which value gets written: `up` writes a freshly generated value, `clone` writes the real (or masked) value it already read from source.

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
| Serial and identity columns | Yes. `up` leaves them for Postgres to assign, then reads the result back. `clone` preserves the source's real value instead, and resyncs the target's sequence afterward so the next unrelated insert does not collide |
| Partitioned tables | Yes, seedy inserts into the parent table and lets Postgres route rows to partitions |
| citext, inet, cidr | Yes, but through a generic text value rather than a purpose built generator |
| CHECK constraints | Detected and shown as a warning and as comments in `seedy.yaml`, but not validated ahead of time. If a generated value fails a check, the whole run rolls back cleanly with an error |
| Composite types | Not supported. If a column has one and is `NOT NULL`, `up` fails with an error until you add an explicit override |

## Sensitive field detection

seedy looks at your column names and flags ones that look like they hold personal data: emails, phone numbers, names, dates of birth, addresses, IP addresses, card numbers, SSNs, and similar identifiers.

`seedy init` shows this as a banner, purely informational, since `up` generates everything synthetically anyway. `seedy clone` uses the same detection to decide which columns get masked by default, see [Masking](#masking).

This detection is based on column name patterns only. It does not know what the table is about. A column named `name` on a `users` table and a column named `name` on an `organizations` table are treated the same way right now, which is not always correct. Use an explicit `generator:` (for `up`) or `mask:` (for `clone`) override in `seedy.yaml` if a guess is wrong.

## Known limitations

- CHECK constraints are not validated before insert. seedy relies on the transaction rolling back cleanly if one fails.
- Composite types (custom `CREATE TYPE ... AS (...)` structs) have no generator yet.
- citext, inet, and cidr columns use a generic fallback rather than a purpose built generator.
- The column name heuristic does not know what a table represents, only the column name.
- The whole run is one transaction. This is correct and safe, but it is not built for generating or cloning millions of rows yet.
- There is no way to avoid duplicate data on a second `up` or `clone` run against the same tables. Truncate the target first if you want a clean set.
- `clone` does not create tables on the target. The target schema must already exist and match the source.
- `--root` subsetting only follows actual foreign key relationships. A table your application looks up outside of any foreign key is not discovered and stays empty on the target.
- JSON and JSONB columns are masked or left alone as a whole column. seedy does not look inside a JSON value for PII in a nested field.
- `mask` requires a primary key on any table it needs to touch (see [Masking](#masking)).
- `migrate` cannot convert arbitrary custom code (Snaplet's `seed.ts` generator functions, Neosync's JavaScript/user-defined transformers). These are reported as needing manual review, not guessed at.
- TLS support covers `sslmode=require`/`prefer` (encrypted, certificate not verified) and `disable` (plain). `verify-ca`/`verify-full` (full certificate chain and hostname verification) are not implemented yet and are rejected with a clear error rather than silently downgraded.

## Development

Requirements: Rust, Cargo, and Docker (for the test suite, which spins up real Postgres containers).

```
cargo build --workspace
cargo test --workspace
cargo clippy --workspace --all-targets
cargo fmt
```

The test suite includes:

- Unit tests for the value encoding, the dependency graph, the generators, and the masking transform.
- Integration tests that create real schemas in a throwaway Postgres container and check the results: composite keys, cycles, enums, arrays, JSONB, citext, partitioned tables, and more.
- Integration tests with two containers (source and target) for `clone`: key preservation, sequence resync, each masking strategy, the rules that reject unsafe masking configs, and subsetting (a diamond dependency, a self-referencing root, a cap abort).
- Integration tests for `mask`: batching across many rows, a genuinely interrupted-and-resumed run verified against independently-computed expected output (not just spot-checked), the same unsafe-config rejections as `clone`, and the row-count invariant.
- A smoke test that runs the actual compiled binary through `init` and `up`.

## Roadmap

Not built yet:

- **Table aware sensitive field detection**, so a `name` column is treated differently on a `users` table versus an `organizations` table.
- **Snapshot files.** `clone` currently needs a live connection to both the source and target database at once. A `snapshot` / `restore` split, where you extract once to a file and load it later without needing source access again, is not built.
- **Full TLS certificate verification** (`verify-ca`/`verify-full`), for setups that need it rather than just an encrypted connection.
- **Post-mask verification pass.** A second, independent check after `mask` completes, re-running the sensitive-field detection against the masked values to confirm they no longer look like real data, as defense in depth on top of the masking itself.

## License

MIT. See [LICENSE](LICENSE).
