//! Batched, topologically ordered insertion engine.
//!
//! Runs the whole `feint up` inside a single transaction: any failure
//! (including a CHECK-constraint violation Postgres itself rejects) rolls
//! everything back, so a completed run is by-construction free of FK/PK/
//! unique/NOT NULL/type violations — the `✓ All constraints valid` UX line
//! is just a successful `COMMIT`, not a separate validation pass.

use std::collections::{HashMap, HashSet};

use postgres_types::ToSql;
use rand::Rng;
use tokio_postgres::Transaction;

use crate::config::FeintConfig;
use crate::error::{FeintError, Result};
use crate::generate::{derive_rng, generate_value, SeedKey};
use crate::graph::{FkRef, InsertGroup, InsertPlan};
use crate::introspect::{Column, ForeignKey, Identity, Schema, Table, TableId};
use crate::value::PgValue;

const MAX_BIND_PARAMS: usize = 65_000;
const MAX_BATCH_ROWS: usize = 500;

pub enum ProgressEvent<'a> {
    TableStarted { table: &'a str, planned_rows: u32 },
    TableFinished { table: &'a str, rows: u64 },
}

pub struct RunSummary {
    pub rows_by_table: Vec<(String, u64)>,
    pub total_rows: u64,
}

/// Sampled reference pool keyed by `(table, referenced-column-set)` so
/// composite FKs sample a whole tuple that actually co-occurred in a
/// generated row, and a table referenced through more than one unique
/// constraint keeps a separate pool per constraint.
#[derive(Default)]
pub(crate) struct RefPool {
    pools: HashMap<(TableId, Vec<String>), Vec<Vec<PgValue>>>,
}

impl RefPool {
    /// A unique constraint/index's column order need not match the order
    /// an FK lists its referenced columns in — Postgres matches them as a
    /// set, not left-to-right (fider's `users` has `UNIQUE (tenant_id,
    /// id)` satisfying `REFERENCES users(id, tenant_id)`). Pools are keyed
    /// and stored in a canonical (sorted) column order so registration and
    /// sampling agree regardless of which order each call site's column
    /// list happens to be in; `reorder` then permutes a tuple between the
    /// canonical order and whatever order a given call site wants.
    fn canonical(columns: &[String]) -> Vec<String> {
        let mut sorted = columns.to_vec();
        sorted.sort();
        sorted
    }

    fn reorder(tuple: &[PgValue], from: &[String], to: &[String]) -> Vec<PgValue> {
        to.iter()
            .map(|c| {
                let idx = from.iter().position(|f| f == c).expect("same column set");
                tuple[idx].clone()
            })
            .collect()
    }

    /// `pub(crate)`: also called directly from `clone.rs` to register a
    /// hybrid run's already-known real (masked) primary keys, which need
    /// no `RETURNING` round trip the way GENERATE mode's server-assigned
    /// keys do. `columns`/`tuple` may be in any order; they're stored
    /// under the canonical sort order regardless.
    pub(crate) fn register(&mut self, table: &TableId, columns: &[String], tuple: Vec<PgValue>) {
        if tuple.iter().any(PgValue::is_null) {
            // A NULL participant can't satisfy MATCH SIMPLE FK lookups
            // reliably as a sampled target; skip registering it.
            return;
        }
        let canonical = Self::canonical(columns);
        let tuple = Self::reorder(&tuple, columns, &canonical);
        self.pools
            .entry((table.clone(), canonical))
            .or_default()
            .push(tuple);
    }

    fn sample(
        &self,
        table: &TableId,
        columns: &[String],
        rng: &mut rand_chacha::ChaCha8Rng,
    ) -> Option<Vec<PgValue>> {
        self.sample_pinned(table, columns, &[], rng)
    }

    /// Like `sample`, but `pins` (a list of `(index into columns, required
    /// value)`) restricts the draw to tuples that agree on those
    /// positions. Needed when two of a row's composite FKs share a
    /// discriminator column — fider's `post_votes` has both
    /// `(post_id, tenant_id) -> posts(id, tenant_id)` and `(user_id,
    /// tenant_id) -> users(id, tenant_id)`; sampling each independently
    /// picks two different tenants and the second draw's write clobbers
    /// the first's `tenant_id`, producing a row whose `(post_id,
    /// tenant_id)` pair never actually co-occurred in `posts`. Pinning the
    /// already-decided `tenant_id` when resolving the second FK keeps
    /// every composite FK on the row pointing at the same tenant.
    fn sample_pinned(
        &self,
        table: &TableId,
        columns: &[String],
        pins: &[(usize, PgValue)],
        rng: &mut rand_chacha::ChaCha8Rng,
    ) -> Option<Vec<PgValue>> {
        let canonical = Self::canonical(columns);
        let pool = self.pools.get(&(table.clone(), canonical.clone()))?;
        if pins.is_empty() {
            if pool.is_empty() {
                return None;
            }
            let idx = rng.gen_range(0..pool.len());
            return Some(Self::reorder(&pool[idx], &canonical, columns));
        }
        let canon_pins: Vec<(usize, &PgValue)> = pins
            .iter()
            .map(|(i, v)| {
                let ci = canonical
                    .iter()
                    .position(|c| c == &columns[*i])
                    .expect("same column set");
                (ci, v)
            })
            .collect();
        let matches: Vec<&Vec<PgValue>> = pool
            .iter()
            .filter(|t| canon_pins.iter().all(|(ci, v)| &t[*ci] == *v))
            .collect();
        if matches.is_empty() {
            return None;
        }
        let idx = rng.gen_range(0..matches.len());
        Some(Self::reorder(matches[idx], &canonical, columns))
    }

    /// Every tuple registered for `(table, columns)`, in registration
    /// order and reordered to match `columns`. Used for profile-driven
    /// cardinality generation, which needs to visit each parent row
    /// exactly once (to decide its own number of children) rather than
    /// sampling one at random.
    pub(crate) fn all(&self, table: &TableId, columns: &[String]) -> Vec<Vec<PgValue>> {
        let canonical = Self::canonical(columns);
        self.pools
            .get(&(table.clone(), canonical.clone()))
            .map(|pool| {
                pool.iter()
                    .map(|t| Self::reorder(t, &canonical, columns))
                    .collect()
            })
            .unwrap_or_default()
    }
}

pub async fn run(
    txn: &Transaction<'_>,
    schema: &Schema,
    plan: &InsertPlan,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    mut progress: impl FnMut(ProgressEvent),
) -> Result<RunSummary> {
    txn.batch_execute("SET CONSTRAINTS ALL DEFERRED").await?;

    // Every table at least one foreign key points at, schema-wide. A
    // `Simple` table outside this set can never be sampled from — a
    // `Backfill`/`Deferred` table is always in it by construction (that's
    // what makes it part of a cycle) — so it can skip `RETURNING` and
    // `ref_pool` registration entirely and take the faster `COPY` path
    // instead of chunked `INSERT`. See `copy.rs`.
    let referenced_tables: HashSet<TableId> = schema
        .tables
        .iter()
        .flat_map(|t| t.foreign_keys.iter().map(|fk| fk.ref_table.clone()))
        .collect();

    let mut ref_pool = RefPool::default();
    let mut rows_by_table = Vec::new();
    let mut total_rows = 0u64;

    for group in &plan.groups {
        match group {
            InsertGroup::Simple(table_id) => {
                let table = schema.table(table_id).expect("table exists in schema");
                progress(ProgressEvent::TableStarted {
                    table: &table_id.qualified(),
                    planned_rows: rows_for(config, table_id, profile),
                });
                let n = match cardinality_driving_fk(table, profile) {
                    Some((fk, cardinality)) => {
                        insert_plain_table_with_cardinality(
                            txn,
                            table,
                            fk,
                            cardinality,
                            config,
                            profile,
                            &mut ref_pool,
                            referenced_tables.contains(table_id),
                        )
                        .await?
                    }
                    None => {
                        insert_plain_table(
                            txn,
                            table,
                            rows_for(config, table_id, profile),
                            config,
                            profile,
                            &HashSet::new(),
                            &mut ref_pool,
                            referenced_tables.contains(table_id),
                        )
                        .await?
                    }
                };
                progress(ProgressEvent::TableFinished {
                    table: &table_id.qualified(),
                    rows: n,
                });
                rows_by_table.push((table_id.qualified(), n));
                total_rows += n;
            }
            InsertGroup::Deferred(tables) => {
                let n = insert_deferred_group(
                    txn,
                    schema,
                    tables,
                    config,
                    profile,
                    &mut ref_pool,
                    &mut progress,
                )
                .await?;
                for (t, c) in n {
                    total_rows += c;
                    rows_by_table.push((t, c));
                }
            }
            InsertGroup::Backfill {
                tables,
                null_then_backfill,
                self_referencing,
            } => {
                let n = insert_backfill_group(
                    txn,
                    schema,
                    tables,
                    null_then_backfill,
                    self_referencing,
                    config,
                    profile,
                    &mut ref_pool,
                    &mut progress,
                )
                .await?;
                for (t, c) in n {
                    total_rows += c;
                    rows_by_table.push((t, c));
                }
            }
            InsertGroup::SelfReferencing(table_id) => {
                let table = schema.table(table_id).expect("table exists in schema");
                progress(ProgressEvent::TableStarted {
                    table: &table_id.qualified(),
                    planned_rows: rows_for(config, table_id, profile),
                });
                let n = insert_self_referencing_table(
                    txn,
                    table,
                    rows_for(config, table_id, profile),
                    config,
                    profile,
                    &mut ref_pool,
                    referenced_tables.contains(table_id),
                )
                .await?;
                progress(ProgressEvent::TableFinished {
                    table: &table_id.qualified(),
                    rows: n,
                });
                rows_by_table.push((table_id.qualified(), n));
                total_rows += n;
            }
        }
    }

    Ok(RunSummary {
        rows_by_table,
        total_rows,
    })
}

/// `rows:` from `feint.yaml` wins when a table is explicitly configured.
/// Otherwise, a loaded profile's captured `row_count` (see `profile.rs`)
/// is a better default than the fixed fallback — it's what the real
/// database this profile came from actually had.
pub(crate) fn rows_for(
    config: &FeintConfig,
    table_id: &TableId,
    profile: Option<&crate::profile::ProfileFile>,
) -> u32 {
    if let Some(t) = config.table_config(&table_id.qualified()) {
        return t.rows;
    }
    if let Some(row_count) = profile.and_then(|p| p.table(&table_id.qualified())) {
        if row_count.row_count > 0 {
            return row_count.row_count.min(u32::MAX as u64) as u32;
        }
    }
    crate::config::DEFAULT_ROWS
}

fn supplied_columns(table: &Table) -> Vec<&Column> {
    table
        .columns
        .iter()
        .filter(|c| !c.is_server_assigned())
        .collect()
}

/// Union of every column that participates in some unique constraint
/// (including the primary key) — the only columns any FK could ever
/// target, so it's exactly what needs to come back via `RETURNING` to
/// populate every possible reference pool for this table.
fn returning_columns(table: &Table) -> Vec<String> {
    let mut seen = HashSet::new();
    let mut cols = Vec::new();
    for uc in &table.unique_constraints {
        for c in &uc.columns {
            if seen.insert(c.clone()) {
                cols.push(c.clone());
            }
        }
    }
    cols
}

/// Finds the first foreign key on `table` that a loaded profile has a
/// captured cardinality histogram for. That FK's parent row count drives
/// how many rows of `table` get generated and how they're distributed —
/// see `insert_plain_table_with_cardinality`. Any other FK on the same
/// table still gets a per-row uniform sample from the `RefPool`, same as
/// without a profile at all.
fn cardinality_driving_fk<'a>(
    table: &'a Table,
    profile: Option<&'a crate::profile::ProfileFile>,
) -> Option<(
    &'a crate::introspect::ForeignKey,
    &'a crate::profile::CardinalityProfile,
)> {
    let table_profile = profile?.table(&table.id.qualified())?;
    table
        .foreign_keys
        .iter()
        .find_map(|fk| table_profile.cardinality.get(&fk.name).map(|c| (fk, c)))
}

/// Weighted-random pick of a `children_count` from a cardinality
/// histogram. Falls back to 0 if the histogram is somehow empty or every
/// weight is zero — never panics, never fabricates a count the profile
/// didn't actually observe.
fn sample_cardinality(histogram: &[(u32, u64)], rng: &mut rand_chacha::ChaCha8Rng) -> u32 {
    let total: u64 = histogram.iter().map(|(_, weight)| *weight).sum();
    if total == 0 {
        return 0;
    }
    let mut roll = rng.gen_range(0..total);
    for (count, weight) in histogram {
        if roll < *weight {
            return *count;
        }
        roll -= *weight;
    }
    histogram.last().map(|(count, _)| *count).unwrap_or(0)
}

/// Generate one row's values for `supplied_columns`, in order.
/// `skip_fk_columns` names FK columns to leave NULL (Backfill first pass);
/// pass `&HashSet::new()` for a plain insert. `profile`, if loaded, rolls
/// a deterministic weighted coin for any nullable column with a captured
/// null fraction, instead of `generate_value`'s normal never-null default.
#[allow(clippy::too_many_arguments)]
fn generate_row(
    table: &Table,
    supplied: &[&Column],
    row_identity: &str,
    global_seed: &str,
    overrides: &std::collections::BTreeMap<String, crate::config::ColumnConfig>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &RefPool,
    profile: Option<&crate::profile::ProfileFile>,
) -> Result<Vec<PgValue>> {
    let table_name = table.id.qualified();
    let mut values: HashMap<String, PgValue> = HashMap::new();

    for fk in &table.foreign_keys {
        if fk.columns.iter().any(|c| skip_fk_columns.contains(c)) {
            for c in &fk.columns {
                values.insert(c.clone(), PgValue::Null);
            }
            continue;
        }
        if !fk
            .columns
            .iter()
            .any(|c| supplied.iter().any(|s| &s.name == c))
        {
            continue;
        }
        let mut rng = derive_rng(
            global_seed,
            &SeedKey {
                table: &table_name,
                column: &fk.name,
                row_identity,
            },
        );
        // A column an earlier FK on this same row already wrote (a shared
        // tenant/workspace discriminator, typically) must stay pinned to
        // that value — otherwise this FK's draw silently overwrites it
        // with an unrelated one. See `RefPool::sample_pinned`.
        let pins: Vec<(usize, PgValue)> = fk
            .columns
            .iter()
            .enumerate()
            .filter_map(|(i, c)| values.get(c).map(|v| (i, v.clone())))
            .collect();
        match ref_pool.sample_pinned(&fk.ref_table, &fk.ref_columns, &pins, &mut rng) {
            Some(tuple) => {
                for (col, val) in fk.columns.iter().zip(tuple) {
                    values.insert(col.clone(), val);
                }
            }
            None => {
                let all_nullable = fk
                    .columns
                    .iter()
                    .all(|c| table.column(c).map(|cc| cc.nullable).unwrap_or(false));
                if all_nullable {
                    for c in &fk.columns {
                        values.insert(c.clone(), PgValue::Null);
                    }
                } else if !pins.is_empty()
                    && ref_pool
                        .sample(&fk.ref_table, &fk.ref_columns, &mut rng)
                        .is_some()
                {
                    return Err(FeintError::Config(format!(
                        "table `{}` has multiple foreign keys sharing a column (via `{}`), but no row in `{}` \
                         matches the value another foreign key on this row already fixed (increase its `rows:` \
                         in feint.yaml so every shared value has a matching row in every referenced table)",
                        table.id.qualified(),
                        fk.name,
                        fk.ref_table.qualified()
                    )));
                } else {
                    return Err(FeintError::Config(format!(
                        "table `{}` needs at least one row in `{}` to satisfy foreign key `{}`, but none exist \
                         (increase its `rows:` in feint.yaml, or configure this table after it)",
                        table.id.qualified(),
                        fk.ref_table.qualified(),
                        fk.name
                    )));
                }
            }
        }
    }

    let null_fractions = profile
        .and_then(|p| p.table(&table_name))
        .map(|t| &t.null_fractions);

    for col in supplied {
        if values.contains_key(&col.name) {
            continue;
        }
        let override_generator = overrides
            .get(&col.name)
            .and_then(|c| c.generator.as_deref());
        let mut rng = derive_rng(
            global_seed,
            &SeedKey {
                table: &table_name,
                column: &col.name,
                row_identity,
            },
        );
        let null_fraction = if col.nullable {
            null_fractions
                .and_then(|f| f.get(&col.name))
                .copied()
                .unwrap_or(0.0)
        } else {
            0.0
        };
        // Rolled from the same RNG stream, before generating the value —
        // keeps the whole row deterministic per seed without a second
        // `derive_rng` call, and a 0.0 fraction (the overwhelming common
        // case: no profile, or a column the profile never saw NULL) never
        // touches the RNG differently than before this feature existed.
        let value = if null_fraction > 0.0 && rng.gen::<f64>() < null_fraction {
            PgValue::Null
        } else {
            generate_value(col, override_generator, &mut rng)?
        };
        values.insert(col.name.clone(), value);
    }

    Ok(supplied
        .iter()
        .map(|c| values.remove(&c.name).unwrap_or(PgValue::Null))
        .collect())
}

/// How many times a single row is regenerated before giving up on avoiding
/// a collision with one of the table's own UNIQUE constraints — well above
/// what any real FK-pool-exhaustion case should need, but finite so a
/// genuinely-too-small parent pool fails with a clear error instead of
/// looping forever.
const MAX_UNIQUE_RETRY_ATTEMPTS: u32 = 50;

/// Index sets (into `columns`) for each of `table`'s UNIQUE constraints —
/// including the primary key — skipping any constraint whose columns
/// aren't all in `columns` (e.g. a server-assigned PK, which Postgres's own
/// sequence already keeps unique without feint's help).
fn unique_key_index_sets(table: &Table, columns: &[&Column]) -> Vec<Vec<usize>> {
    table
        .unique_constraints
        .iter()
        .filter_map(|uc| {
            uc.columns
                .iter()
                .map(|c| columns.iter().position(|col| &col.name == c))
                .collect::<Option<Vec<usize>>>()
        })
        .collect()
}

/// Same as [`unique_key_index_sets`], additionally dropping any constraint
/// that touches a column in `skip` — used for a deferred FK cycle's first
/// generation pass, where cyclic columns are still NULL and can't be
/// meaningfully checked for a collision yet (they're resolved in pass 2,
/// same as the primary key there already is).
fn unique_key_index_sets_excluding(
    table: &Table,
    columns: &[&Column],
    skip: &HashSet<String>,
) -> Vec<Vec<usize>> {
    table
        .unique_constraints
        .iter()
        .filter(|uc| !uc.columns.iter().any(|c| skip.contains(c)))
        .filter_map(|uc| {
            uc.columns
                .iter()
                .map(|c| columns.iter().position(|col| &col.name == c))
                .collect::<Option<Vec<usize>>>()
        })
        .collect()
}

/// Describes one colliding UNIQUE key set for `generate_unique_row`'s
/// exhaustion error — distinguishing a genuine foreign key (where the
/// fix is almost always "give the referenced table more rows") from a
/// column whose own declared type or a CHECK constraint caps how many
/// distinct values it can ever hold (Metabase's `UNIQUE (is_active
/// boolean)`, capped at 2 non-null values; Rallly's singleton
/// `instance_settings`, capped at 1 row by its own `CHECK (id = 1)`),
/// where "increase the referenced table's rows" is nonsensical advice
/// since there's no referenced table at all.
fn describe_unique_collision(table: &Table, columns: &[&Column], key: &[usize]) -> String {
    let col_names: Vec<&str> = key.iter().map(|&i| columns[i].name.as_str()).collect();
    let is_fk_column = |name: &str| {
        table
            .foreign_keys
            .iter()
            .any(|fk| fk.columns.iter().any(|c| c == name))
    };
    if !col_names.is_empty() && col_names.iter().all(|c| is_fk_column(c)) {
        format!(
            "`{}` (a foreign key) — the referenced table likely doesn't have enough distinct \
             rows to fill it uniquely (increase its `rows:` in feint.yaml)",
            col_names.join(", ")
        )
    } else {
        format!(
            "`{}` — its own declared type or a CHECK constraint caps how many distinct values \
             it can ever hold (e.g. a `boolean` column tops out at 2 non-null values; a \
             singleton-table CHECK caps the whole table at 1 row), so no `rows:` increase can \
             satisfy it — lower this table's own `rows:` instead, or add an explicit \
             `generator:` override for the column",
            col_names.join(", ")
        )
    }
}

/// Generate one row, retrying with a different derived seed if it collides
/// with an already-generated row of the same batch on any of `table`'s
/// UNIQUE constraints. Plain per-row-independent `RefPool` sampling has no
/// way to know about sibling rows in the same batch, so a composite or
/// single-column UNIQUE foreign key — Miniflux's `integrations.user_id` (a
/// 1:1 PK-as-FK), Listmonk's `roles` table's `UNIQUE (parent_id, list_id)`
/// — can otherwise collide at random and crash the whole batch on a
/// duplicate-key error. NULLs are never considered a collision, matching
/// Postgres's own default (non-`NULLS NOT DISTINCT`) unique semantics.
#[allow(clippy::too_many_arguments)]
fn generate_unique_row(
    table: &Table,
    columns: &[&Column],
    row_index: u64,
    global_seed: &str,
    overrides: &std::collections::BTreeMap<String, crate::config::ColumnConfig>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &RefPool,
    profile: Option<&crate::profile::ProfileFile>,
    key_sets: &[Vec<usize>],
    seen: &mut [Vec<Vec<PgValue>>],
) -> Result<Vec<PgValue>> {
    // Which key sets collided on the *last* attempt — kept around so a
    // final failure can name the actual constraint(s) responsible instead
    // of a generic message, since this function's UNIQUE constraints
    // aren't always an FK (a plain `UNIQUE (some_boolean)` or a
    // CHECK-capped singleton table hits this same retry loop).
    let mut last_collisions: Vec<bool> = vec![false; key_sets.len()];
    for attempt in 0..=MAX_UNIQUE_RETRY_ATTEMPTS {
        let row_identity = if attempt == 0 {
            row_index.to_string()
        } else {
            format!("{row_index}#retry{attempt}")
        };
        let row = generate_row(
            table,
            columns,
            &row_identity,
            global_seed,
            overrides,
            skip_fk_columns,
            ref_pool,
            profile,
        )?;

        let tuples: Vec<Option<Vec<PgValue>>> = key_sets
            .iter()
            .map(|key| {
                let tuple: Vec<PgValue> = key.iter().map(|&i| row[i].clone()).collect();
                if tuple.iter().any(PgValue::is_null) {
                    None
                } else {
                    Some(tuple)
                }
            })
            .collect();
        let per_key_collides: Vec<bool> = tuples
            .iter()
            .zip(seen.iter())
            .map(|(tuple, seen_rows)| matches!(tuple, Some(t) if seen_rows.contains(t)))
            .collect();
        if !per_key_collides.iter().any(|&c| c) {
            for (tuple, seen_rows) in tuples.into_iter().zip(seen.iter_mut()) {
                if let Some(t) = tuple {
                    seen_rows.push(t);
                }
            }
            return Ok(row);
        }
        last_collisions = per_key_collides;
    }
    let colliding_sets: Vec<&Vec<usize>> = key_sets
        .iter()
        .zip(last_collisions.iter())
        .filter_map(|(key, &collided)| collided.then_some(key))
        .collect();
    let detail = colliding_sets
        .iter()
        .map(|key| describe_unique_collision(table, columns, key))
        .collect::<Vec<_>>()
        .join("; ");
    Err(FeintError::Config(format!(
        "table `{}` couldn't generate row {} without violating one of its own UNIQUE \
         constraints after {MAX_UNIQUE_RETRY_ATTEMPTS} attempts — {detail}",
        table.id.qualified(),
        row_index + 1,
    )))
}

/// Schema-qualified so a type outside the connection's `search_path`
/// still resolves — a bare `::"type_name"` cast only works when the
/// type's own schema happens to already be on `search_path` (true for
/// every built-in type, which lives in `pg_catalog`, but not guaranteed
/// for a real schema's own `CREATE TYPE`/`CREATE DOMAIN`, e.g. Twenty's
/// tables live in `core` and declare enums like `core.file_status_enum`
/// there too — an unqualified `::file_status_enum` cast fails with "type
/// does not exist" unless `core` happens to already be on `search_path`).
pub(crate) fn sql_cast_type(column: &Column) -> String {
    match &column.type_kind {
        crate::introspect::TypeKind::Array {
            elem_type,
            elem_type_schema,
            ..
        } => format!("\"{elem_type_schema}\".\"{elem_type}\"[]"),
        _ => format!("\"{}\".\"{}\"", column.type_schema, column.type_name),
    }
}

pub(crate) async fn execute_batched_insert(
    txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    rows: &[Vec<PgValue>],
    returning: &[String],
    overriding_system_value: bool,
) -> Result<Vec<Vec<PgValue>>> {
    if rows.is_empty() {
        return Ok(Vec::new());
    }

    if columns.is_empty() {
        // PostgreSQL has no multi-row `DEFAULT VALUES` form. This case is
        // rare (a table made entirely of serial/identity/stored-generated
        // columns), so issue one statement per planned row. Unlike the old
        // early return, this both creates the real rows and captures any
        // server-assigned keys needed by downstream foreign keys.
        let sql = build_default_insert_sql(table, returning, overriding_system_value);
        let mut returned = Vec::with_capacity(rows.len());
        for _ in rows {
            let result_rows = txn.query(&sql, &[]).await?;
            for row in result_rows {
                let mut tuple = Vec::with_capacity(returning.len());
                for i in 0..returning.len() {
                    tuple.push(row.get::<_, PgValue>(i));
                }
                returned.push(tuple);
            }
        }
        return Ok(returned);
    }

    let batch_rows = (MAX_BIND_PARAMS / columns.len()).clamp(1, MAX_BATCH_ROWS);
    let mut returned = Vec::with_capacity(rows.len());

    for chunk in rows.chunks(batch_rows) {
        let sql = build_insert_sql(
            table,
            columns,
            chunk.len(),
            returning,
            overriding_system_value,
        );
        let params: Vec<&(dyn ToSql + Sync)> = chunk
            .iter()
            .flat_map(|row| row.iter().map(|v| v as &(dyn ToSql + Sync)))
            .collect();
        let result_rows = txn.query(&sql, &params).await?;
        for row in result_rows {
            let mut tuple = Vec::with_capacity(returning.len());
            for i in 0..returning.len() {
                tuple.push(row.get::<_, PgValue>(i));
            }
            returned.push(tuple);
        }
    }

    Ok(returned)
}

fn build_default_insert_sql(
    table: &Table,
    returning: &[String],
    overriding_system_value: bool,
) -> String {
    let returning_clause = if returning.is_empty() {
        String::new()
    } else {
        format!(
            " RETURNING {}",
            returning
                .iter()
                .map(|c| format!("\"{c}\""))
                .collect::<Vec<_>>()
                .join(", ")
        )
    };
    let overriding_clause = if overriding_system_value {
        " OVERRIDING SYSTEM VALUE"
    } else {
        ""
    };
    format!(
        "INSERT INTO \"{}\".\"{}\"{overriding_clause} DEFAULT VALUES{returning_clause}",
        table.id.schema, table.id.name
    )
}

pub(crate) fn build_insert_sql(
    table: &Table,
    columns: &[&Column],
    row_count: usize,
    returning: &[String],
    overriding_system_value: bool,
) -> String {
    let col_list = columns
        .iter()
        .map(|c| format!("\"{}\"", c.name))
        .collect::<Vec<_>>()
        .join(", ");

    let mut param_idx = 1;
    let mut value_groups = Vec::with_capacity(row_count);
    for _ in 0..row_count {
        let placeholders = columns
            .iter()
            .map(|c| {
                let p = format!("${}::{}", param_idx, sql_cast_type(c));
                param_idx += 1;
                p
            })
            .collect::<Vec<_>>()
            .join(", ");
        value_groups.push(format!("({placeholders})"));
    }

    let returning_clause = if returning.is_empty() {
        String::new()
    } else {
        format!(
            " RETURNING {}",
            returning
                .iter()
                .map(|c| format!("\"{c}\""))
                .collect::<Vec<_>>()
                .join(", ")
        )
    };

    let overriding_clause = if overriding_system_value {
        " OVERRIDING SYSTEM VALUE"
    } else {
        ""
    };

    format!(
        "INSERT INTO \"{}\".\"{}\" ({col_list}){overriding_clause} VALUES {}{returning_clause}",
        table.id.schema,
        table.id.name,
        value_groups.join(", ")
    )
}

fn register_returned(
    ref_pool: &mut RefPool,
    table: &Table,
    returning: &[String],
    rows: &[Vec<PgValue>],
) {
    for uc in &table.unique_constraints {
        let indices: Option<Vec<usize>> = uc
            .columns
            .iter()
            .map(|c| returning.iter().position(|r| r == c))
            .collect();
        let Some(indices) = indices else { continue };
        for row in rows {
            let tuple: Vec<PgValue> = indices.iter().map(|&i| row[i].clone()).collect();
            ref_pool.register(&table.id, &uc.columns, tuple);
        }
    }
}

/// `is_referenced` should be true if any table's foreign key points at
/// this one, anywhere in the schema. When it's false, nothing will ever
/// sample this table's rows from the `ref_pool`, so there's no need to
/// pay for `RETURNING` and registration at all — this table takes the
/// `COPY` path instead of chunked `INSERT`, which is the whole point:
/// this is exactly the case a high-volume padding/leaf table (events,
/// logs, line items) hits in practice.
#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_plain_table(
    txn: &Transaction<'_>,
    table: &Table,
    planned_rows: u32,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    skip_fk_columns: &HashSet<String>,
    ref_pool: &mut RefPool,
    is_referenced: bool,
) -> Result<u64> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);

    let columns = supplied_columns(table);
    let key_sets = unique_key_index_sets(table, &columns);
    let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];
    let mut rows = Vec::with_capacity(planned_rows as usize);
    for i in 0..planned_rows {
        rows.push(generate_unique_row(
            table,
            &columns,
            i as u64,
            &config.seed,
            overrides,
            skip_fk_columns,
            ref_pool,
            profile,
            &key_sets,
            &mut seen,
        )?);
    }

    if is_referenced {
        let returning = returning_columns(table);
        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);
    } else {
        crate::copy::copy_rows(txn, table, &columns, &rows).await?;
    }
    Ok(rows.len() as u64)
}

/// A `Simple`-group table whose first profiled foreign key already has
/// its parent rows generated (guaranteed by topological order). Instead
/// of a flat `planned_rows` count, visits each parent row once, draws a
/// `children_count` from the captured histogram (deterministically, keyed
/// on the parent's own index), and generates that many child rows
/// pointing at it — the actual mechanism behind [`crate::profile`]'s
/// whole reason to exist: a long tail instead of a uniform count.
#[allow(clippy::too_many_arguments)]
async fn insert_plain_table_with_cardinality(
    txn: &Transaction<'_>,
    table: &Table,
    driving_fk: &crate::introspect::ForeignKey,
    cardinality: &crate::profile::CardinalityProfile,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    ref_pool: &mut RefPool,
    is_referenced: bool,
) -> Result<u64> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);
    let columns = supplied_columns(table);
    let table_name = table.id.qualified();

    // Snapshot the parent pool up front: `ref_pool` is read-only for the
    // rest of this function (every FK, including `driving_fk` itself,
    // still goes through `generate_row`'s normal sampling — its pick for
    // `driving_fk` just gets overwritten below), so this shared borrow
    // and the later mutable one for registration don't overlap.
    let parents: Vec<Vec<PgValue>> = ref_pool.all(&driving_fk.ref_table, &driving_fk.ref_columns);

    let fk_positions: Vec<usize> = driving_fk
        .columns
        .iter()
        .filter_map(|c| columns.iter().position(|col| &col.name == c))
        .collect();

    let mut rows = Vec::new();
    let mut row_index: u64 = 0;
    for (parent_idx, parent_tuple) in parents.iter().enumerate() {
        let mut count_rng = derive_rng(
            &config.seed,
            &SeedKey {
                table: &table_name,
                column: &driving_fk.name,
                row_identity: &parent_idx.to_string(),
            },
        );
        let children = sample_cardinality(&cardinality.histogram, &mut count_rng);

        for _ in 0..children {
            let row_identity = row_index.to_string();
            row_index += 1;
            let mut row = generate_row(
                table,
                &columns,
                &row_identity,
                &config.seed,
                overrides,
                &HashSet::new(),
                ref_pool,
                profile,
            )?;
            for (&pos, val) in fk_positions.iter().zip(parent_tuple.iter()) {
                row[pos] = val.clone();
            }
            rows.push(row);
        }
    }

    if is_referenced {
        let returning = returning_columns(table);
        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);
    } else {
        crate::copy::copy_rows(txn, table, &columns, &rows).await?;
    }
    Ok(rows.len() as u64)
}

/// The Postgres sequence backing `column`, if any — resolves both a plain
/// `nextval()` serial default and a `GENERATED ALWAYS/BY DEFAULT AS
/// IDENTITY` column. `pub(crate)`: shared with `clone::resync_sequences`,
/// which needs the identical lookup.
///
/// `pg_get_serial_sequence`'s `table_name` argument is parsed with
/// ordinary SQL identifier rules, not treated as a literal relation name:
/// an unquoted mixed-case part (e.g. Documenso's `"User"` table) silently
/// case-folds to `user` and the lookup misses. Quoting each part here
/// preserves the case exactly like it would in a normal qualified
/// reference.
pub(crate) async fn serial_sequence_name(
    txn: &Transaction<'_>,
    table: &Table,
    column_name: &str,
) -> Result<Option<String>> {
    let qualified = format!("\"{}\".\"{}\"", table.id.schema, table.id.name);
    let seq_row = txn
        .query_one(
            "SELECT pg_get_serial_sequence($1, $2)",
            &[&qualified, &column_name],
        )
        .await?;
    Ok(seq_row.get(0))
}

/// Reserves `n` consecutive values from `seq_name` via `nextval()`, in
/// order, as the exact PK values a self-referencing table's rows will use
/// — see `insert_self_referencing_table`.
async fn prefetch_sequence_values(
    txn: &Transaction<'_>,
    seq_name: &str,
    n: i64,
    column: &Column,
) -> Result<Vec<PgValue>> {
    if n == 0 {
        return Ok(Vec::new());
    }
    // `nextval`'s argument is `regclass`; tokio-postgres's `ToSql` only
    // binds text-family types to a placeholder, so — same as
    // `clone::resync_sequences` — inline it as a literal. `seq_name` comes
    // straight from `pg_get_serial_sequence`, never user input.
    let literal = seq_name.replace('\'', "''");
    let rows = txn
        .query(
            &format!("SELECT nextval('{literal}') FROM generate_series(1, $1::bigint)"),
            &[&n],
        )
        .await?;
    Ok(rows
        .into_iter()
        .map(|row| {
            let v: i64 = row.get(0);
            match column.type_name.as_str() {
                "int2" => PgValue::Int2(v as i16),
                "int8" => PgValue::Int8(v),
                _ => PgValue::Int4(v as i32),
            }
        })
        .collect())
}

/// The local (referencing) columns of every self-referencing FK on `table`
/// — i.e. every FK whose `ref_table` is `table` itself.
fn self_referencing_fks(table: &Table) -> Vec<&ForeignKey> {
    table
        .foreign_keys
        .iter()
        .filter(|fk| fk.ref_table == table.id)
        .collect()
}

/// Reserves `nextval()` values for every column a self-referencing FK on
/// `table` points at (almost always just its own PK), and extends
/// `supplied_columns(table)` with those columns so they get written
/// explicitly instead of left to `DEFAULT`. Shared by
/// `insert_self_referencing_table` (a table whose *only* cyclic dependency
/// is on itself) and `insert_backfill_group` (a table whose self-loop
/// coexists with genuine cross-table cyclic edges, e.g. Zammad's `users`)
/// — both need the identical up-front reservation, just as part of a
/// different surrounding insertion strategy.
async fn prefetch_self_referencing<'a>(
    txn: &Transaction<'_>,
    table: &'a Table,
    self_fks: &[&ForeignKey],
    planned_rows: u32,
) -> Result<(Vec<&'a Column>, bool, HashMap<String, Vec<PgValue>>)> {
    let mut prefetch_col_names: Vec<String> = Vec::new();
    for fk in self_fks {
        for c in &fk.ref_columns {
            if !prefetch_col_names.contains(c) {
                prefetch_col_names.push(c.clone());
            }
        }
    }

    let mut prefetched: HashMap<String, Vec<PgValue>> = HashMap::new();
    let mut needs_overriding = false;
    for col_name in &prefetch_col_names {
        let col = table
            .column(col_name)
            .expect("ref column exists on its own table");
        if matches!(col.identity, Identity::Always) {
            needs_overriding = true;
        }
        let seq_name = serial_sequence_name(txn, table, col_name)
            .await?
            .ok_or_else(|| {
                FeintError::Config(format!(
                "table `{}` has a self-referencing foreign key on `{}`, but no backing Postgres \
                 sequence could be found for it — this shouldn't be possible for a plain serial \
                 default or identity column.",
                table.id.qualified(),
                col_name
            ))
            })?;
        let values = prefetch_sequence_values(txn, &seq_name, planned_rows as i64, col).await?;
        prefetched.insert(col_name.clone(), values);
    }

    let mut columns = supplied_columns(table);
    for col in &table.columns {
        if prefetched.contains_key(&col.name) {
            columns.push(col);
        }
    }
    columns.sort_by_key(|c| c.position);

    Ok((columns, needs_overriding, prefetched))
}

/// Fills in row `i`'s prefetched ref-column value(s) and resolves every
/// self-referencing FK on it by sampling among the ids already decided for
/// rows `0..=i` (including the row's own) — always valid, since Postgres
/// only checks a non-deferrable FK once the whole triggering `INSERT`
/// statement's rows already exist, and any earlier row is already
/// committed within this transaction by the time a later chunk's `INSERT`
/// runs. `row` must have been generated with every self-fk's local column
/// in the caller's skip set (left NULL), and `columns` must be the
/// `prefetch_self_referencing`-extended list so the prefetched ref
/// column(s) have a slot to write into.
fn apply_self_referencing_values(
    row: &mut [PgValue],
    columns: &[&Column],
    self_fks: &[&ForeignKey],
    prefetched: &HashMap<String, Vec<PgValue>>,
    table_name: &str,
    global_seed: &str,
    i: u32,
) {
    for (col_name, values) in prefetched {
        let pos = columns
            .iter()
            .position(|c| &c.name == col_name)
            .expect("prefetched column was added to the supplied list above");
        row[pos] = values[i as usize].clone();
    }

    for fk in self_fks {
        let mut rng = derive_rng(
            global_seed,
            &SeedKey {
                table: table_name,
                column: &fk.name,
                row_identity: &i.to_string(),
            },
        );
        let pick = rng.gen_range(0..=i as usize);
        for (local_col, ref_col) in fk.columns.iter().zip(&fk.ref_columns) {
            let pos = columns
                .iter()
                .position(|c| &c.name == local_col)
                .expect("self-fk column was added to the supplied list above");
            row[pos] = prefetched[ref_col][pick].clone();
        }
    }
}

/// A table whose only cyclic dependency is a self-referencing FK on a
/// sequence-backed server-assigned column (almost always its own PK) —
/// `InsertGroup::SelfReferencing`. feint never otherwise knows a row's
/// own serial/identity value until *after* insert (via `RETURNING`), by
/// which point any self-reference on that same row would already have
/// had to be written — so a self-reference can never get a real value
/// through the normal generate-then-insert flow, regardless of
/// nullability or deferrability. Real hand-written seed scripts solve
/// this the same way: reserve primary keys from the sequence up front and
/// write them explicitly. This does that — pre-fetches `planned_rows`
/// values via `nextval()`, writes them into each row's own PK column
/// explicitly (bypassing `DEFAULT`, using `OVERRIDING SYSTEM VALUE` for a
/// `GENERATED ALWAYS AS IDENTITY` column), and resolves every
/// self-referencing column the same way `apply_self_referencing_values`
/// does for a self-referencing table inside a larger `Backfill` group.
pub(crate) async fn insert_self_referencing_table(
    txn: &Transaction<'_>,
    table: &Table,
    planned_rows: u32,
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    ref_pool: &mut RefPool,
    is_referenced: bool,
) -> Result<u64> {
    let empty = std::collections::BTreeMap::new();
    let overrides = config
        .table_config(&table.id.qualified())
        .map(|t| &t.columns)
        .unwrap_or(&empty);

    let self_fks = self_referencing_fks(table);
    let self_fk_columns: HashSet<String> = self_fks
        .iter()
        .flat_map(|fk| fk.columns.iter().cloned())
        .collect();

    let (columns, needs_overriding, prefetched) =
        prefetch_self_referencing(txn, table, &self_fks, planned_rows).await?;

    let key_sets = unique_key_index_sets_excluding(table, &columns, &self_fk_columns);
    let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];

    let table_name = table.id.qualified();
    let mut rows: Vec<Vec<PgValue>> = Vec::with_capacity(planned_rows as usize);
    for i in 0..planned_rows {
        let mut row = generate_unique_row(
            table,
            &columns,
            i as u64,
            &config.seed,
            overrides,
            &self_fk_columns,
            ref_pool,
            profile,
            &key_sets,
            &mut seen,
        )?;

        apply_self_referencing_values(
            &mut row,
            &columns,
            &self_fks,
            &prefetched,
            &table_name,
            &config.seed,
            i,
        );

        rows.push(row);
    }

    if is_referenced {
        let returning = returning_columns(table);
        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, needs_overriding)
                .await?;
        register_returned(ref_pool, table, &returning, &returned);
    } else {
        crate::copy::bulk_insert_no_returning(txn, table, &columns, &rows, needs_overriding)
            .await?;
    }
    Ok(rows.len() as u64)
}

#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_backfill_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    null_then_backfill: &[FkRef],
    self_referencing: &[FkRef],
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    ref_pool: &mut RefPool,
    progress: &mut impl FnMut(ProgressEvent),
) -> Result<Vec<(String, u64)>> {
    let mut skip_by_table: HashMap<TableId, HashSet<String>> = HashMap::new();
    for r in null_then_backfill {
        skip_by_table
            .entry(r.table.clone())
            .or_default()
            .extend(r.fk.columns.iter().cloned());
    }
    let mut self_refs_by_table: HashMap<TableId, Vec<&ForeignKey>> = HashMap::new();
    for r in self_referencing {
        self_refs_by_table
            .entry(r.table.clone())
            .or_default()
            .push(&r.fk);
    }

    let mut results = Vec::new();
    // Track the primary key values captured per table+row so the backfill
    // UPDATE can target each row precisely.
    let mut captured_pks: HashMap<TableId, Vec<Vec<PgValue>>> = HashMap::new();
    // Full `RETURNING` rows (every unique-constraint column, by
    // construction of `returning_columns`) + the column list they're
    // indexed against — lets the backfill pass below check a freshly
    // backfilled FK value against sibling unique-constraint columns whose
    // values were already fixed in the initial insert (e.g. Listmonk's
    // `roles` table: `list_id` is fixed up front, `parent_id` is
    // backfilled after, and `UNIQUE (parent_id, list_id)` needs both).
    let mut captured_returning: HashMap<TableId, (Vec<String>, Vec<Vec<PgValue>>)> = HashMap::new();

    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id, profile);
        progress(ProgressEvent::TableStarted {
            table: &table_id.qualified(),
            planned_rows,
        });

        let empty = std::collections::BTreeMap::new();
        let overrides = config
            .table_config(&table_id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);
        let self_refs = self_refs_by_table
            .get(table_id)
            .cloned()
            .unwrap_or_default();
        let self_ref_columns: HashSet<String> = self_refs
            .iter()
            .flat_map(|fk| fk.columns.iter().cloned())
            .collect();
        let (columns, needs_overriding, prefetched) = if self_refs.is_empty() {
            (supplied_columns(table), false, HashMap::new())
        } else {
            prefetch_self_referencing(txn, table, &self_refs, planned_rows).await?
        };

        let mut skip = skip_by_table.get(table_id).cloned().unwrap_or_default();
        skip.extend(self_ref_columns.iter().cloned());
        let key_sets = unique_key_index_sets_excluding(table, &columns, &self_ref_columns);
        let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];

        let table_name = table_id.qualified();
        let mut rows = Vec::with_capacity(planned_rows as usize);
        for i in 0..planned_rows {
            let mut row = generate_unique_row(
                table,
                &columns,
                i as u64,
                &config.seed,
                overrides,
                &skip,
                ref_pool,
                profile,
                &key_sets,
                &mut seen,
            )?;
            if !self_refs.is_empty() {
                apply_self_referencing_values(
                    &mut row,
                    &columns,
                    &self_refs,
                    &prefetched,
                    &table_name,
                    &config.seed,
                    i,
                );
            }
            rows.push(row);
        }

        let pk_cols = table
            .primary_key
            .clone()
            .ok_or_else(|| FeintError::Config(format!(
                "table `{}` is part of a foreign-key cycle resolved by null+backfill, but has no primary key to target the backfill UPDATE",
                table_id.qualified()
            )))?;

        let mut returning = returning_columns(table);
        for c in &pk_cols {
            if !returning.contains(c) {
                returning.push(c.clone());
            }
        }

        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, needs_overriding)
                .await?;
        register_returned(ref_pool, table, &returning, &returned);

        let pk_indices: Vec<usize> = pk_cols
            .iter()
            .map(|c| returning.iter().position(|r| r == c).unwrap())
            .collect();
        let pks: Vec<Vec<PgValue>> = returned
            .iter()
            .map(|row| pk_indices.iter().map(|&i| row[i].clone()).collect())
            .collect();
        captured_pks.insert(table_id.clone(), pks);
        captured_returning.insert(table_id.clone(), (returning, returned));

        progress(ProgressEvent::TableFinished {
            table: &table_id.qualified(),
            rows: rows.len() as u64,
        });
        results.push((table_id.qualified(), rows.len() as u64));
    }

    backfill_null_edges(
        txn,
        schema,
        null_then_backfill,
        config,
        ref_pool,
        &captured_pks,
        &captured_returning,
    )
    .await?;

    Ok(results)
}

/// UPDATEs each `r: FkRef`'s nulled column(s) back to a real sampled
/// value, now that every table in the group has been written and
/// registered in `ref_pool`. Shared by `insert_backfill_group` (a plain
/// null-then-backfill cyclic group) and `insert_deferred_group` (a
/// `Deferred` group whose non-deferrable edges needed the same
/// null-then-backfill trick to break a hard sub-cycle among themselves —
/// see `deferred_group_write_order`); both callers capture `captured_pks`/
/// `captured_returning` identically while writing each table, so this is
/// the one piece that's genuinely shared rather than coincidentally
/// similar.
async fn backfill_null_edges(
    txn: &Transaction<'_>,
    schema: &Schema,
    null_then_backfill: &[FkRef],
    config: &FeintConfig,
    ref_pool: &RefPool,
    captured_pks: &HashMap<TableId, Vec<Vec<PgValue>>>,
    captured_returning: &HashMap<TableId, (Vec<String>, Vec<Vec<PgValue>>)>,
) -> Result<()> {
    for r in null_then_backfill {
        let table = schema.table(&r.table).expect("table exists");
        let pk_cols = table.primary_key.clone().expect("checked above");
        let pks = captured_pks.get(&r.table).cloned().unwrap_or_default();
        let table_name = r.table.qualified();

        // Unique constraints this backfilled FK actually participates in —
        // its sibling columns' values are already fixed from the initial
        // insert (captured in `returning`/`returned` above), so a
        // collision on the *combination* only becomes checkable once this
        // FK's real value is chosen here.
        let (returning, returned) = captured_returning
            .get(&r.table)
            .cloned()
            .unwrap_or_default();
        let relevant_constraints: Vec<Vec<usize>> = table
            .unique_constraints
            .iter()
            .filter(|uc| uc.columns.iter().any(|c| r.fk.columns.contains(c)))
            .filter_map(|uc| {
                uc.columns
                    .iter()
                    .map(|c| returning.iter().position(|ret| ret == c))
                    .collect::<Option<Vec<usize>>>()
            })
            .collect();
        let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); relevant_constraints.len()];

        for (row_idx, pk) in pks.iter().enumerate() {
            let mut tuple = None;
            let mut pool_was_empty = false;
            for attempt in 0..=MAX_UNIQUE_RETRY_ATTEMPTS {
                let row_identity = if attempt == 0 {
                    row_idx.to_string()
                } else {
                    format!("{row_idx}#retry{attempt}")
                };
                let mut rng = derive_rng(
                    &config.seed,
                    &SeedKey {
                        table: &table_name,
                        column: &r.fk.name,
                        row_identity: &row_identity,
                    },
                );
                let Some(candidate) = ref_pool.sample(&r.fk.ref_table, &r.fk.ref_columns, &mut rng)
                else {
                    pool_was_empty = true;
                    break; // pool empty (e.g. 0 rows configured upstream) — leave NULL
                };

                let candidate_tuples: Vec<Vec<PgValue>> = relevant_constraints
                    .iter()
                    .map(|key| {
                        key.iter()
                            .map(|&i| {
                                if let Some(pos) = r.fk.columns.iter().position(|c| {
                                    returning.get(i).map(|ret| ret == c).unwrap_or(false)
                                }) {
                                    candidate[pos].clone()
                                } else {
                                    returned[row_idx][i].clone()
                                }
                            })
                            .collect()
                    })
                    .collect();
                let collides = candidate_tuples
                    .iter()
                    .zip(seen.iter())
                    .any(|(t, s)| !t.iter().any(PgValue::is_null) && s.contains(t));
                if !collides {
                    for (t, s) in candidate_tuples.into_iter().zip(seen.iter_mut()) {
                        if !t.iter().any(PgValue::is_null) {
                            s.push(t);
                        }
                    }
                    tuple = Some(candidate);
                    break;
                }
            }
            let Some(tuple) = tuple else {
                if pool_was_empty {
                    continue; // pool was empty — leave NULL, as before
                }
                return Err(FeintError::Config(format!(
                    "table `{}` couldn't backfill foreign key `{}` for row {} without violating \
                     one of its own UNIQUE constraints after {MAX_UNIQUE_RETRY_ATTEMPTS} attempts \
                     — the referenced table(s) likely don't have enough distinct rows to fill it \
                     uniquely (increase their `rows:` in feint.yaml)",
                    r.table.qualified(),
                    r.fk.name,
                    row_idx + 1,
                )));
            };

            let set_clause =
                r.fk.columns
                    .iter()
                    .enumerate()
                    .map(|(i, c)| {
                        format!(
                            "\"{c}\" = ${}::{}",
                            i + 1,
                            sql_cast_type(table.column(c).unwrap())
                        )
                    })
                    .collect::<Vec<_>>()
                    .join(", ");
            let where_offset = r.fk.columns.len();
            let where_clause = pk_cols
                .iter()
                .enumerate()
                .map(|(i, c)| {
                    format!(
                        "\"{c}\" = ${}::{}",
                        where_offset + i + 1,
                        sql_cast_type(table.column(c).unwrap())
                    )
                })
                .collect::<Vec<_>>()
                .join(" AND ");

            let sql = format!(
                "UPDATE \"{}\".\"{}\" SET {set_clause} WHERE {where_clause}",
                r.table.schema, r.table.name
            );
            let mut params: Vec<&(dyn ToSql + Sync)> =
                tuple.iter().map(|v| v as &(dyn ToSql + Sync)).collect();
            params.extend(pk.iter().map(|v| v as &(dyn ToSql + Sync)));
            txn.execute(&sql, &params).await?;
        }
    }
    Ok(())
}

/// A valid write order for a `Deferred` group's actual `INSERT`s, plus any
/// edges that couldn't be ordered directly and instead need the same
/// null-then-backfill trick `InsertGroup::Backfill` uses. See
/// `deferred_group_write_order`.
struct DeferredWriteOrder {
    tables: Vec<TableId>,
    null_then_backfill: Vec<FkRef>,
}

/// Topologically sorts `tables` using only `edges` (parent = `fk.ref_table`
/// must come before child = `r.table`) via Kahn's algorithm. `None` if
/// `edges` don't form a DAG over `tables`.
fn toposort_by_edges(tables: &[TableId], edges: &[FkRef]) -> Option<Vec<TableId>> {
    let mut children: HashMap<TableId, Vec<TableId>> =
        tables.iter().map(|t| (t.clone(), Vec::new())).collect();
    let mut in_degree: HashMap<TableId, usize> = tables.iter().map(|t| (t.clone(), 0)).collect();
    for r in edges {
        children
            .get_mut(&r.fk.ref_table)
            .expect("ref table is in this group")
            .push(r.table.clone());
        *in_degree.get_mut(&r.table).expect("table is in this group") += 1;
    }

    let mut queue: std::collections::VecDeque<TableId> = tables
        .iter()
        .filter(|t| in_degree[*t] == 0)
        .cloned()
        .collect();
    let mut order = Vec::with_capacity(tables.len());
    while let Some(t) = queue.pop_front() {
        for child in &children[&t] {
            let deg = in_degree.get_mut(child).expect("table is in this group");
            *deg -= 1;
            if *deg == 0 {
                queue.push_back(child.clone());
            }
        }
        order.push(t);
    }

    (order.len() == tables.len()).then_some(order)
}

/// Orders `tables` so every internal FK edge that is *not* `DEFERRABLE`
/// has its referenced table written before its referencing one —
/// `SET CONSTRAINTS ALL DEFERRED` only defers checking for constraints
/// actually declared `DEFERRABLE`; a group lands in `InsertGroup::Deferred`
/// as soon as *any* internal edge is deferrable (see `plan_insertion`), so
/// it can still contain edges Postgres checks immediately on `INSERT`
/// regardless of that session-level setting. Twenty's real shape is
/// exactly this: a 5-table cycle (`application`, `publicDomain`,
/// `applicationRegistration`, `file`, `workspace`) where most edges are
/// `DEFERRABLE INITIALLY DEFERRED` but `publicDomain.applicationId ->
/// application(id)` is not — writing `publicDomain` before `application`
/// had a real row on disk failed immediately with a foreign-key
/// violation, not at commit. Self-loop edges (a table referencing itself)
/// impose no ordering constraint relative to any *other* table, so
/// they're skipped here the same way `plan_insertion` skips them for
/// `Deferred` classification generally.
///
/// If the non-deferrable edges alone don't form a DAG, this falls back to
/// the same cycle-breaking trick `plan_insertion` already uses for a
/// `Backfill` group: pull out whichever of those edges have a nullable
/// local column (write them as `NULL` first, resolve them later via
/// `backfill_null_edges`) and retry ordering with only the remaining
/// (`NOT NULL`) non-deferrable edges. Only genuinely fails — a hard
/// sub-cycle no nullable escape can break — when that second attempt
/// still isn't a DAG.
fn deferred_group_write_order(schema: &Schema, tables: &[TableId]) -> Result<DeferredWriteOrder> {
    let table_set: HashSet<&TableId> = tables.iter().collect();
    let mut non_deferrable: Vec<FkRef> = Vec::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        for fk in &table.foreign_keys {
            if fk.deferrable || &fk.ref_table == table_id || !table_set.contains(&fk.ref_table) {
                continue;
            }
            non_deferrable.push(FkRef {
                table: table_id.clone(),
                fk: fk.clone(),
            });
        }
    }

    if let Some(order) = toposort_by_edges(tables, &non_deferrable) {
        return Ok(DeferredWriteOrder {
            tables: order,
            null_then_backfill: Vec::new(),
        });
    }

    let is_edge_nullable = |r: &FkRef| {
        let table = schema.table(&r.table).expect("table exists");
        r.fk.columns
            .iter()
            .all(|col| table.column(col).map(|c| c.nullable).unwrap_or(false))
    };
    let (breakable, hard): (Vec<FkRef>, Vec<FkRef>) =
        non_deferrable.into_iter().partition(is_edge_nullable);

    let Some(order) = toposort_by_edges(tables, &hard) else {
        let names = tables
            .iter()
            .map(|t| t.qualified())
            .collect::<Vec<_>>()
            .join(", ");
        let constraint_names = hard
            .iter()
            .map(|r| format!("{}.{}", r.table.qualified(), r.fk.name))
            .collect::<Vec<_>>()
            .join(", ");
        return Err(FeintError::Config(format!(
            "tables [{names}] form a foreign-key cycle with no valid write order, even after \
             treating every nullable non-deferrable edge as null-then-backfill — the remaining \
             NOT NULL edges ({constraint_names}) still form a cycle on their own. Make one of \
             them DEFERRABLE or nullable, or break the cycle with a different edge."
        )));
    };
    Ok(DeferredWriteOrder {
        tables: order,
        null_then_backfill: breakable,
    })
}

#[allow(clippy::too_many_arguments)]
pub(crate) async fn insert_deferred_group(
    txn: &Transaction<'_>,
    schema: &Schema,
    tables: &[TableId],
    config: &FeintConfig,
    profile: Option<&crate::profile::ProfileFile>,
    ref_pool: &mut RefPool,
    progress: &mut impl FnMut(ProgressEvent),
) -> Result<Vec<(String, u64)>> {
    // Deferred constraints let us insert rows before the row(s) they
    // reference exist in the DB (Postgres only checks at COMMIT), but
    // feint still has to know the *value* to write at insert time. That's
    // only possible when every table's referenced key in the cycle is
    // client-generated (e.g. a UUID default) rather than server-assigned
    // (serial/identity) — those aren't known until the DB assigns them.
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        for fk in &table.foreign_keys {
            if !tables.contains(&fk.ref_table) {
                continue;
            }
            let ref_table = schema.table(&fk.ref_table).expect("table exists");
            for c in &fk.ref_columns {
                if let Some(col) = ref_table.column(c) {
                    if col.is_server_assigned() {
                        return Err(FeintError::Config(format!(
                            "table `{}` has a deferrable foreign-key cycle through `{}`, but `{}`.`{}` is a \
                             server-assigned (serial/identity) column feint can't pre-generate a value for. \
                             Make the referencing column nullable instead, or use a client-generated key \
                             (e.g. a UUID default) for `{}`.",
                            table_id.qualified(),
                            fk.ref_table.qualified(),
                            fk.ref_table.qualified(),
                            c,
                            fk.ref_table.qualified()
                        )));
                    }
                }
            }
        }
    }

    // Pass 1: generate every non-cyclic column for every row of every
    // table in the group, and register unique-constraint tuples as soon
    // as they're fully known so cyclic FKs (resolved in pass 2) can
    // sample them regardless of which table in the group comes "first".
    let mut cyclic_columns: HashMap<TableId, HashSet<String>> = HashMap::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let mut cols = HashSet::new();
        for fk in &table.foreign_keys {
            if tables.contains(&fk.ref_table) {
                cols.extend(fk.columns.iter().cloned());
            }
        }
        cyclic_columns.insert(table_id.clone(), cols);
    }

    let mut partial_rows: HashMap<TableId, Vec<Vec<PgValue>>> = HashMap::new();
    for table_id in tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id, profile);
        let empty = std::collections::BTreeMap::new();
        let overrides = config
            .table_config(&table_id.qualified())
            .map(|t| &t.columns)
            .unwrap_or(&empty);
        let columns = supplied_columns(table);
        let skip = cyclic_columns.get(table_id).cloned().unwrap_or_default();
        // A non-cyclic FK on a table in this group (e.g. Baserow's
        // `automation_automationnode.service_id`, UNIQUE and DEFERRABLE
        // but pointing outside the cycle) still goes through plain
        // `RefPool` sampling here, which samples with replacement — so it
        // needs the same collision-retry protection `insert_plain_table`
        // gives ordinary tables, or a UNIQUE FK can silently collide.
        let key_sets = unique_key_index_sets_excluding(table, &columns, &skip);
        let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];

        let mut rows = Vec::with_capacity(planned_rows as usize);
        for i in 0..planned_rows {
            rows.push(generate_unique_row(
                table,
                &columns,
                i as u64,
                &config.seed,
                overrides,
                &skip,
                ref_pool,
                profile,
                &key_sets,
                &mut seen,
            )?);
        }

        // Register unique-constraint tuples that don't touch a cyclic
        // column — almost always the primary key.
        for uc in &table.unique_constraints {
            if uc.columns.iter().any(|c| skip.contains(c)) {
                continue;
            }
            let indices: Vec<usize> = uc
                .columns
                .iter()
                .map(|c| columns.iter().position(|s| &s.name == c).unwrap())
                .collect();
            for row in &rows {
                let tuple: Vec<PgValue> = indices.iter().map(|&i| row[i].clone()).collect();
                ref_pool.register(table_id, &uc.columns, tuple);
            }
        }

        partial_rows.insert(table_id.clone(), rows);
    }

    // Pass 2: resolve the cyclic columns now that every table's
    // non-cyclic (usually PK) values are registered, then actually write
    // each table — in an order that respects any non-deferrable internal
    // edge (see `deferred_group_write_order`); a group only needs *one*
    // deferrable edge to land here, so it can still contain edges
    // Postgres checks immediately regardless of `SET CONSTRAINTS ALL
    // DEFERRED`.
    let write_order = deferred_group_write_order(schema, tables)?;
    let mut backfill_columns_by_table: HashMap<TableId, HashSet<String>> = HashMap::new();
    for r in &write_order.null_then_backfill {
        backfill_columns_by_table
            .entry(r.table.clone())
            .or_default()
            .extend(r.fk.columns.iter().cloned());
    }

    let mut results = Vec::new();
    let mut captured_pks: HashMap<TableId, Vec<Vec<PgValue>>> = HashMap::new();
    let mut captured_returning: HashMap<TableId, (Vec<String>, Vec<Vec<PgValue>>)> = HashMap::new();
    for table_id in &write_order.tables {
        let table = schema.table(table_id).expect("table exists");
        let planned_rows = rows_for(config, table_id, profile);
        progress(ProgressEvent::TableStarted {
            table: &table_id.qualified(),
            planned_rows,
        });

        let columns = supplied_columns(table);
        let mut rows = partial_rows.remove(table_id).unwrap_or_default();
        let skip = cyclic_columns.get(table_id).cloned().unwrap_or_default();
        let backfill_cols = backfill_columns_by_table.get(table_id);
        let table_name = table_id.qualified();

        for fk in &table.foreign_keys {
            if !fk.columns.iter().any(|c| skip.contains(c)) {
                continue;
            }
            if fk
                .columns
                .iter()
                .any(|c| backfill_cols.is_some_and(|s| s.contains(c)))
            {
                // Left NULL by pass 1 (it's already in `skip`); resolved
                // after every table in the group has been written, by
                // `backfill_null_edges` below — this is the edge
                // `deferred_group_write_order` couldn't fit into a pure
                // write order and broke by nulling instead.
                continue;
            }
            // Same collision-avoidance `insert_backfill_group` already
            // does for its own cyclic-edge resolution: plain `RefPool`
            // sampling has no way to know about sibling rows, so a UNIQUE
            // cyclic FK (e.g. Baserow's `builder_builder.login_page_id`,
            // 1:1 with `builder_page`) can otherwise collide at random.
            let key_sets: Vec<Vec<usize>> = table
                .unique_constraints
                .iter()
                .filter(|uc| uc.columns.iter().any(|c| fk.columns.contains(c)))
                .filter_map(|uc| {
                    uc.columns
                        .iter()
                        .map(|c| columns.iter().position(|col| &col.name == c))
                        .collect::<Option<Vec<usize>>>()
                })
                .collect();
            let mut seen: Vec<Vec<Vec<PgValue>>> = vec![Vec::new(); key_sets.len()];

            for (row_idx, row) in rows.iter_mut().enumerate() {
                let mut chosen = None;
                let mut pool_was_empty = false;
                for attempt in 0..=MAX_UNIQUE_RETRY_ATTEMPTS {
                    let row_identity = if attempt == 0 {
                        row_idx.to_string()
                    } else {
                        format!("{row_idx}#retry{attempt}")
                    };
                    let mut rng = derive_rng(
                        &config.seed,
                        &SeedKey {
                            table: &table_name,
                            column: &fk.name,
                            row_identity: &row_identity,
                        },
                    );
                    let Some(candidate) = ref_pool.sample(&fk.ref_table, &fk.ref_columns, &mut rng)
                    else {
                        pool_was_empty = true;
                        break; // pool empty (e.g. 0 rows configured upstream) — leave NULL
                    };
                    let candidate_tuples: Vec<Vec<PgValue>> = key_sets
                        .iter()
                        .map(|key| {
                            key.iter()
                                .map(|&i| {
                                    match fk.columns.iter().position(|c| {
                                        columns.get(i).map(|col| &col.name == c).unwrap_or(false)
                                    }) {
                                        Some(pos) => candidate[pos].clone(),
                                        None => row[i].clone(),
                                    }
                                })
                                .collect()
                        })
                        .collect();
                    let collides = candidate_tuples
                        .iter()
                        .zip(seen.iter())
                        .any(|(t, s)| !t.iter().any(PgValue::is_null) && s.contains(t));
                    if !collides {
                        for (t, s) in candidate_tuples.into_iter().zip(seen.iter_mut()) {
                            if !t.iter().any(PgValue::is_null) {
                                s.push(t);
                            }
                        }
                        chosen = Some(candidate);
                        break;
                    }
                }
                match chosen {
                    Some(tuple) => {
                        for (col_name, val) in fk.columns.iter().zip(tuple) {
                            if let Some(pos) = columns.iter().position(|c| &c.name == col_name) {
                                row[pos] = val;
                            }
                        }
                    }
                    None if pool_was_empty => {
                        // Every other table in the cycle is registered in
                        // `ref_pool` by the time pass 2 runs (pass 1 built
                        // every table's rows before this loop started), so
                        // an empty pool here means the *other* side's own
                        // matching unique-constraint tuple never got
                        // registered — almost always because that side's
                        // relevant columns were themselves skipped as
                        // cyclic (Matrix Synapse's `worker_read_write_locks`
                        // <-> `worker_read_write_locks_mode`, which resolve
                        // through the *same* `lock_name`/`lock_key`
                        // columns on both sides, so neither ever anchors
                        // the other). Leaving NULL here is only safe if
                        // the column tolerates it — otherwise this becomes
                        // a raw NOT NULL violation at the INSERT below,
                        // with none of this cycle's context in the error.
                        let not_null: Vec<&str> = fk
                            .columns
                            .iter()
                            .filter(|c| table.column(c).map(|col| !col.nullable).unwrap_or(false))
                            .map(String::as_str)
                            .collect();
                        if !not_null.is_empty() {
                            return Err(FeintError::Config(format!(
                                "table `{}` has a deferrable foreign-key cycle through `{}`, but neither \
                                 side ever has a matching row to resolve `{}` (NOT NULL: {}) against — the \
                                 cycle has no independently-generatable anchor. Make {} nullable, or break \
                                 the cycle with a different, independently-resolvable edge.",
                                table_id.qualified(),
                                fk.ref_table.qualified(),
                                fk.name,
                                not_null.join(", "),
                                if not_null.len() == 1 { "it" } else { "them" }
                            )));
                        }
                    } // leave NULL, as before
                    None => {
                        return Err(FeintError::Config(format!(
                            "table `{}` couldn't resolve cyclic foreign key `{}` for row {} without \
                             violating one of its own UNIQUE constraints after {MAX_UNIQUE_RETRY_ATTEMPTS} \
                             attempts — the referenced table(s) likely don't have enough distinct rows to \
                             fill it uniquely (increase their `rows:` in feint.yaml)",
                            table_id.qualified(),
                            fk.name,
                            row_idx + 1,
                        )));
                    }
                }
            }
        }

        let pk_cols = table.primary_key.clone();
        if pk_cols.is_none() && backfill_cols.is_some() {
            return Err(FeintError::Config(format!(
                "table `{}` is part of a foreign-key cycle resolved by null+backfill (within a \
                 deferred group), but has no primary key to target the backfill UPDATE",
                table_id.qualified()
            )));
        }

        let mut returning = returning_columns(table);
        if let Some(pk_cols) = &pk_cols {
            for c in pk_cols {
                if !returning.contains(c) {
                    returning.push(c.clone());
                }
            }
        }

        let returned =
            execute_batched_insert(txn, table, &columns, &rows, &returning, false).await?;
        register_returned(ref_pool, table, &returning, &returned);

        if let Some(pk_cols) = &pk_cols {
            let pk_indices: Vec<usize> = pk_cols
                .iter()
                .map(|c| returning.iter().position(|r| r == c).unwrap())
                .collect();
            let pks: Vec<Vec<PgValue>> = returned
                .iter()
                .map(|row| pk_indices.iter().map(|&i| row[i].clone()).collect())
                .collect();
            captured_pks.insert(table_id.clone(), pks);
        }
        captured_returning.insert(table_id.clone(), (returning, returned));

        progress(ProgressEvent::TableFinished {
            table: &table_id.qualified(),
            rows: rows.len() as u64,
        });
        results.push((table_id.qualified(), rows.len() as u64));
    }

    backfill_null_edges(
        txn,
        schema,
        &write_order.null_then_backfill,
        config,
        ref_pool,
        &captured_pks,
        &captured_returning,
    )
    .await?;

    Ok(results)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Identity, TypeKind};

    fn column(type_name: &str, type_schema: &str, type_kind: TypeKind) -> Column {
        Column {
            name: "col".to_string(),
            position: 1,
            type_name: type_name.to_string(),
            type_schema: type_schema.to_string(),
            type_kind,
            max_length: None,
            vector_dimensions: None,
            numeric_precision: None,
            numeric_scale: None,
            check_min: None,
            check_max: None,
            check_allowed_values: None,
            check_null_escape: false,
            check_like_prefix: None,
            nullable: true,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    #[test]
    fn scalar_cast_is_schema_qualified() {
        let col = column("int4", "pg_catalog", TypeKind::Scalar);
        assert_eq!(sql_cast_type(&col), "\"pg_catalog\".\"int4\"");
    }

    #[test]
    fn enum_cast_uses_the_type_s_own_schema_not_public() {
        // Twenty's real shape: a table in schema `core` with an enum type
        // also declared in `core`, not `public` — a bare `::file_status_enum`
        // cast only resolves if `core` happens to be on `search_path`.
        let col = column(
            "file_status_enum",
            "core",
            TypeKind::Enum(vec!["UPLOADED".to_string(), "PENDING".to_string()]),
        );
        assert_eq!(sql_cast_type(&col), "\"core\".\"file_status_enum\"");
    }

    #[test]
    fn array_cast_qualifies_the_element_type_s_schema() {
        let col = column(
            "_file_status_enum",
            "core",
            TypeKind::Array {
                elem_type: "file_status_enum".to_string(),
                elem_type_schema: "core".to_string(),
                elem_kind: Box::new(TypeKind::Enum(vec!["UPLOADED".to_string()])),
            },
        );
        assert_eq!(sql_cast_type(&col), "\"core\".\"file_status_enum\"[]");
    }
}
