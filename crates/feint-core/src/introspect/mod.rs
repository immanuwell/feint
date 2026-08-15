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
        let columns = list_columns(client, rt.oid, &mut enum_cache).await?;
        let unique_constraints = list_unique_constraints(client, rt.oid).await?;
        let primary_key = unique_constraints
            .iter()
            .find(|u| u.is_primary)
            .map(|u| u.columns.clone());
        let foreign_keys = list_foreign_keys(client, rt.oid).await?;
        let check_constraints = list_check_constraints(client, rt.oid).await?;

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
        let max_length = if typmod > 0 && matches!(type_name.as_str(), "varchar" | "bpchar") {
            Some(typmod - 4)
        } else {
            None
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
