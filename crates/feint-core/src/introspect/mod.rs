//! Schema introspection: reads `pg_catalog` and builds an in-memory
//! [`Schema`] model. Runs as a handful of straightforward per-table
//! queries rather than one giant join — introspected schemas are at most a
//! few hundred tables, so simplicity beats a marginal round-trip win here.

use std::collections::HashMap;

use tokio_postgres::Client;

use crate::error::Result;

/// Name of the bookkeeping table `mask`'s checkpoint mechanism creates
/// (see `sanitize.rs`). Reserved and excluded from every introspected
/// [`Schema`] — it is feint's own internal state, never user schema, and
/// must never be treated as a table to generate into, clone, mask, or
/// track a classification lockfile entry for.
pub(crate) const MASK_CHECKPOINT_TABLE: &str = "_feint_mask_checkpoint";

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct TableId {
    pub schema: String,
    pub name: String,
}

impl TableId {
    pub fn qualified(&self) -> String {
        format!("{}.{}", self.schema, self.name)
    }
}

impl std::fmt::Display for TableId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.qualified())
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Identity {
    None,
    Always,
    ByDefault,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TypeKind {
    Scalar,
    Enum(Vec<String>),
    Domain {
        base_type: String,
    },
    Array {
        elem_type: String,
        elem_kind: Box<TypeKind>,
    },
    Composite,
    Other,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Column {
    pub name: String,
    pub position: i16,
    pub type_name: String,
    pub type_kind: TypeKind,
    /// `character_maximum_length` for `varchar(N)`/`char(N)`/`bpchar(N)` —
    /// `None` for unbounded `text`/`citext` and every other type. Generators
    /// use this to truncate rather than overflow the column.
    pub max_length: Option<i32>,
    /// Declared dimension for pgvector's `vector(N)` type. `None` for an
    /// unconstrained vector and every non-vector type.
    pub vector_dimensions: Option<i32>,
    /// Declared `numeric(precision, scale)`. Both `None` for a bare
    /// `numeric` with no modifier (unbounded) and every non-numeric type.
    /// Generators use this to stay within the column's total-digit budget
    /// instead of overflowing it.
    pub numeric_precision: Option<i32>,
    pub numeric_scale: Option<i32>,
    /// Lower/upper bound narrowed from a simple single-column CHECK
    /// constraint on an `int2`/`int4`/`int8` column (e.g. `CHECK (col >=
    /// 0)`, the standard shape Django's `PositiveSmallIntegerField` and
    /// friends emit). `None` when no such constraint exists, or when the
    /// table has one but it's not this narrow, safely-parseable shape.
    pub check_min: Option<i64>,
    pub check_max: Option<i64>,
    /// The fixed set of legal values narrowed from a simple single-column
    /// CHECK constraint of the shape `CHECK (col = ANY (ARRAY['a', 'b']))`
    /// (any cast variant Postgres's `pg_get_constraintdef` emits — plain,
    /// `::text`, `::character varying`, schema-qualified enum casts) or the
    /// singleton `CHECK (col = 'a')` — a very common allowlist idiom
    /// (Rails/TypeORM `validates :col, inclusion: {in: [...]}`-style
    /// columns, or a table narrowing a shared enum type down to one value).
    /// `None` when no such constraint exists, or when the table has one but
    /// it's not this narrow, safely-parseable shape (a cross-column OR, a
    /// function call, etc). Multiple matching constraints on the same
    /// column are intersected, same as `check_min`/`check_max`.
    pub check_allowed_values: Option<Vec<String>>,
    pub nullable: bool,
    pub identity: Identity,
    /// `GENERATED ALWAYS AS (...) STORED` — never written by feint.
    pub is_stored_generated: bool,
    /// Column has a server-side default (sequence, `nextval(...)`, literal,
    /// expression, or `GENERATED ... AS IDENTITY`). Combined with
    /// `identity`/`is_stored_generated` to decide whether feint must supply
    /// a value.
    pub has_default: bool,
    pub is_serial_default: bool,
}

impl Column {
    /// True if feint must never include this column in an INSERT column
    /// list — Postgres either forbids it (`GENERATED ALWAYS AS IDENTITY`,
    /// stored-generated) or the value should come from the DB default to
    /// preserve reproducibility (serial/sequence defaults captured via
    /// `RETURNING`).
    pub fn is_server_assigned(&self) -> bool {
        self.is_stored_generated
            || matches!(self.identity, Identity::Always)
            || self.is_serial_default
    }

    /// True for a server-assigned column that's actually backed by a real
    /// Postgres sequence (`nextval()`-default or `GENERATED ALWAYS AS
    /// IDENTITY`), as opposed to `is_stored_generated`, which is computed
    /// by an expression and has no sequence to reserve values from. A
    /// self-referencing FK on this kind of column can be resolved by
    /// pre-reserving its values via `nextval()` before generating any
    /// row; a stored-generated one can't.
    pub fn is_sequence_backed(&self) -> bool {
        self.is_serial_default || matches!(self.identity, Identity::Always)
    }
}

/// Build the SELECT expression used to read a column into `PgValue`.
///
/// PostgreSQL returns binary values by default. `PgValue` has real binary
/// decoders for the common scalar types below, enums, and arrays composed of
/// those types. For everything else, ask PostgreSQL for its canonical text
/// representation instead of interpreting an opaque binary payload as UTF-8.
/// That text can be fed back into a column of the original type.
pub(crate) fn select_column_expression(column: &Column) -> String {
    let quoted = format!("\"{}\"", column.name);
    if has_binary_decoder(&column.type_name, &column.type_kind) {
        quoted
    } else {
        format!("{quoted}::text AS {quoted}")
    }
}

fn has_binary_decoder(type_name: &str, type_kind: &TypeKind) -> bool {
    match type_kind {
        TypeKind::Enum(_) => true,
        TypeKind::Array {
            elem_type,
            elem_kind,
        } => has_binary_decoder(elem_type, elem_kind),
        TypeKind::Scalar => matches!(
            type_name,
            "bool"
                | "int2"
                | "int4"
                | "int8"
                | "numeric"
                | "float4"
                | "float8"
                | "text"
                | "varchar"
                | "bpchar"
                | "name"
                | "bytea"
                | "uuid"
                | "timestamp"
                | "timestamptz"
                | "date"
                | "json"
                | "jsonb"
        ),
        TypeKind::Domain { .. } | TypeKind::Composite | TypeKind::Other => false,
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct ForeignKey {
    pub name: String,
    pub columns: Vec<String>,
    pub ref_table: TableId,
    pub ref_columns: Vec<String>,
    pub deferrable: bool,
    pub initially_deferred: bool,
}

#[derive(Debug, Clone, PartialEq)]
pub struct UniqueConstraint {
    pub name: String,
    pub is_primary: bool,
    pub columns: Vec<String>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct CheckConstraint {
    pub name: String,
    pub definition: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Table {
    pub id: TableId,
    pub columns: Vec<Column>,
    pub primary_key: Option<Vec<String>>,
    pub foreign_keys: Vec<ForeignKey>,
    pub unique_constraints: Vec<UniqueConstraint>,
    pub check_constraints: Vec<CheckConstraint>,
}

impl Table {
    pub fn column(&self, name: &str) -> Option<&Column> {
        self.columns.iter().find(|c| c.name == name)
    }
}

#[derive(Debug, Clone, Default, PartialEq)]
pub struct Schema {
    pub tables: Vec<Table>,
}

impl Schema {
    pub fn table(&self, id: &TableId) -> Option<&Table> {
        self.tables.iter().find(|t| &t.id == id)
    }
}

struct RawTable {
    oid: u32,
    id: TableId,
}

/// Introspect exactly the given schemas (e.g. `["public"]`). Scoping is
/// explicit rather than "every non-system schema" so that (a) feint never
/// silently slurps up an unrelated extension's or another app's schema in
/// the same database, and (b) tests can isolate themselves into their own
/// schema and introspect only that one, even running in parallel against a
/// shared container.
pub async fn introspect(client: &Client, schemas: &[String]) -> Result<Schema> {
    let raw_tables = list_tables(client, schemas).await?;
    let mut enum_cache: HashMap<u32, Vec<String>> = HashMap::new();

    let mut tables = Vec::with_capacity(raw_tables.len());
    for rt in &raw_tables {
        let mut columns = list_columns(client, rt.oid, &mut enum_cache).await?;
        let unique_constraints = list_unique_constraints(client, rt.oid).await?;
        let primary_key = unique_constraints
            .iter()
            .find(|u| u.is_primary)
            .map(|u| u.columns.clone());
        let foreign_keys = list_foreign_keys(client, rt.oid).await?;
        let check_constraints = list_check_constraints(client, rt.oid).await?;

        for col in &mut columns {
            if matches!(col.type_name.as_str(), "int2" | "int4" | "int8") {
                let (min, max) = simple_integer_bounds(&check_constraints, &col.name);
                col.check_min = min;
                col.check_max = max;
            }
            col.check_allowed_values = simple_allowed_values(&check_constraints, &col.name);
        }

        tables.push(Table {
            id: rt.id.clone(),
            columns,
            primary_key,
            foreign_keys,
            unique_constraints,
            check_constraints,
        });
    }

    Ok(Schema { tables })
}

/// Ordinary and partitioned tables, excluding partition children
/// (`relispartition`) so a partitioned table is represented exactly once by
/// its top-level parent — inserting into a child directly would bypass
/// Postgres's partition routing, and counting children as separate tables
/// would double up FK relationships. Also excludes [`MASK_CHECKPOINT_TABLE`]
/// regardless of which schema it landed in — `ensure_checkpoint_table`
/// creates it unqualified, so it can end up anywhere on the connection's
/// `search_path`, not necessarily whichever schema `--schema` named.
async fn list_tables(client: &Client, schemas: &[String]) -> Result<Vec<RawTable>> {
    let rows = client
        .query(
            "SELECT c.oid, n.nspname, c.relname \
             FROM pg_class c \
             JOIN pg_namespace n ON n.oid = c.relnamespace \
             WHERE c.relkind IN ('r', 'p') \
               AND NOT c.relispartition \
               AND n.nspname = ANY($1) \
               AND c.relname <> $2 \
             ORDER BY n.nspname, c.relname",
            &[&schemas, &MASK_CHECKPOINT_TABLE],
        )
        .await?;

    Ok(rows
        .into_iter()
        .map(|row| RawTable {
            oid: row.get::<_, u32>(0),
            id: TableId {
                schema: row.get(1),
                name: row.get(2),
            },
        })
        .collect())
}

async fn list_columns(
    client: &Client,
    table_oid: u32,
    enum_cache: &mut HashMap<u32, Vec<String>>,
) -> Result<Vec<Column>> {
    let rows = client
        .query(
            "SELECT a.attnum, a.attname, a.attnotnull, a.attidentity, a.attgenerated, \
                    t.oid, t.typname, t.typtype, t.typcategory, t.typbasetype, \
                    bt.typname AS base_typname, \
                    et.oid AS elem_type_oid, et.typname AS elem_typname, \
                    et.typtype AS elem_typtype, et.typbasetype AS elem_base_type_oid, \
                    ebt.typname AS elem_base_typname, \
                    (SELECT pg_get_expr(d.adbin, d.adrelid) FROM pg_attrdef d \
                       WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum) AS default_expr, \
                    a.atttypmod \
             FROM pg_attribute a \
             JOIN pg_type t ON t.oid = a.atttypid \
             LEFT JOIN pg_type bt ON bt.oid = t.typbasetype \
             LEFT JOIN pg_type et ON et.oid = t.typelem AND t.typcategory = 'A' \
             LEFT JOIN pg_type ebt ON ebt.oid = et.typbasetype \
             WHERE a.attrelid = $1 AND a.attnum > 0 AND NOT a.attisdropped \
             ORDER BY a.attnum",
            &[&table_oid],
        )
        .await?;

    let mut columns = Vec::with_capacity(rows.len());
    for row in rows {
        let position: i16 = row.get(0);
        let name: String = row.get(1);
        let not_null: bool = row.get(2);
        let identity_char: i8 = row.get(3);
        let generated_char: i8 = row.get(4);
        let type_oid: u32 = row.get(5);
        let type_name: String = row.get(6);
        let type_type: i8 = row.get(7);
        let type_category: i8 = row.get(8);
        let base_type_oid: u32 = row.get(9);
        let base_typname: Option<String> = row.get(10);
        let elem_type_oid: Option<u32> = row.get(11);
        let elem_typname: Option<String> = row.get(12);
        let elem_typtype: Option<i8> = row.get(13);
        let elem_base_type_oid: Option<u32> = row.get(14);
        let elem_base_typname: Option<String> = row.get(15);
        let default_expr: Option<String> = row.get(16);
        let typmod: i32 = row.get(17);
        // `atttypmod` for varchar(N)/bpchar(N) is N + 4 (VARHDRSZ); -1
        // means unbounded (plain `text`/`citext`, or `varchar` with no
        // length given).
        // `atttypmod` on an array column describes the *element* type's
        // modifier (Postgres applies the same encoding as the scalar case),
        // so `text[]`... er, `varchar(N)[]`/`bpchar(N)[]` needs the element
        // type name checked here too — not just the outer (`_varchar`-style)
        // array type name, which never matches "varchar"/"bpchar" directly.
        let is_length_bounded_type = |name: &str| matches!(name, "varchar" | "bpchar");
        let is_array = type_category as u8 as char == 'A';
        let max_length = if typmod > 0
            && (is_length_bounded_type(&type_name)
                || (is_array
                    && elem_typname
                        .as_deref()
                        .map(is_length_bounded_type)
                        .unwrap_or(false)))
        {
            Some(typmod - 4)
        } else {
            None
        };
        let vector_dimensions = if typmod > 0 && type_name == "vector" {
            Some(typmod)
        } else {
            None
        };
        // `numeric(precision, scale)` packs both into `atttypmod` as
        // `((precision << 16) | scale) + VARHDRSZ` (VARHDRSZ == 4); -1
        // means a bare `numeric` with no modifier (unbounded).
        let (numeric_precision, numeric_scale) = if typmod > 0 && type_name == "numeric" {
            let packed = typmod - 4;
            (Some(packed >> 16), Some(packed & 0xffff))
        } else {
            (None, None)
        };

        let identity = match identity_char as u8 as char {
            'a' => Identity::Always,
            'd' => Identity::ByDefault,
            _ => Identity::None,
        };
        let is_stored_generated = generated_char as u8 as char == 's';
        let is_serial_default = default_expr
            .as_deref()
            .map(|e| e.starts_with("nextval("))
            .unwrap_or(false);

        let type_kind = match type_type as u8 as char {
            'e' => {
                if let Some(variants) = enum_cache.get(&type_oid) {
                    TypeKind::Enum(variants.clone())
                } else {
                    let variants = list_enum_variants(client, type_oid).await?;
                    enum_cache.insert(type_oid, variants.clone());
                    TypeKind::Enum(variants)
                }
            }
            'd' => TypeKind::Domain {
                base_type: base_typname.unwrap_or_else(|| format!("oid:{base_type_oid}")),
            },
            'c' => TypeKind::Composite,
            _ if type_category as u8 as char == 'A' => {
                let elem_type = elem_typname.unwrap_or_else(|| "unknown".to_string());
                let elem_kind = match elem_typtype.map(|v| v as u8 as char) {
                    Some('e') => {
                        let oid = elem_type_oid.unwrap_or_default();
                        let variants = if let Some(variants) = enum_cache.get(&oid) {
                            variants.clone()
                        } else {
                            let variants = list_enum_variants(client, oid).await?;
                            enum_cache.insert(oid, variants.clone());
                            variants
                        };
                        TypeKind::Enum(variants)
                    }
                    Some('d') => TypeKind::Domain {
                        base_type: elem_base_typname.unwrap_or_else(|| {
                            format!("oid:{}", elem_base_type_oid.unwrap_or_default())
                        }),
                    },
                    Some('c') => TypeKind::Composite,
                    Some('b') => TypeKind::Scalar,
                    _ => TypeKind::Other,
                };
                TypeKind::Array {
                    elem_type,
                    elem_kind: Box::new(elem_kind),
                }
            }
            'b' => TypeKind::Scalar,
            _ => TypeKind::Other,
        };

        columns.push(Column {
            name,
            position,
            type_name,
            type_kind,
            max_length,
            vector_dimensions,
            numeric_precision,
            numeric_scale,
            // Filled in by `introspect()` once this table's check
            // constraints are known — `list_columns` runs before that.
            check_min: None,
            check_max: None,
            check_allowed_values: None,
            nullable: !not_null,
            identity,
            is_stored_generated,
            has_default: default_expr.is_some() || identity != Identity::None,
            is_serial_default,
        });
    }

    Ok(columns)
}

async fn list_enum_variants(client: &Client, type_oid: u32) -> Result<Vec<String>> {
    let rows = client
        .query(
            "SELECT enumlabel FROM pg_enum WHERE enumtypid = $1 ORDER BY enumsortorder",
            &[&type_oid],
        )
        .await?;
    Ok(rows.into_iter().map(|r| r.get(0)).collect())
}

async fn list_unique_constraints(client: &Client, table_oid: u32) -> Result<Vec<UniqueConstraint>> {
    let rows = client
        .query(
            "SELECT con.conname, con.contype, \
                    array(SELECT attname FROM pg_attribute \
                           WHERE attrelid = con.conrelid AND attnum = ANY(con.conkey) \
                           ORDER BY array_position(con.conkey, attnum)) AS columns \
             FROM pg_constraint con \
             WHERE con.conrelid = $1 AND con.contype IN ('u', 'p')",
            &[&table_oid],
        )
        .await?;

    let mut constraints: Vec<UniqueConstraint> = rows
        .into_iter()
        .map(|row| {
            let contype: i8 = row.get(1);
            UniqueConstraint {
                name: row.get(0),
                is_primary: contype as u8 as char == 'p',
                columns: row.get(2),
            }
        })
        .collect();

    // A bare `CREATE UNIQUE INDEX` (no `ADD CONSTRAINT`) enforces
    // uniqueness exactly like a real unique constraint but leaves no
    // `pg_constraint` row — extremely common in Rails/TypeORM/Django-style
    // migrations (e.g. Listmonk's `idx_roles`, Mastodon's `idx_on_account_
    // id_target_account_id_...`). Missing these meant feint had no idea
    // these column combinations needed to stay unique. Two kinds are
    // excluded: partial indexes (`indpred IS NOT NULL`), which only
    // constrain rows matching their predicate rather than the whole table;
    // and expression indexes (`indexprs IS NOT NULL`, e.g. Listmonk's
    // `idx_subs_email ON (lower(email))`), whose key isn't a plain column
    // at all — `indkey` reports a `0` placeholder for an expression key,
    // which resolves to no real column and would otherwise be
    // misread as a (wrongly always-colliding) empty column list.
    let index_rows = client
        .query(
            "SELECT ci.relname, \
                    array(SELECT attname FROM pg_attribute \
                           WHERE attrelid = i.indrelid AND attnum = ANY(i.indkey::smallint[]) \
                           ORDER BY array_position(i.indkey::smallint[], attnum)) AS columns \
             FROM pg_index i \
             JOIN pg_class ci ON ci.oid = i.indexrelid \
             WHERE i.indrelid = $1 AND i.indisunique \
               AND i.indpred IS NULL AND i.indexprs IS NULL \
               AND NOT EXISTS (SELECT 1 FROM pg_constraint c \
                                WHERE c.conindid = i.indexrelid AND c.contype IN ('u', 'p'))",
            &[&table_oid],
        )
        .await?;
    // A primary key always has a backing `pg_constraint` row in Postgres —
    // there's no way to create one via a bare index — so every row here
    // (already filtered to "no backing constraint") is a plain unique
    // index, never a primary key.
    constraints.extend(index_rows.into_iter().map(|row| UniqueConstraint {
        name: row.get(0),
        is_primary: false,
        columns: row.get(1),
    }));

    // Belt-and-suspenders: a constraint with no resolvable plain columns
    // (expression/exotic-key cases the query above doesn't already
    // exclude) is worse than useless downstream — every row's "value" for
    // it is the same empty tuple, so consumers that check for uniqueness
    // by comparing tuples would see every row as a false collision.
    constraints.retain(|c| !c.columns.is_empty());

    Ok(constraints)
}

async fn list_foreign_keys(client: &Client, table_oid: u32) -> Result<Vec<ForeignKey>> {
    let rows = client
        .query(
            "SELECT con.conname, \
                    array(SELECT attname FROM pg_attribute \
                           WHERE attrelid = con.conrelid AND attnum = ANY(con.conkey) \
                           ORDER BY array_position(con.conkey, attnum)) AS local_columns, \
                    nsp2.nspname, cls2.relname, \
                    array(SELECT attname FROM pg_attribute \
                           WHERE attrelid = con.confrelid AND attnum = ANY(con.confkey) \
                           ORDER BY array_position(con.confkey, attnum)) AS ref_columns, \
                    con.condeferrable, con.condeferred \
             FROM pg_constraint con \
             JOIN pg_class cls2 ON cls2.oid = con.confrelid \
             JOIN pg_namespace nsp2 ON nsp2.oid = cls2.relnamespace \
             WHERE con.conrelid = $1 AND con.contype = 'f'",
            &[&table_oid],
        )
        .await?;

    Ok(rows
        .into_iter()
        .map(|row| ForeignKey {
            name: row.get(0),
            columns: row.get(1),
            ref_table: TableId {
                schema: row.get(2),
                name: row.get(3),
            },
            ref_columns: row.get(4),
            deferrable: row.get(5),
            initially_deferred: row.get(6),
        })
        .collect())
}

/// Matches `pg_get_constraintdef`'s output for exactly one shape: a single
/// unqualified (optionally double-quoted) column compared to an integer
/// literal — `CHECK ((col >= 0))`, `CHECK ((col <= 100))`, etc. This is the
/// standard shape Django's `PositiveSmallIntegerField`/`PositiveIntegerField`
/// and Rails' numeric validators emit, and it showed up dozens of times
/// across the real-world schema pilot (Zulip especially). Anything more
/// complex — cross-column, string, boolean, function-call expressions — is
/// deliberately left unmatched: feint doesn't attempt to evaluate arbitrary
/// CHECK expressions, only this narrow, common, safely-parseable one.
static SIMPLE_INT_CHECK_RE: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(
        r#"^CHECK \(\(\s*"?([A-Za-z_][A-Za-z0-9_]*)"?\s*(>=|<=|>|<|=)\s*(-?\d+)\s*\)\)$"#,
    )
    .expect("valid regex")
});

/// Narrow the generated range for `column_name` using every simple,
/// single-column integer CHECK constraint on `table` that mentions it
/// (multiple constraints on the same column — e.g. a separate lower and
/// upper bound — are intersected). Returns `(None, None)` when nothing
/// matches, which generation treats as "no narrowing, use the type's usual
/// default range."
fn simple_integer_bounds(
    check_constraints: &[CheckConstraint],
    column_name: &str,
) -> (Option<i64>, Option<i64>) {
    let mut min: Option<i64> = None;
    let mut max: Option<i64> = None;
    for c in check_constraints {
        let Some(caps) = SIMPLE_INT_CHECK_RE.captures(c.definition.trim()) else {
            continue;
        };
        if &caps[1] != column_name {
            continue;
        }
        let Ok(value) = caps[3].parse::<i64>() else {
            continue;
        };
        let (lo, hi) = match &caps[2] {
            ">=" => (Some(value), None),
            ">" => (value.checked_add(1), None),
            "<=" => (None, Some(value)),
            "<" => (None, value.checked_sub(1)),
            "=" => (Some(value), Some(value)),
            _ => continue,
        };
        if let Some(lo) = lo {
            min = Some(min.map_or(lo, |m| m.max(lo)));
        }
        if let Some(hi) = hi {
            max = Some(max.map_or(hi, |m| m.min(hi)));
        }
    }
    (min, max)
}

/// Matches `pg_get_constraintdef`'s `col = ANY (ARRAY[...])` shape — a
/// fixed-value allowlist, the standard idiom Rails/TypeORM emit for a
/// `validates ..., inclusion: {in: [...]}`-style column (`CHECK ((role =
/// ANY (ARRAY['USER'::text, 'ADMIN'::text])))`). Also matches the cast
/// variant Postgres emits when the column or array element type needs an
/// explicit cast to compare (`CHECK (((status)::text = ANY ((ARRAY[...
/// ::character varying])::text[]))))`), and a single unqualified column
/// name, optionally quoted/cast, on the left. The array's own contents are
/// captured as one string and split by [`ARRAY_ITEM_RE`].
static SIMPLE_ALLOWED_VALUES_RE: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(
    || {
        regex::Regex::new(
        r#"^CHECK \(\(\(?\s*"?([A-Za-z_][A-Za-z0-9_]*)"?\s*\)?(?:::[\w". ]+)?\s*=\s*ANY\s*\(\(?ARRAY\[(.*?)\]\)?(?:::[\w". ]+\[\])?\)\)\)$"#,
    )
    .expect("valid regex")
    },
);

/// Matches the singleton-equality variant of the same idiom — a table
/// narrowing a column (often a shared enum type) down to exactly one legal
/// value, e.g. NodeBB's `CHECK ((type = 'set'::public.legacy_object_type))`
/// or Penpot's `CHECK ((type = 'oidc'::text))`.
static SIMPLE_TEXT_EQ_RE: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(
        r#"^CHECK \(\(\(?\s*"?([A-Za-z_][A-Za-z0-9_]*)"?\s*\)?(?:::[\w". ]+)?\s*=\s*'((?:[^']|'')*)'(?:::[\w". ]+)?\)\)$"#,
    )
    .expect("valid regex")
});

/// One single-quoted string literal (with `''` as Postgres's escaped
/// single quote), ignoring any trailing `::cast` — used to split
/// `SIMPLE_ALLOWED_VALUES_RE`'s captured array contents into individual
/// values.
static ARRAY_ITEM_RE: std::sync::LazyLock<regex::Regex> =
    std::sync::LazyLock::new(|| regex::Regex::new(r#"'((?:[^']|'')*)'"#).expect("valid regex"));

/// The fixed set of legal values for `column_name` narrowed from every
/// simple, single-column allowlist CHECK constraint on `table` that
/// mentions it (`col = ANY (ARRAY[...])` or singleton `col = 'x'`).
/// Multiple matching constraints on the same column are intersected, same
/// as [`simple_integer_bounds`]. Returns `None` when nothing matches, or
/// when an intersection across multiple constraints leaves no values at
/// all (a contradiction that shouldn't occur in a real schema, but falls
/// back to "no narrowing" rather than generating into a value that can
/// never satisfy every constraint).
fn simple_allowed_values(
    check_constraints: &[CheckConstraint],
    column_name: &str,
) -> Option<Vec<String>> {
    let mut allowed: Option<Vec<String>> = None;
    for c in check_constraints {
        let def = c.definition.trim();
        let values: Vec<String> = if let Some(caps) = SIMPLE_ALLOWED_VALUES_RE.captures(def) {
            if &caps[1] != column_name {
                continue;
            }
            ARRAY_ITEM_RE
                .captures_iter(&caps[2])
                .map(|m| m[1].replace("''", "'"))
                .collect()
        } else if let Some(caps) = SIMPLE_TEXT_EQ_RE.captures(def) {
            if &caps[1] != column_name {
                continue;
            }
            vec![caps[2].replace("''", "'")]
        } else {
            continue;
        };
        if values.is_empty() {
            continue;
        }
        allowed = Some(match allowed {
            None => values,
            Some(existing) => existing
                .into_iter()
                .filter(|v| values.contains(v))
                .collect(),
        });
    }
    allowed.filter(|v| !v.is_empty())
}

async fn list_check_constraints(client: &Client, table_oid: u32) -> Result<Vec<CheckConstraint>> {
    let rows = client
        .query(
            "SELECT con.conname, pg_get_constraintdef(con.oid) \
             FROM pg_constraint con \
             WHERE con.conrelid = $1 AND con.contype = 'c'",
            &[&table_oid],
        )
        .await?;

    Ok(rows
        .into_iter()
        .map(|row| CheckConstraint {
            name: row.get(0),
            definition: row.get(1),
        })
        .collect())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn check(name: &str, definition: &str) -> CheckConstraint {
        CheckConstraint {
            name: name.to_string(),
            definition: definition.to_string(),
        }
    }

    #[test]
    fn plain_any_array_allowlist_is_extracted() {
        let constraints = vec![check(
            "users_role_check",
            "CHECK ((role = ANY (ARRAY['USER'::text, 'ADMIN'::text])))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "role"),
            Some(vec!["USER".to_string(), "ADMIN".to_string()])
        );
    }

    #[test]
    fn cast_any_array_allowlist_is_extracted() {
        // n8n's shape: column cast to ::text, array elements cast to
        // ::character varying, whole array cast to ::text[].
        let constraints = vec![check(
            "CHK_workflow_publication_outbox_status",
            "CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, \
             'failed'::character varying])::text[])))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "status"),
            Some(vec!["pending".to_string(), "failed".to_string()])
        );
    }

    #[test]
    fn single_element_any_array_allowlist_is_extracted() {
        let constraints = vec![check(
            "project_settings_project_mode_values",
            "CHECK ((project_mode = ANY (ARRAY['open'::text])))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "project_mode"),
            Some(vec!["open".to_string()])
        );
    }

    #[test]
    fn quoted_mixed_case_column_name_is_matched() {
        let constraints = vec![check(
            "workspace_activation_status_check",
            "CHECK ((\"activationStatus\" = ANY (ARRAY['PENDING'::text, 'ACTIVE'::text])))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "activationStatus"),
            Some(vec!["PENDING".to_string(), "ACTIVE".to_string()])
        );
    }

    #[test]
    fn singleton_equality_allowlist_is_extracted() {
        let constraints = vec![check(
            "sso_provider_type_check",
            "CHECK ((type = 'oidc'::text))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "type"),
            Some(vec!["oidc".to_string()])
        );
    }

    #[test]
    fn singleton_equality_with_schema_qualified_enum_cast_is_extracted() {
        let constraints = vec![check(
            "legacy_set_type_check",
            "CHECK ((type = 'set'::public.legacy_object_type))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "type"),
            Some(vec!["set".to_string()])
        );
    }

    #[test]
    fn singleton_equality_with_column_cast_is_extracted() {
        let constraints = vec![check(
            "ck_chart_datasource",
            "CHECK (((datasource_type)::text = 'table'::text))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "datasource_type"),
            Some(vec!["table".to_string()])
        );
    }

    #[test]
    fn wrong_column_name_is_ignored() {
        let constraints = vec![check(
            "users_role_check",
            "CHECK ((role = ANY (ARRAY['USER'::text, 'ADMIN'::text])))",
        )];
        assert_eq!(simple_allowed_values(&constraints, "status"), None);
    }

    #[test]
    fn cross_column_or_expression_is_not_matched() {
        // Twenty's real shape: an allowlist ORed with an unrelated
        // condition — deliberately left unmatched, same "don't guess"
        // stance as the cross-column CHECK limitation generally.
        let constraints = vec![check(
            "workspace_check",
            "CHECK (((\"activationStatus\" = ANY (ARRAY['PENDING_CREATION'::text, \
             'ONGOING_CREATION'::text])) OR (\"defaultRoleId\" IS NOT NULL)))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "activationStatus"),
            None
        );
    }

    #[test]
    fn escaped_single_quote_in_allowed_value_is_unescaped() {
        let constraints = vec![check(
            "labels_check",
            "CHECK ((label = ANY (ARRAY['can''t stop'::text, 'ok'::text])))",
        )];
        assert_eq!(
            simple_allowed_values(&constraints, "label"),
            Some(vec!["can't stop".to_string(), "ok".to_string()])
        );
    }

    #[test]
    fn multiple_constraints_on_same_column_are_intersected() {
        let constraints = vec![
            check(
                "c1",
                "CHECK ((role = ANY (ARRAY['USER'::text, 'ADMIN'::text, 'GUEST'::text])))",
            ),
            check(
                "c2",
                "CHECK ((role = ANY (ARRAY['ADMIN'::text, 'GUEST'::text])))",
            ),
        ];
        assert_eq!(
            simple_allowed_values(&constraints, "role"),
            Some(vec!["ADMIN".to_string(), "GUEST".to_string()])
        );
    }

    #[test]
    fn no_matching_constraint_returns_none() {
        assert_eq!(simple_allowed_values(&[], "role"), None);
    }
}
