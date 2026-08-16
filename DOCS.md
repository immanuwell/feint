# feint docs

This is the full reference for feint. For a quick overview, see [README.md](README.md).

## What feint is

feint is a command line tool for Postgres. It has three modes.

**Generate** reads your database schema and generates realistic, synthetic test data from nothing. Commands: `init`, `plan`, `up`.

**Clone** reads a real source database and writes a copy into a target database, keeping the same primary keys and foreign keys, and masking sensitive columns as it goes. Command: `clone`.

**Mask** rewrites a database's own sensitive columns in place, on that same database, no second database involved. Command: `mask`. This is for a workflow clone can't cover: a database that already got a full physical copy from somewhere else (a cloud snapshot restore is the common case), and now needs its own PII scrubbed before anyone treats it as safe to use.

Alongside the three modes, `feint migrate` converts another tool's config (Snaplet Seed, Neosync) into a starting `feint.yaml`, so switching tools doesn't mean starting from a blank file. `feint policy` writes ready-made masking rules for a data domain (PII, healthcare, payments) into a config, so you don't write every `mask:` override by hand.

`plan` only reads your schema, it never writes anything. `migrate` only reads a config file, never a database. `policy list` reads nothing at all. `init`, `up`, `clone`, `mask`, and `policy apply` all touch a database.

## Install

On Linux or macOS, install the prebuilt binary:

```
curl -fsSL ewry.net/feint.sh | sh
```

This installs to `~/.local/bin`. Set `FEINT_VERSION=X.Y.Z` before running it to pin a specific version instead of the latest release. Set `FEINT_INSTALL_DIR` to install somewhere else.

Or build from source. Requirements: Rust and Cargo (get them from rustup.rs), and access to a Postgres database.

```
git clone https://github.com/immanuwell/feint.git
cd feint
cargo build --release
```

The binary is at `target/release/feint`.

## Commands

### feint init

```
feint init <DATABASE_URL> [--config <PATH>] [--schema <NAME>]...
```

Connects to the database, reads the schema, and writes a config file.

- `<DATABASE_URL>` is a normal Postgres connection string, for example `postgres://user:pass@localhost/mydb`.
- `--config <PATH>` sets where to write the config. Default is `feint.yaml` in the current directory.
- `--schema <NAME>` sets which schema to read. Default is `public`. Pass it more than once to read more than one schema.

`init` prints a short report: table count, foreign key count, enum count, JSONB column count, any cyclic dependencies found, any CHECK constraints found, and a list of columns that look like they hold sensitive data (see [Sensitive field detection](#sensitive-field-detection)).

It then writes the config file. It does not insert any data.

### feint plan

```
feint plan <DATABASE_URL> [--config <PATH>] [--schema <NAME>]...
```

Reads the schema and shows what `feint up` would do, without touching the database.

It prints:

- The foreign key dependency tree. A table listed under another table means it has a foreign key pointing at it.
- The insertion order: which table gets filled first, second, and so on, and how many rows each one gets.
- Which groups of tables have a foreign key cycle, and how feint plans to resolve it.
- The total number of rows across all tables.
- A count of columns that look sensitive.

If a `feint.yaml` file exists at the given `--config` path, `plan` uses its row counts. If not, it uses the default row count for every table.

### feint up

```
feint up <DATABASE_URL> [--config <PATH>] [--seed <SEED>] [--schema <NAME>]... [--profile <PATH>]
```

Generates data and inserts it.

- `--config <PATH>` sets which config file to read. Default is `feint.yaml`.
- `--seed <SEED>` overrides the seed value from the config file for this run.
- `--schema <NAME>` sets which schema to read, same as `init` and `plan`.
- `--profile <PATH>` reads a file written by `feint profile` and generates against its captured shape (row counts, null rates, per-parent child-row distribution) instead of uniform defaults. See [Profile-driven generation](#profile-driven-generation).

The whole run happens inside one database transaction. If any row fails to insert, for example a CHECK constraint rejects a generated value, the entire transaction rolls back. Nothing is left half-written.

On success, `up` prints the total row count, the time taken, and confirms that constraints and foreign keys were satisfied.

### feint profile

```
feint profile <DATABASE_URL> --output <PATH> [--schema <NAME>]...
```

Captures a statistical shape from a real database: row counts, per-column null rates, and per-foreign-key cardinality (how many child rows each parent row has). Writes it to a file for `up --profile` to generate against later. Only ever runs aggregate `SELECT`s (`count(*)`, `count(*) FILTER (...)`, `GROUP BY` on join keys); no row's actual data ever leaves the database, only counts and ratios.

- `<DATABASE_URL>` is only ever queried with aggregate `SELECT`s.
- `--output <PATH>` sets where the profile file is written.
- `--schema <NAME>` sets which schema(s) to profile.

See [Profile-driven generation](#profile-driven-generation) for what gets captured, what it's used for, and what's deliberately out of scope.

### feint clone

```
feint clone <SOURCE_URL> <TARGET_URL> [--root "<table> WHERE <condition>"] [--config <PATH>] [--schema <NAME>]... [--strict] [--lockfile <PATH>]
```

Reads real rows from `SOURCE_URL` and writes them into `TARGET_URL`, masking sensitive columns as configured (see [Masking](#masking)).

- `<SOURCE_URL>` is only ever read from. feint opens it as a read only transaction at the database level, not just by convention.
- `<TARGET_URL>` is written to, inside one transaction. If anything fails, the whole thing rolls back and the target is left exactly as it was.
- `--root "<table> WHERE <condition>"` clones a subset instead of the whole database. See [Subsetting](#subsetting). Without `--root`, feint clones every table.
- `--config <PATH>` reads masking overrides from a `feint.yaml` file, if one exists. `rows:` is ignored for a table left at the default `strategy: mask` (every real row is cloned regardless of what `rows:` says), but is the target row count for a `strategy: generate` table. See [Hybrid clone](#hybrid-clone-mask--generate-in-one-run).
- `--schema <NAME>` sets which schema to read from source, same as the other commands.
- `--strict` / `--lockfile <PATH>`: see [Fail-closed masking](#fail-closed-masking---strict).

Primary keys and foreign keys are preserved exactly as they are on the source. This means:

- The target tables must already exist with a matching schema before you run `clone`. feint does not create tables.
- If you run `clone` twice into the same target without clearing it first, the second run fails on duplicate keys.
- Sequences and identity columns on the target are advanced past whatever was just inserted, so a normal insert afterward does not collide.

On success, `clone` prints the row count per table and confirms that keys were preserved.

### feint snapshot

```
feint snapshot <SOURCE_URL> --output <PATH> [--root "<table> WHERE <condition>"] [--config <PATH>] [--schema <NAME>]...
```

Reads real rows from `SOURCE_URL`, masks them exactly the way `clone` would, and writes the result to a single file instead of a target database. No target connection is needed at all for this step.

- `<SOURCE_URL>` is only ever read from, same read-only guarantee as `clone`.
- `--output <PATH>` sets where the snapshot file is written.
- `--root`, `--config`, `--schema` all mean exactly what they mean for `clone`.

A table with `strategy: generate` (see [Hybrid clone](#hybrid-clone-mask--generate-in-one-run)) is rejected before anything is read: a generate-strategy table's rows need a live target connection to resolve server-assigned columns via `RETURNING`, which a file replay can't provide. Snapshot a database with only `mask`-strategy tables, or remove the `strategy:` override for this run.

The file is gzip-compressed bincode, feint's own format, not meant for anything other than a later `feint restore`. It carries the already-masked row data and column names only, nothing about insertion order or foreign-key handling: `restore` recomputes that fresh from the target's own schema, which is what keeps the file small and keeps both sides trivially consistent with whatever the target schema actually is at restore time.

### feint restore

```
feint restore <SNAPSHOT_FILE> <TARGET_URL>
```

Loads a file written by `feint snapshot` into `TARGET_URL`, inside one transaction, same all-or-nothing guarantee as `clone`. No `--config` or `--schema` needed: the file already carries the finished, masked values, so there's nothing left to configure, and it already knows which schemas it touched.

- `<SNAPSHOT_FILE>` a path written by `feint snapshot`.
- `<TARGET_URL>` is written to. Same requirement as `clone`: matching tables must already exist.

`restore` introspects the target's own schema and builds a fresh insertion plan from it, the same way `clone` builds one from the source on every run. If the target schema drifted since the snapshot was captured (a column renamed, added, or removed), `restore` rejects the mismatched table with a clear error rather than guessing at a mapping. A table the snapshot has no data for (for instance, one outside a `--root` snapshot's subset) is left empty, the same way `--root` leaves an unrelated table empty on a live `clone`.

A snapshot file's format is versioned. A file written by a newer feint than the one running `restore` is rejected with a clear error rather than misread.

### feint mask

```
feint mask <DATABASE_URL> [--config <PATH>] [--schema <NAME>]... [--batch-size N] [--dry-run] [--yes] [--resume] [--max-batches N] [--skip-verify] [--strict] [--lockfile <PATH>] [--json]
```

Rewrites a single database's own sensitive columns in place. One connection, read and write. No second database, no key remapping, no row inserted or deleted, ever, only `UPDATE` on existing columns.

This is for a case `clone` does not cover: a database that already has a full, real copy of your data through some other means, most commonly a cloud provider's own snapshot-and-restore mechanism (see [Mask-in-place and a snapshot-restore workflow](#mask-in-place-and-a-snapshot-restore-workflow) below). By the time feint could get involved, the data already exists, unmasked, on one database. `clone` streams and masks between two databases; `mask` scrubs one database that already has everything.

- `<DATABASE_URL>` is both read from and written to.
- `--config <PATH>` reads masking overrides from `feint.yaml`, same format and same strategies as `clone` (see [Masking](#masking)). The default is the same too: a column that looks sensitive gets `fake`, everything else passes through.
- `--batch-size N` sets rows per `UPDATE` batch. Default 5000. Rows are processed in primary-key order, in batches, each batch its own transaction, not the whole table in one transaction.
- `--dry-run` reports which tables and columns would be touched, and how many rows, without writing anything. This is the recommended first step, always, before a real run.
- `--yes` skips the interactive confirmation prompt. Without it, `mask` prints the exact target and table/column list and asks you to type "yes" before writing anything. Needed for scripted or CI use.
- `--resume` continues a previous run that stopped partway through (crashed, was killed, or hit `--max-batches`), picking up exactly where it left off. Without `--resume`, a run refuses to start at all if it finds unfinished progress from an earlier attempt. You have to choose to continue it, feint will not guess.
- `--max-batches N` stops the whole run after N batches, leaving a valid, resumable checkpoint. Useful for pacing a very large run across more than one invocation. Unlimited if omitted.
- `--skip-verify` skips the post-mask verification pass described below. On by default.
- `--strict` / `--lockfile <PATH>`: see [Fail-closed masking](#fail-closed-masking---strict).
- `--json` prints one JSON object to stdout instead of the human-readable report, and suppresses every other stdout line (the confirmation prompt, if needed, moves to stderr). See [CI and scripted use](#ci-and-scripted-use) for the shape and the exit-code contract.

`mask` tracks its own progress in a small table it creates on the target, `_feint_mask_checkpoint`, one row per table it has touched. This is what makes `--resume` safe: each batch's `UPDATE` and its checkpoint update commit together, in the same transaction, so a row is read and masked exactly once, ever, no matter how many times a run gets interrupted and resumed. This matters specifically for the `hash` strategy, which is keyed off a column's real value. Re-masking an already-masked row would hash the masked output instead of the original, which is exactly what the checkpoint is there to prevent.

`_feint_mask_checkpoint` is excluded from every command's view of your schema, always, regardless of which schema it actually landed in. It's feint's own bookkeeping, not something `up`, `clone`, `plan`, `policy apply`, or `classify` will ever try to generate into, copy, mask, or track a classification for.

Before and after masking each table, `mask` checks the row count is unchanged. `mask` only ever runs `UPDATE`. A row-count mismatch is a hard error, not a warning, since it would mean something else wrote to the table while masking was running.

On success, `mask` prints the row count masked per table and confirms row counts and keys were untouched, then runs a post-mask verification pass and prints its result too.

#### Post-mask verification

After masking commits, `mask` re-reads the database and checks that each masked column's values have the shape masking should have produced:

- A `redact`-masked column: every value is null (if the column is nullable) or exactly the expected placeholder (if not).
- A `hash`-masked column: every value matches the `masked_<hex>` format.
- A `fake`-masked column: not every row shares the exact same value. On its own this doesn't prove a value is fake, but if every row in a column that should vary per row has collapsed to one identical value, the per-row identity keying broke, and that is worth knowing before you trust the database.

This is not a content-based PII detector. It cannot tell you whether a `fake` value merely looks like a real name. What it catches is pipeline bugs: a batch that silently didn't get processed, a malformed hash, a column that should have been nulled out but wasn't. Defense in depth on top of masking itself, not a replacement for reviewing what you configured.

If verification finds an issue, `mask` reports it and exits with an error, even though the masking run itself already committed successfully. The two are separate: your data is masked and the row-count/key guarantees above still hold, but verification is telling you something about the *result* looks wrong and needs a look before you treat the database as safe.

### feint migrate

```
feint migrate snaplet <CONFIG_TS> [--seed-ts <PATH>] [--output <PATH>]
feint migrate neosync <JOB_JSON> [--output <PATH>]
```

Converts another tool's config into a `feint.yaml`, as a starting point. Best effort, not a full translation. Both prompt through what got converted, what needs manual review, and why, so nothing is silently dropped or guessed.

**`feint migrate snaplet <CONFIG_TS>`** reads a Snaplet Seed `seed.config.ts` file.

- Literal table names in its `select` array become `tables:` entries in the output.
- A glob pattern (`"public.*"`) or an exclude entry (`"!archive*"`) cannot become a literal table list on its own. These are reported as notes instead, telling you to run `feint init` and adjust the result by hand.
- `--seed-ts <PATH>` also reads a `seed.ts` file, if you have one, and looks for `seed.<model>(...)` calls. These are Snaplet's custom per-row generator functions, arbitrary TypeScript, and cannot be mechanically converted. Every model with one is reported as needing manual review, listing which table it affects.
- `--output <PATH>` sets where the converted file is written. Default `feint.yaml`.

**`feint migrate neosync <JOB_JSON>`** reads a Neosync Job export, the JSON body returned by Neosync's `GetJob` API call. Neosync has no static config file on disk the way Snaplet does. Jobs live in Neosync's own database and are reached through its UI or API, so you need to export one first.

- Each column mapping with a transformer becomes a `mask:` (and, where feint has a matching generator, a `generator:`) entry.
- Some transformers map exactly (an email transformer becomes `mask: fake, generator: email`; a SHA-256 hash transformer becomes `mask: hash`).
- Some map approximately: feint's closest strategy is used, but the shape will not match exactly (Neosync's categorical transformer picks from a fixed value set, which is not carried over). These are still written to the output, flagged with a note explaining the gap.
- Custom code (JavaScript transformers, user-defined transformers) has no feint equivalent and is reported as needing manual review, not written to the output.

Neither converter touches a database. Both only read the input file and write a `feint.yaml`. Run `feint plan` against your actual database afterward to check the result matches your real schema before running `up`, `clone`, or `mask` with it.

### feint policy

```
feint policy list
feint policy apply <NAME> <DATABASE_URL> [--config <PATH>] [--schema <NAME>]... [--force]
```

Prebuilt masking rules for a data domain, so you don't write every `mask:` override in `feint.yaml` by hand. `feint policy list` prints the available templates. `feint policy apply` connects to your database, finds columns matching the template's patterns, and writes `mask:` (and, where one applies, `generator:`) into the config file.

Built-in policies:

- `pii`. Names, contact details, government IDs, dates of birth, addresses.
- `healthcare`. Medical record numbers, diagnoses, medications, patient identity, policy and beneficiary numbers, account numbers, license and certificate numbers, vehicle and device identifiers, URLs, IP addresses, fax numbers.
- `payments`. Card numbers, CVVs, account and routing numbers, cardholder identity.

A policy is a starting point, not a compliance certification. It matches on column name patterns, the same kind of heuristic [Sensitive field detection](#sensitive-field-detection) uses, so review what it applied before trusting it with real data. Use `--config` on a fresh path first if you want to inspect the result before overwriting an existing file.

`healthcare` targets HIPAA's Safe Harbor identifier list as closely as a column-name policy reasonably can, with one deliberate gap: Safe Harbor requires ages over 89 to be aggregated to "90+", but `age` is too short and too common a substring of ordinary words (storage, message, usage, package, average, ...) to pattern-match safely, so this policy does not include it. Add an explicit `mask: redact` override by hand for a real age column if that identifier class matters to you. See `crates/feint-core/src/policy.rs` for the exact rule list.

Two rules, same as everywhere else in masking:

- A primary key or foreign key column is never matched, even if its name looks sensitive. `feint policy apply` reports how many columns were skipped for this reason.
- A column that already has an explicit `mask:` set is left alone, so applying a policy never silently overwrites a choice you already made by hand. Pass `--force` to overwrite anyway. This also means you can apply more than one policy to the same config: run `pii` then `payments`, and columns both would touch (like `email`) keep whichever policy set them first.

### feint classify

```
feint classify <DATABASE_URL> [--config <PATH>] [--schema <NAME>]... [--lockfile <PATH>] [--write] [--check] [--json]
```

Reports which columns look sensitive by name and what strategy they'd resolve to, then compares that against a committed lockfile so a schema change nobody reviewed shows up as a failure instead of silence. See [Fail-closed masking](#fail-closed-masking---strict) for why this exists and how it fits with `mask --strict` and `clone --strict`.

- With no flags, prints the classification report and, if a lockfile exists, the diff against it. Always exits 0. This is the "what would this decide" mode.
- `--write` approves the current classification: writes it to the lockfile. Do this after reviewing the report, and commit the file.
- `--check` exits non-zero if the lockfile is missing, or if the live schema has drifted from it. This is the CI mode.
- `--lockfile <PATH>` sets where the lockfile lives. Default `feint.lock.yaml`.
- `--json` prints one JSON object to stdout instead of the human-readable report and diff. See [CI and scripted use](#ci-and-scripted-use).

## Masking

`clone` and `mask` share the same masking logic and the same `feint.yaml` format.

By default, both look at each column's name using the same detection as [Sensitive field detection](#sensitive-field-detection). If a column looks sensitive, it gets replaced with a deterministic fake value. Everything else is copied or left through unchanged.

"Deterministic" means the same source row always produces the same fake value, every time you run `clone` or `mask`, as long as the seed stays the same. This is not random noise, it is a stable, repeatable substitute.

You can override the strategy per column in `feint.yaml`:

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

- **A primary key column or a foreign key column can never be masked.** For `clone`, this is what lets keys carry over unchanged without rewriting every reference. For `mask`, it's even more important: there is no separate untouched copy to fall back to if a key gets corrupted in place. feint rejects a config that tries to mask one of these columns before touching any database.
- **`redact` cannot be used on a column with a unique constraint** (other than the primary key). A fixed placeholder on every row would violate uniqueness. Use `hash` or `fake` there instead, both vary per row.

`mask` has one further requirement `clone` does not: a table with a column to mask must have a primary key. Masking needs a stable, ordered key to batch and checkpoint against. A table with a sensitive-looking column and no primary key is rejected with a clear error rather than skipped silently. Set `mask: none` on that column explicitly if you want to leave it alone.

## JSON path masking

The strategies above treat a `json`/`jsonb` column as one opaque value: `mask: fake` replaces the whole thing, `mask: hash` and `mask: redact` do too, and `mask: none` leaves it alone. That is often too blunt. A `profile` column holding `{"bio": "...", "contact": {"email": "...", "phone": "..."}}` usually needs its `contact.email` masked while `bio` stays intact and readable, not the whole blob wiped.

`json_paths` masks specific keys inside the value and leaves everything else, including the rest of the object's shape, untouched:

```yaml
version: 1
seed: default
tables:
  public.users:
    rows: 0
    columns:
      profile:
        json_paths:
          contact.email: fake
          contact.ssn: redact
```

A path is a dot-separated chain of object keys (`contact.email` means `value["contact"]["email"]`). Each path gets its own strategy from the same four (`fake`, `hash`, `redact`, `none`), applied only to that leaf:

- `redact` replaces the leaf with `null`, any JSON type.
- `hash` replaces a leaf with a deterministic `masked_<hex>` string, same as column-level `hash`.
- `fake` replaces a leaf with a synthetic value that keeps its JSON type: a string leaf gets fake text (using the same key-name heuristic as [Sensitive field detection](#sensitive-field-detection) on the leaf's own key, so an `email` key gets an email-shaped fake value), a number leaf gets a random number, a boolean leaf gets a random boolean. A leaf that's itself an object or array has no well-defined "fake" replacement, so `fake` redacts it to `null` instead of guessing a shape.
- `none` is a no-op, useful only to document that a path was looked at and is fine as-is.

A row whose document doesn't have a configured path (a sparse/optional key, or a document that isn't even an object at that point) is left alone for that row, not treated as an error: not every row's JSON necessarily has the same shape.

`json_paths` and a whole-column `mask:` (other than the default `mask: none`) are mutually exclusive on the same column: set one or the other, not both, since it's ambiguous what "mask the whole column AND mask this one path inside it" should mean. `json_paths` is also rejected on any column that isn't `json`/`jsonb`, and on a primary-key or foreign-key column, same as a whole-column `mask:` override.

Scope, on purpose:

- Only object keys are addressed. A path through an array (`items.0.name`) isn't supported: array elements have no stable "key" to mask consistently across rows with differently-sized arrays.
- `feint init`'s sensitive-field banner samples up to 200 real, non-null rows per JSON/JSONB column and looks at their key names (never the values) up to 2 levels of nesting, flagging any key that matches the same name heuristic used for plain columns. This is a name-based hint to help you write `json_paths:` entries, not an automatic config: nothing gets written for you.
- The post-mask verification pass (on by default after `mask`) does not check `json_paths` rules; it verifies whole-column strategies only. A `json_paths`-masked column is treated like any other unmasked column for verification purposes.

## Hybrid clone (mask + generate in one run)

A table-level `strategy:` key in `feint.yaml` lets one `clone` run mask real rows for the tables that matter and generate synthetic padding for the rest, in the same run, with foreign keys holding correctly across the boundary:

```yaml
version: 1
seed: default
tables:
  public.users:
    rows: 0
  public.events:
    rows: 500000
    strategy: generate
```

`users` isn't mentioned beyond `rows:` (which `clone` ignores for it anyway), so it keeps the default `strategy: mask`: every real row, cloned and masked exactly like plain `clone` always has. `events` is `strategy: generate`: `clone` never reads its real rows at all, and instead synthesizes 500000 rows the same way `up` would, each one's foreign key sampled from the real, already-cloned `users` rows that now exist on the target.

This is the answer to a specific, well-known problem: a staging environment built from a tiny synthetic dataset makes Postgres pick different query plans than production, because the table statistics (row counts, cardinality, distribution) are nothing like the real thing. Fully synthetic data everywhere doesn't fix this, and a full production copy is often too much data, too slow, or too sensitive to move as-is. Masking the tables that actually drive query plans (the ones your slow queries join on) while padding high-volume, lower-stakes tables (logs, events, activity) with synthetic rows gets a database that's cheap to build, safe to hand out, and shaped enough like production for `EXPLAIN` to tell the truth.

Two things to know before using it:

- **`rows:` changes meaning for a `generate` table.** For a `mask` table it's ignored, same as plain `clone` today (every real row is cloned, however many there are). For a `generate` table it's the exact target row count, same field `up` reads.
- **A `mask` table's foreign key can never point at a `generate` table.** `mask` preserves the source's real foreign-key values exactly as they are; a `generate` table's rows have an entirely fabricated key space that those real values essentially never happen to match. `clone` rejects this combination before touching either database, not partway through. The other direction, a `generate` table referencing a `mask` table, is exactly the supported case above. Two `generate` tables referencing each other works too, the same way two tables generated by `up` would.
- **Every table inside one foreign-key cycle must share the same strategy.** A self-referencing table, or two tables that reference each other, are always `mask` together or `generate` together, never split. This is a real, structurally rare case (most schemas have no FK cycles at all; see [Foreign keys and cycles](#foreign-keys-and-cycles)), and `clone` rejects a config that tries to mix strategies inside one before touching either database.

`--root` composes with this cleanly: subsetting only changes which real rows a `mask` table pulls from source. A `generate` table always produces its full configured `rows:`, regardless of `--root`, and its synthesized foreign keys only ever point at whatever subset of parent rows actually got cloned.

## Fail-closed masking (--strict)

The name-based detection in [Masking](#masking) is a convenience, not a guarantee. A brand new column that the heuristic doesn't recognize silently resolves to `mask: none`, and neither `clone` nor `mask` will tell you that happened. Nobody notices until the unmasked column shows up somewhere it shouldn't.

`--strict` closes that gap by requiring an approved, committed answer to "have I looked at every column" instead of trusting the heuristic every single run:

```
feint classify $PROD_URL --write         # review the report, then approve it
git add feint.lock.yaml && git commit    # commit the approval

feint mask $STAGE_URL --strict           # refuses to run if the schema drifted since the approval
feint clone $PROD_URL $DEV_URL --strict  # same check, same flag
```

`--strict` runs the same check as `feint classify --check`, before any table is read or written:

1. If `feint.lock.yaml` doesn't exist yet, the run refuses to start. There is nothing to compare against, so there is nothing to trust.
2. If it exists, feint classifies the live schema the same way `feint classify` does, and compares it column by column against the lockfile. Any difference, a new column, a removed column, or a column whose resolved strategy changed, fails the run and prints exactly which columns changed and how.
3. Only an exact match lets the run proceed.

This is what makes the difference concrete: a `feint mask` run with no `--strict` flag masks whatever the heuristic currently decides, silently, every time, even if that decision changed since the last run. A `feint mask --strict` run only ever masks a schema a human has actually looked at and approved, and fails loudly the moment that stops being true, which is the property teams describe wanting when they say masking should be "enforced by construction, not by convention."

Wire `feint classify --check` (not `--write`) into CI as a separate, cheap step: it fails fast on drift without needing a database write, and it's a natural gate before `--strict` mask/clone runs later in the same pipeline.

Two things `--strict` does not do:

- It does not detect PII missed by the [naming heuristic](#sensitive-field-detection) itself. If a column named `notes` happens to hold something sensitive, `--strict` will not flag it, because the heuristic doesn't flag it either. `--strict` guarantees every column's classification was consciously reviewed at least once, not that the review was correct.
- It does not look inside JSON or JSONB values. See [Known limitations](#known-limitations).

## CI and scripted use

`mask` and `classify` are both meant to run unattended: on a schedule, in a pipeline step, right after a snapshot restore. This section is the contract a script can rely on.

**Build once, restore per job.** `feint snapshot`/`feint restore` (see the command reference above) split capturing a masked database from loading it, specifically for this. Run `feint snapshot` once, on a schedule or whenever the source changes meaningfully, commit or cache the resulting file, then have every CI job (per PR, per branch, whatever the pipeline needs) run `feint restore` against its own throwaway database. Every job gets an identical, already-masked dataset without re-reading the source or re-running masking N times.

**Exit codes.** 0 means success. Any non-zero exit means something needs attention: a config error, a rejected masking config, an aborted confirmation, a post-mask verification failure, a `--strict` refusal, or a `--check` drift. feint does not currently distinguish failure reasons by exit code number, only by 0 versus non-zero, so a script should treat any non-zero exit as "stop, don't trust this database yet" and read stderr for why.

**Non-interactive runs.** Pass `--yes` to `mask` so it never waits on a confirmation prompt. Without it, `mask` blocks on stdin, which hangs a CI job rather than failing it.

**`--json`.** Both `mask` and `classify` accept `--json`, which prints exactly one JSON object to stdout and nothing else, so a script can pipe it straight into `jq` or a language's JSON parser. Human-readable text (headings, per-table lines, the interactive prompt if `--yes` wasn't passed) either moves to stderr or is suppressed. This holds even when combined with `--strict`: `mask --strict --json` still prints only one JSON object on a successful run.

`classify --json` shape:

```json
{
  "lockfile": "feint.lock.yaml",
  "columns": {"public.users.email": {"sensitive": true, "strategy": "fake"}},
  "diff": {"new_columns": [], "removed_columns": [], "changed_columns": []},
  "written": false
}
```

`diff` is `null` when there's no lockfile to compare against yet (or right after `--write`, since there's nothing to diff against the file you just wrote).

`mask --json` shape, on a real run:

```json
{
  "target": "user@host:5432/dbname",
  "tables": [{"table": "public.users", "rows": 234}],
  "total_rows": 234,
  "verification": {"ok": true, "issues": []}
}
```

`mask --dry-run --json` shape:

```json
{"dry_run": true, "tables": [{"table": "public.users", "rows": 234}], "total_rows": 234}
```

One honest limitation: `--json` shapes the stdout of a run that completed its masking pass, including one that fails post-mask verification (`verification.ok` is `false`, the issues are listed, and the process still exits non-zero). It does not apply to a hard mid-run error (a dropped connection, a row-count mismatch) or to a `--strict` refusal before any table was touched: those print a human-readable message to stderr and exit non-zero, with no JSON on stdout at all, since there is no completed run to summarize.

**A GitHub Actions example**, gating a staging refresh on a clean classification, then masking and reporting how much got touched:

```yaml
- name: Check classification hasn't drifted
  run: feint classify "$STAGING_URL" --check

- name: Mask the restored snapshot
  run: feint mask "$STAGING_URL" --yes --strict --json > mask-result.json

- name: Record what got masked
  run: echo "Masked $(jq '.total_rows' mask-result.json) rows" >> "$GITHUB_STEP_SUMMARY"
```

The first step is a cheap, read-only gate: it fails the job outright if a new column showed up since the lockfile was last approved, before anything is written. `mask --strict` runs the same check again immediately before writing, as a second, independent line of defense, and both a `--strict` refusal and a post-mask verification failure already exit non-zero on their own, no extra step needed to catch either. The third step only runs if the second one succeeded, and exists to make the row count visible in the job's summary rather than buried in a log, using the `--json` output the second step already produced.

## Deterministic identity

The same seed applied to the same real row always produces the same fake value. Not just within one run, and not just within one command: the guarantee holds across `clone` and `mask`, and across as many separate runs as you like, as long as the seed, the table, the column, and the row's primary key are the same.

Concretely:

```
prod.users, id 9281:
  Alice Thompson, alice@example.com

feint clone $PROD_URL $DEV_URL --config feint.yaml   (seed: team-default)
  dev.users, id 9281: Maria Stone, maria.stone@example.test

a week later, a fresh snapshot restore + feint mask, same seed:
  stage.users, id 9281: Maria Stone, maria.stone@example.test
```

User 9281 gets the same fake identity every time, on every database, because both commands derive the fake value from the same inputs: the seed in `feint.yaml`, the table's schema-qualified name, the column name, and the row's real primary key. Neither command looks at the other's output, and neither needs to. The math just agrees.

This is not a coincidence you have to maintain by hand. It falls out of `clone` and `mask` sharing the same masking code path (see [Masking](#masking) above) and both keying off the row's real, unmasked primary key rather than an insertion order or a row number that could differ between two databases. A test proves this directly: `cargo test --test cross_mode_identity -- --nocapture` clones a database with masking, separately masks an independent copy of the same source data in place, and asserts the two runs produced byte-identical fake values for every row.

What changes the fake identity a row gets:

- A different `seed` in `feint.yaml`, or a different `--seed` passed to a command that accepts one.
- A different table or column name. Identity is per-column, not per-row: the fake email for user 9281 has nothing to do with the fake name for user 9281 beyond both being derived from the same seed.
- A different primary key. If a row's real PK changes between two databases (rare, but possible if one was reloaded with new IDs), its fake identity changes too, since the PK is the whole basis of the identity.

What does not change it: which command reached the row, which database it's sitting in, how many other rows are around it, or how much time passed between runs.

## Subsetting

`--root "<table> WHERE <condition>"` clones only the rows that belong to a starting condition, instead of the whole database.

Example:

```
feint clone $PROD_URL $DEV_URL --root "organizations WHERE id = 42"
```

This finds organization 42, then works outward in two steps:

1. **Everything that belongs to it.** Any row in another table with a foreign key pointing at an included row gets pulled in too, and this repeats outward. If organization 42 has users, and those users have orders, the users and orders are included.
2. **Everything it needs to exist.** Once step 1 is done, feint looks at every included row's own foreign keys and pulls in whatever parent rows are required, so nothing points at a row that isn't there. If an order references a product, that product is pulled in.

Step 2 does not repeat step 1. A product pulled in because one order needs it does not bring along every other order that happens to reference the same product. This is what keeps the subset from growing into the whole database.

A table with no foreign key connection to anything in the subset is left empty on the target. Pure foreign-key-based subsetting cannot discover a table your application only looks up by, say, a hardcoded list, if nothing in the subset actually references it.

There is a safety cap on total row count. If a `--root` condition expands too far (a self-referencing table, like an org chart, is the usual cause), feint stops and writes nothing to the target, rather than silently copying a partial, broken subset.

The condition after `WHERE` is passed straight through to your source database as SQL. It is not restricted to simple equality, you can write anything Postgres accepts in a WHERE clause.

## Mask-in-place and a snapshot-restore workflow

A common way teams refresh a lower environment (staging, a scratch database, a local copy) from production is entirely outside feint: a cloud provider's own snapshot-and-restore mechanism copies the whole database at the storage level, into a new, temporarily-named instance, and only afterward is that instance renamed or repointed to take over the "staging" identifier. This is often preferred over a logical dump/restore because it barely touches the live source, doesn't depend on network throughput between the two environments, and sidesteps client/server version mismatches.

That workflow has no masking step by default. It's a block-level copy, so whatever the source has, the restored instance has too, in full, unmasked, the moment the restore finishes.

`feint mask` is meant to be one new step inserted into that existing workflow, in one specific place: **after the restore finishes and is verified, but before the restored instance takes over the environment's real identifier or receives any live traffic.**

```
1. Snapshot the source.
2. Restore the snapshot into a new, temporarily-named instance.
3. Verify the restore (size, schema, freshness).
3.5  <-- feint mask runs here, against the temporary instance's own connection string
4. Cut the new instance over to the environment's real identifier / DNS name.
5. (whatever else the workflow already does: credential reset, state reconciliation, traffic verification)
```

The ordering is the point. If masking happened after step 4 instead, the identifier that the rest of your system treats as "safe to use" would hold real, unmasked data for however long the masking run takes. Even if nobody happens to query it in that window, it's still sitting there. Masking before the cutover means the identifier the environment actually points at never, at any point, holds unmasked data.

Two things worth knowing before wiring this in:

- **`feint mask` only ever needs one connection string.** It has no awareness of snapshots, cloud APIs, or which instance is "temporary" versus "real". From its side, this is just "mask this one Postgres database." Getting the right connection string to it, and only the right one, is entirely the operator's (or the surrounding script's) responsibility. Treat the target as if it might be a mistake waiting to happen: `--dry-run` first, review what it says it will touch, then a real run.
- **Check your database's TLS requirements before the first attempt.** Some managed Postgres services require an encrypted connection even when you're already tunneling through SSH, since the requirement is enforced by Postgres itself, not by the transport underneath. Pass `sslmode=require` in the connection string if a plain connection is refused with something like "no pg_hba.conf entry ... no encryption."
- **No superuser needed, which matters here specifically.** The temporary instance in step 3.5 is exactly the kind of managed Postgres (RDS, Aurora, Cloud SQL, Neon) that will not grant superuser and cannot install an extension. feint doesn't need either: it's a normal client connection that reads and writes rows like any application would. Extension-based masking tools cannot run this step at all on those platforms; feint doesn't notice the difference.

## The feint.yaml file

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
- A table can also set `strategy: generate`, which only means something to `clone` (`up` always generates, `mask` never does). See [Hybrid clone](#hybrid-clone-mask--generate-in-one-run).

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

Built in generator names: `email`, `phone`, `first_name`, `last_name`, `person_name`, `bool`, `int2_range`, `int4_range`, `int8_range`, `decimal`, `float4`, `float8`, `uuid`, `timestamp`, `timestamptz`, `date`, `json_object`, `bytea`, `inet`, `tsvector`, `point`, `line`, `lseg`, `box`, `path`, `polygon`, `circle`, `vector`, `lorem_word`.

### CHECK constraint comments

If a table has CHECK constraints, `init` adds them as comments above that table in the config file, so you can see them while editing. Comments are just for you to read. feint does not parse them, and they are dropped if you regenerate the file.

## How generation works

For each column, feint picks a generator in this order:

1. An explicit `generator:` in `feint.yaml`, if you set one.
2. A guess based on the column name, but only if the column's declared type is text-like (`text`/`varchar`/`bpchar`/`citext`). For example a column named `email` or containing `email` gets the email generator. A column ending in `_name` gets a person name generator. A non-text column whose name happens to match (`is_email_verified boolean`, `email_flags integer`) falls through to the type-based guess instead, since the name heuristic only ever produces text.
3. A guess based on the column type. A `uuid` column gets a UUID. An `int4` column gets a random integer. A `timestamptz` column gets a random recent timestamp. And so on.

A generated text value that's too long for a `varchar(N)`/`bpchar(N)` column is truncated to fit, rather than left for Postgres to reject.

If none of these apply and the column type is one feint does not understand, and the column is `NOT NULL`, `up` fails with a clear error naming the column. You then add an explicit `generator:` override for it.

### Determinism

Every value feint generates comes from a random number generator seeded from a hash of four things: your `seed`, the table name, the column name, and the row's position. Same inputs, same hash, same value. This means:

- Running `feint up` twice with the same seed against the same empty schema produces byte for byte identical data.
- Changing the seed changes every value, but running the new seed twice again gives you that new set of values every time.
- This does not deduplicate or diff against existing rows. Running `up` twice without truncating the tables first adds a second copy of the data.

## Foreign keys and cycles

feint builds a dependency graph from your foreign keys and inserts tables in the right order: a referenced table always gets its rows before the table that references it.

### Composite foreign keys

If a foreign key spans more than one column, feint samples a full matching row from the referenced table, not each column independently. This avoids generating column combinations that never actually appeared together.

### Foreign keys under a UNIQUE constraint

If a table has a `UNIQUE` constraint (single-column or composite, including a bare `CREATE UNIQUE INDEX` with no backing constraint) over one or more foreign key columns, feint retries a colliding row with a different sampled value instead of letting Postgres reject it on a duplicate-key error. If the referenced table doesn't have enough distinct rows to fill the constraint without a collision, `up` fails with a clear error telling you to increase `rows:` on the referenced table.

### Logical foreign keys

Some schemas have a relationship that isn't a real PostgreSQL foreign key at all, but application code (usually a trigger) still depends on it. A common shape: table B has a column that names table A's row, but no `REFERENCES` constraint was ever declared, and a trigger on table B fails unless that column actually points at a real row in table A.

Declare the relationship by hand under a table's `logical_foreign_keys:` key:

```yaml
version: 1
seed: default
tables:
  public.conversations:
    rows: 100
    logical_foreign_keys:
      - columns: [account_id]
        ref_table: public.accounts
        ref_columns: [id]
```

feint merges this into the schema's real foreign keys before planning insertion order, so the column gets sampled from `accounts.id` exactly like a declared FK would, instead of being generated independently. `ref_table` is `schema.table`, same format as a `feint.yaml` table key. There is no way to infer this automatically. You have to know the real relationship and declare it yourself.

### Self references and cycles

Some schemas have a table that references itself, like an `employees` table with a `manager_id` column pointing back at `employees.id`. Some schemas have two or more tables that reference each other in a loop.

feint resolves these in one of three ways, in this order:

1. **Deferred.** If the foreign key is declared `DEFERRABLE`, feint plans out every row's key up front, wires up the references, and lets Postgres check the constraint at commit time instead of at insert time.
2. **Null then backfill.** If the foreign key column is nullable, feint inserts the row with that column set to null, then runs an `UPDATE` afterward once every row in the cycle exists.
3. **Error.** If the foreign key is `NOT NULL` and not `DEFERRABLE`, there is no safe way to insert it. feint stops and prints an error naming the exact tables and constraints involved, before writing anything. Fix this by making the column nullable or marking the constraint `DEFERRABLE`.

This applies the same way in `clone`. The only difference is which value gets written: `up` writes a freshly generated value, `clone` writes the real (or masked) value it already read from source.

## Bulk loading

`up`, `clone`, and `restore` all write rows through Postgres's `COPY ... FROM STDIN` protocol wherever they can, instead of chunked, parameterized `INSERT` statements. `COPY` has no per-statement bind-parameter ceiling and no per-row statement-planning overhead, which is what actually gets in the way of a large run: the old `INSERT` path capped out at a few hundred rows per statement, needing hundreds or thousands of round trips for anything past the tens of thousands of rows.

Two things `COPY` cannot do, so these fall back to the older `INSERT` path automatically, no configuration needed:

- **`RETURNING`.** GENERATE mode needs the database-assigned value back for any table another table's foreign key might sample (see [How generation works](#how-generation-works) above): feint works out schema-wide which tables that is once per run, and only tables nothing references take the `COPY` path. A table with a lot of configured `rows:` that nothing else in the schema points at (an events table, a log table, an activity feed) is exactly the case this is for.
- **`OVERRIDING SYSTEM VALUE`.** `clone` and `restore` need this to preserve a real `GENERATED ALWAYS AS IDENTITY` value from the source rather than letting Postgres assign a new one. A table with this kind of column keeps using `INSERT`; every other `clone`/`restore` table uses `COPY`.

Verified directly, not just claimed: an integration test clones, generates, and restores 20,000 rows through each of these paths and checks every row landed with the correct value, well past the point the old chunked `INSERT` path would have needed 40-plus separate statements. This is a real, measured number, not "millions" rounded up. The whole run is still one transaction with every row held in memory before any write, so this removes the per-statement ceiling, not the memory one. A genuinely unbounded, constant-memory streaming run is a further step, not built yet.

## Profile-driven generation

A uniform `rows:` count per table means a uniform number of children per parent: with `orders: rows: 500` and `users: rows: 100`, every user ends up with roughly 5 orders. Production never looks like that. Most users have one or two orders; a handful have hundreds. That shape, not just the total row count, is what tends to change which query plan Postgres picks, which is exactly the thing a uniform synthetic dataset gets wrong.

`feint profile` captures that shape from a real database, and `up --profile` generates against it instead of a flat count:

```
feint profile postgres://prod-host/myapp --output prod.profile.yaml
feint up postgres://localhost/myapp_dev --profile prod.profile.yaml
```

Three things get captured, per table:

- **Row count.** Used as the default `rows:` for a table you haven't explicitly configured in `feint.yaml`. An explicit `rows:` still wins over the profile; the profile only fills in what you didn't set.
- **Null rate**, per nullable column. `up` rolls a weighted coin for that column on every row instead of never generating NULL.
- **Cardinality**, per foreign key: the real distribution of "how many child rows does each parent have," captured as a histogram (`count(*) FILTER`/`GROUP BY` on the join, not a peek at any row's actual data). At generate time, `up` visits each of the parent table's rows once, draws a child count from that histogram, and generates exactly that many child rows pointing at it, instead of sampling a random parent independently per child row. The result: a real long tail, not a bell curve around the mean.

Scope, on purpose:

- Cardinality is only captured (and only used) for a **single-column** foreign key referencing a **single-column** unique/primary key. A composite key is skipped, not approximated.
- If a table has more than one foreign key with a captured profile, the first one (in the table's own foreign-key order) drives the row count and distribution; any other foreign key on that table still gets an ordinary per-row random sample, same as without a profile.
- Enum and boolean value frequencies (`status: active 60%, pending 30%, cancelled 10%` instead of an even split across declared variants) are not captured yet: a natural next step, not built.
- `feint plan`'s row-count estimate does not read a profile; it always shows the flat `rows:`/default count, even for a table you intend to run with `--profile`.
- Nothing sensitive ever leaves the source database. Every value written to the profile file is a count or a ratio; no row's actual column value is ever read for this.
- A profile is matched to a table by schema-qualified name, the same way `feint.yaml`'s `tables:` keys are. Capture and generate should point at databases with the same schema (same table and column names), the normal case for this feature (a production source, a dev/staging target).

## Supported Postgres features

| Feature | Support |
|---|---|
| Composite foreign keys | Yes |
| Self referencing foreign keys | Yes |
| Foreign key cycles | Yes, see above |
| Enums | Yes, picks a random declared value |
| Domains | Yes, generates a value for the underlying base type |
| Arrays | Yes, generates a short array of the element type. Reading an array back out of Postgres (`clone`, `mask`) round-trips correctly in both text and binary wire format |
| JSONB and JSON | Yes, generates a small JSON object |
| tsvector | Yes, `up` generates a short vector of positioned lexemes and `clone`/`mask` read it through PostgreSQL's canonical text representation |
| Geometric types | Yes, `up` generates `point`, `line`, `lseg`, `box`, `path`, `polygon`, and `circle` values; `clone`/`mask` use their canonical text representations |
| pgvector | Yes, `up` honors the column's declared `vector(N)` dimension; `clone`/`mask` use its canonical text representation |
| UUID primary keys | Yes, generated client side so `--seed` stays reproducible even when the column has a `DEFAULT gen_random_uuid()` |
| Serial and identity columns | Yes. `up` leaves them for Postgres to assign, then reads the result back. `clone` preserves the source's real value instead, and resyncs the target's sequence afterward so the next unrelated insert does not collide |
| Partitioned tables | Yes, feint inserts into the parent table and lets Postgres route rows to partitions |
| citext, inet, cidr | Yes, but through a generic text value rather than a purpose built generator |
| CHECK constraints | Detected and shown as a warning and as comments in `feint.yaml`, but not validated ahead of time. If a generated value fails a check, the whole run rolls back cleanly with an error |
| Composite types | Not supported. If a column has one and is `NOT NULL`, `up` fails with an error until you add an explicit override |

## Sensitive field detection

feint looks at your column names and flags ones that look like they hold personal data: emails, phone numbers, names, dates of birth, addresses, IP addresses, card numbers, SSNs, and similar identifiers.

`feint init` shows this as a banner, purely informational, since `up` generates everything synthetically anyway. `feint clone` uses the same detection to decide which columns get masked by default, see [Masking](#masking). `feint init` also samples real JSON/JSONB values for key names that match the same heuristic, see [JSON path masking](#json-path-masking).

This detection is based on column name patterns only. It does not know what the table is about. A column named `name` on a `users` table and a column named `name` on an `organizations` table are treated the same way right now, which is not always correct. Use an explicit `generator:` (for `up`) or `mask:` (for `clone`) override in `feint.yaml` if a guess is wrong.

## Known limitations

- CHECK constraints are not validated before insert. feint relies on the transaction rolling back cleanly if one fails.
- Composite types (custom `CREATE TYPE ... AS (...)` structs) have no generator yet.
- Types without a native binary decoder (including `tsvector`, geometric types, pgvector, `inet`/`cidr`, and extension types) are read through PostgreSQL's canonical `::text` output in `clone`, `mask`, snapshot, and subset paths, then parsed by the destination type's text input function.
- The column name heuristic does not know what a table represents, only the column name.
- The whole run is still one transaction, that part is unchanged, and still not built around constant memory for an unbounded row count (rows are fully materialized before any write). What changed: bulk loading uses `COPY` instead of chunked, parameterized `INSERT` wherever nothing needs `RETURNING` or `OVERRIDING SYSTEM VALUE` (`clone`, `restore`, and any `up`/generate-strategy table nothing else references), removing the old few-hundred-rows-per-statement ceiling entirely for that path. A table `up` needs `RETURNING` for (because something else references it), and a `clone`/`restore` table with a `GENERATED ALWAYS AS IDENTITY` column, still use the older chunked-`INSERT` path, unchanged.
- There is no way to avoid duplicate data on a second `up` or `clone` run against the same tables. Truncate the target first if you want a clean set.
- `clone` does not create tables on the target. The target schema must already exist and match the source.
- `--root` subsetting only follows actual foreign key relationships. A table your application looks up outside of any foreign key is not discovered and stays empty on the target.
- `json_paths` (see [JSON path masking](#json-path-masking)) only addresses object keys, not array elements, and its `fake` strategy falls back to `redact` for a leaf that's itself an object or array rather than guessing a shape. Post-mask verification also does not check `json_paths` rules, only whole-column strategies.
- `mask` requires a primary key on any table it needs to touch (see [Masking](#masking)).
- `--strict` (see [Fail-closed masking](#fail-closed-masking---strict)) guarantees every column's classification was reviewed at least once, not that the naming heuristic behind that classification is correct. It will not catch PII in a column the heuristic itself misses.
- `migrate` cannot convert arbitrary custom code (Snaplet's `seed.ts` generator functions, Neosync's JavaScript/user-defined transformers). These are reported as needing manual review, not guessed at.
- `feint snapshot` does not support a `strategy: generate` table (see [Hybrid clone](#hybrid-clone-mask--generate-in-one-run)); it rejects the config rather than only capturing part of a hybrid run.
- A snapshot file is feint's own versioned format, meant only for a later `feint restore` by a compatible feint build. It is not a portable interchange format, and a file from a newer feint version than the one running `restore` is rejected rather than misread.
- TLS support covers `sslmode=require`/`prefer` (encrypted, certificate not verified) and `disable` (plain). `verify-ca`/`verify-full` (full certificate chain and hostname verification) are not implemented yet and are rejected with a clear error rather than silently downgraded.
- Cardinality profiling (see [Profile-driven generation](#profile-driven-generation)) only covers single-column foreign keys, and `feint plan`'s row estimate doesn't read a profile.

## Development

Requirements: Rust, Cargo, and Docker (for the test suite, which spins up real Postgres containers).

```
cargo build --workspace
cargo test --workspace
cargo clippy --workspace --all-targets
cargo fmt
```

The test suite includes:

- Unit tests for the value encoding, the dependency graph, the generators, the masking transform, and `COPY` text-format encoding (escaping, NULL, every `PgValue` variant, including the array-braces-pass-through and doubled-backslash-in-bytea cases).
- Integration tests that create real schemas in a throwaway Postgres container and check the results: composite keys, cycles, enums, arrays, JSONB, citext, partitioned tables, and more.
- Integration tests with two containers (source and target) for `clone`: key preservation, sequence resync, each masking strategy, the rules that reject unsafe masking configs, and subsetting (a diamond dependency, a self-referencing root, a cap abort).
- `hybrid_clone`, for `strategy: generate`: synthetic rows padded to the configured `rows:` while correctly referencing real, already-masked parent rows (verified via an actual FK-constrained Postgres commit, not just a row count), a generate-strategy table's real source row proven unread, both hybrid validation rejections (a mask table pointing at a generate table, and mixed strategy inside one FK cycle), and composition with `--root` subsetting.
- Integration tests for `mask`: batching across many rows, a genuinely interrupted-and-resumed run verified against independently-computed expected output (not just spot-checked), the same unsafe-config rejections as `clone`, and the row-count invariant.
- A smoke test that runs the actual compiled binary through `init` and `up`.
- `correctness_demo`, a single narrated run over every nasty-schema fixture in order, printing a clean pass/fail report. Run it yourself with `cargo test --test correctness_demo -- --nocapture`. This is the source of the transcript in the README.
- `cross_mode_identity`, which clones a database with masking and separately masks an independent copy of the same source data in place, then asserts both runs produced byte-identical fake values for every row. This is what backs the claim in [Deterministic identity](#deterministic-identity).
- `policy_apply`, which applies a policy template, runs the resulting config through `mask` against a real database, and checks the masked values: a redact-mapped column actually comes back null, an unmatched column passes through untouched, and applying a second policy doesn't overwrite the first policy's choices.
- `verify_masking`, which confirms the post-mask verification pass stays quiet after a real, correct mask run, then corrupts the masked data directly (a broken hash, a non-redacted value, every row's fake value collapsed to one) and confirms verification catches each one specifically.
- `classify_mode`, which checks the classification report and lockfile diff against a real database: sensitive columns detected, key columns excluded, a new column showing up as drift, and an explicit `mask: none` override on a sensitive-looking column being visible in the report rather than silently disappearing. The smoke test also runs the full `feint classify --write` / `--check` / `mask --strict` cycle through the real compiled binary, including the refuse-then-succeed sequence around a drifted column.
- `snapshot_restore`, which proves the whole point of the split: a snapshot captured from a source container round-trips through a real file on disk, and `restore` never touches the source connection again after `capture` returns (the smoke test goes further and destroys the source container entirely between `snapshot` and `restore`). Also covers a foreign-key cycle surviving the round trip, `strategy: generate` rejected at capture time, `--root` composing with a snapshot, and a schema that drifted between capture and restore being rejected rather than guessed at.
- `copy_volume`, which round-trips 20,000 rows through `clone`, `up` (an unreferenced leaf table), and `restore`, checking a full-column checksum and a specific sampled row rather than just a count, plus a dedicated test that writes a real array column containing tabs, newlines, backslashes, and non-ASCII text through `clone`'s `COPY` path and reads the exact values back from Postgres. That second test is what caught a real, pre-existing bug: `PgValue`'s `FromSql` had no explicit handling for the binary array wire format and was silently corrupting any array column read back when the driver requested binary rather than text, now fixed (see [Supported Postgres features](#supported-postgres-features)).
- `profile_mode`, which captures a deliberately skewed distribution (one parent with 50 children among 19 with exactly 1 each) from a real database and confirms `up --profile` reproduces that exact shape (never a count the source distribution didn't actually have), a captured null rate landing within a statistical tolerance band at n=500, the profile's row count winning as the default for an unconfigured table but losing to an explicit `rows:`, and the same profile-driven run producing an identical total both times it's run.
- `json_path_masking`, which confirms `json_paths` masks only the configured leaf through both `mask` and `clone` against real Postgres JSONB columns (a sibling key and an untouched row both survive unchanged, a row missing the whole nested object doesn't error), a `hash`-masked path resolving to the expected placeholder format, and both `json_paths` config rejections (combined with a whole-column `mask:`, or set on a non-JSON column) firing before any table is read or written. The smoke test separately proves `feint init`'s JSONB key-name sampling against a real container: a nested sensitive-looking key gets flagged with its full path, and a plain key does not.

## Roadmap

Not built yet:

- **Homebrew tap.** A formula template exists at `packaging/homebrew/feint.rb`, but it needs a real release's checksums before it can go live. See `packaging/homebrew/README.md`.
- **aarch64 Linux binaries.** The install script and release workflow currently cover x86_64 Linux, and both Intel and Apple Silicon macOS. arm64 Linux (e.g. AWS Graviton, Raspberry Pi) needs to build from source for now.
- **Table aware sensitive field detection**, so a `name` column is treated differently on a `users` table versus an `organizations` table.
- **Full TLS certificate verification** (`verify-ca`/`verify-full`), for setups that need it rather than just an encrypted connection.
- **Constant-memory streaming.** [Bulk loading](#bulk-loading) removed the per-statement row ceiling, but a run still materializes every row in memory before writing any of it. True streaming (read, mask/generate, and write one row at a time) would remove the memory ceiling too.

## License

MIT. See [LICENSE](LICENSE).
