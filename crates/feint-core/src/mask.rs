//! Deterministic masking transform for CLONE mode.
//!
//! Never touches a primary-key column or a foreign-key-owning column
//! ([`validate_masking_config`] rejects that at config-load time) — that
//! invariant is what lets CLONE mode preserve keys unchanged on the
//! target and skip the `RefPool`/remapping machinery GENERATE mode needs.

use std::collections::BTreeMap;

use rand::Rng;
use serde::{Deserialize, Serialize};

use crate::config::FeintConfig;
use crate::error::{FeintError, Result};
use crate::generate::{classify_sensitive, derive_rng, fake_text_for_key, generate_value, SeedKey};
use crate::introspect::{Column, Schema, Table, TypeKind};
use crate::value::PgValue;

/// Dot-separated JSON key path (e.g. `"contact.email"`) to the masking
/// strategy to apply at that path inside a `json`/`jsonb` column's value.
/// See [`mask_json_column_value`].
pub type JsonPathRules = BTreeMap<String, MaskStrategy>;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MaskStrategy {
    /// Deterministic synthetic replacement — reuses the GENERATE-mode
    /// generator engine, keyed by the source row's real identity so the
    /// same source row always maps to the same fake value across runs.
    Fake,
    /// Deterministic one-way hash of the real value. Text-like columns
    /// only.
    Hash,
    /// Fixed placeholder (or NULL, on a nullable column).
    Redact,
    /// Explicit escape hatch: pass the real value through unmasked.
    None,
}

/// True if masking `col_name` would break referential integrity on the
/// target: it's part of the primary key, or it's owned by a foreign key.
/// CLONE mode preserves these values unchanged by construction, so they
/// must never be masked — not even by the column-name default heuristic
/// (an FK column named e.g. `email_id` would otherwise get swept up by
/// [`classify_sensitive`]'s `email` match).
pub fn is_key_column(table: &Table, col_name: &str) -> bool {
    let is_pk = table
        .primary_key
        .as_ref()
        .map(|pk| pk.iter().any(|c| c == col_name))
        .unwrap_or(false);
    let is_fk_owner = table
        .foreign_keys
        .iter()
        .any(|fk| fk.columns.iter().any(|c| c == col_name));
    is_pk || is_fk_owner
}

/// Resolve the strategy for a column. Key columns ([`is_key_column`])
/// always resolve to `none`, regardless of any override — enforced here
/// too, not just at config-validation time, as a second line of defense.
/// Otherwise: an explicit `mask:` override wins; failing that, `fake` if
/// the column name looks sensitive ([`classify_sensitive`]), else pass
/// through unmasked.
pub fn resolve_mask_strategy(
    table: &Table,
    column: &Column,
    override_strategy: Option<MaskStrategy>,
) -> MaskStrategy {
    if is_key_column(table, &column.name) {
        return MaskStrategy::None;
    }
    if let Some(s) = override_strategy {
        return s;
    }
    if classify_sensitive(&column.name).is_some() {
        MaskStrategy::Fake
    } else {
        MaskStrategy::None
    }
}

/// Cross-references every `mask:` override in `config` against the
/// introspected `schema` and rejects configurations that would break FK
/// integrity or uniqueness on the target. Call once, before any table is
/// read or written.
pub fn validate_masking_config(schema: &Schema, config: &FeintConfig) -> Result<()> {
    for table in &schema.tables {
        let Some(table_config) = config.table_config(&table.id.qualified()) else {
            continue;
        };
        for (col_name, col_config) in &table_config.columns {
            let Some(column) = table.column(col_name) else {
                continue;
            };

            if !col_config.json_paths.is_empty() {
                if is_key_column(table, col_name) {
                    return Err(FeintError::Config(format!(
                        "`{}`.`{col_name}` cannot use `json_paths`: it is part of a primary key \
                         or foreign key, and masking it would break referential integrity.",
                        table.id.qualified()
                    )));
                }
                if !matches!(column.type_name.as_str(), "json" | "jsonb") {
                    return Err(FeintError::Config(format!(
                        "`{}`.`{col_name}` cannot use `json_paths`: it is a `{}` column, not \
                         `json`/`jsonb`.",
                        table.id.qualified(),
                        column.type_name
                    )));
                }
                if col_config.mask.is_some_and(|s| s != MaskStrategy::None) {
                    return Err(FeintError::Config(format!(
                        "`{}`.`{col_name}` sets both `mask:` and `json_paths:` — pick one. \
                         `json_paths` masks specific keys inside the JSON value and leaves the \
                         rest alone; a whole-column `mask:` masks the entire value. Remove the \
                         `mask:` override, or drop `json_paths` and mask the whole column instead.",
                        table.id.qualified()
                    )));
                }
                for path in col_config.json_paths.keys() {
                    if path.trim().is_empty() || path.split('.').any(|p| p.is_empty()) {
                        return Err(FeintError::Config(format!(
                            "`{}`.`{col_name}` has an invalid `json_paths` key {path:?}: must be \
                             a non-empty, dot-separated path with no empty segments, e.g. \
                             `contact.email`.",
                            table.id.qualified()
                        )));
                    }
                }
            }

            let Some(strategy) = col_config.mask else {
                continue;
            };
            if strategy == MaskStrategy::None {
                continue;
            }

            if is_key_column(table, col_name) {
                return Err(FeintError::Config(format!(
                    "`{}`.`{col_name}` cannot be masked: it is part of a primary key or foreign \
                     key, and masking it would break referential integrity. Remove the `mask:` \
                     override, or set it to `none`.",
                    table.id.qualified()
                )));
            }

            let is_other_unique = table
                .unique_constraints
                .iter()
                .any(|uc| !uc.is_primary && uc.columns.contains(col_name));
            if strategy == MaskStrategy::Redact && is_other_unique {
                return Err(FeintError::Config(format!(
                    "`{}`.`{col_name}` cannot use `mask: redact`: it is part of a unique \
                     constraint, and a fixed placeholder would collide across rows. Use \
                     `mask: hash` or `mask: fake` instead.",
                    table.id.qualified()
                )));
            }

            if strategy == MaskStrategy::Hash && !is_hashable_type(column) {
                return Err(FeintError::Config(format!(
                    "`{}`.`{col_name}` cannot use `mask: hash`: hashing is only supported for \
                     text-like columns (text, varchar, citext, ...). Use `mask: fake` instead.",
                    table.id.qualified()
                )));
            }
        }
    }
    Ok(())
}

fn is_hashable_type(column: &Column) -> bool {
    matches!(
        column.type_name.as_str(),
        "text" | "varchar" | "bpchar" | "name" | "citext"
    )
}

/// Apply masking to one column's real value from one source row.
/// `row_identity` should come from [`row_identity_key`] so `fake` masking
/// produces the same output for the same source row across repeated
/// `feint clone`/`feint mask` runs.
pub fn mask_value(
    strategy: MaskStrategy,
    column: &Column,
    generator_override: Option<&str>,
    real_value: &PgValue,
    seed: &str,
    table_name: &str,
    row_identity: &str,
) -> Result<PgValue> {
    // Unconditional and first: an absent value stays absent, regardless of
    // strategy — otherwise e.g. `hash` would turn a NULL middle_name into
    // a non-null value, silently changing the target's null density
    // relative to the source.
    if real_value.is_null() {
        return Ok(PgValue::Null);
    }

    match strategy {
        MaskStrategy::None => Ok(real_value.clone()),
        MaskStrategy::Fake => {
            let mut rng = derive_rng(
                seed,
                &SeedKey {
                    table: table_name,
                    column: &column.name,
                    row_identity,
                },
            );
            generate_value(column, generator_override, &mut rng)
        }
        MaskStrategy::Hash => {
            let input = format!("{seed}\0{}", real_value.as_text_literal());
            let digest = blake3::hash(input.as_bytes());
            Ok(PgValue::Text(format!("masked_{}", &digest.to_hex()[..24])))
        }
        MaskStrategy::Redact => {
            if column.nullable {
                Ok(PgValue::Null)
            } else {
                Ok(redact_literal(column))
            }
        }
    }
}

/// Apply per-path masking to a `json`/`jsonb` column's real value: every
/// key listed in `json_paths` gets masked in place, and every key not
/// listed passes through unchanged. Complements [`mask_value`], which only
/// ever treats a JSON column as one opaque blob — call this instead when
/// `json_paths` overrides are configured for the column (validated
/// mutually exclusive with a whole-column `mask:` by
/// [`validate_masking_config`]).
///
/// A NULL column value, or a path that doesn't exist in a given row's
/// document (a sparse/optional key, or a document that isn't even an
/// object), is left as-is for that row rather than treated as an error —
/// not every row's JSON necessarily has the same shape.
pub fn mask_json_column_value(
    json_paths: &JsonPathRules,
    real_value: &PgValue,
    seed: &str,
    table_name: &str,
    column_name: &str,
    row_identity: &str,
) -> PgValue {
    let PgValue::Json(value) = real_value else {
        return real_value.clone();
    };
    let mut out = value.clone();
    for (path, strategy) in json_paths {
        if *strategy == MaskStrategy::None {
            continue;
        }
        let components: Vec<&str> = path.split('.').collect();
        mask_json_path(
            &mut out,
            &components,
            *strategy,
            seed,
            table_name,
            column_name,
            row_identity,
            path,
        );
    }
    PgValue::Json(out)
}

#[allow(clippy::too_many_arguments)]
fn mask_json_path(
    node: &mut serde_json::Value,
    remaining: &[&str],
    strategy: MaskStrategy,
    seed: &str,
    table_name: &str,
    column_name: &str,
    row_identity: &str,
    full_path: &str,
) {
    let [head, tail @ ..] = remaining else {
        return;
    };
    let serde_json::Value::Object(map) = node else {
        return;
    };
    if tail.is_empty() {
        if let Some(leaf) = map.get_mut(*head) {
            *leaf = masked_json_leaf(
                leaf,
                strategy,
                seed,
                table_name,
                column_name,
                row_identity,
                full_path,
            );
        }
    } else if let Some(child) = map.get_mut(*head) {
        mask_json_path(
            child,
            tail,
            strategy,
            seed,
            table_name,
            column_name,
            row_identity,
            full_path,
        );
    }
}

#[allow(clippy::too_many_arguments)]
fn masked_json_leaf(
    original: &serde_json::Value,
    strategy: MaskStrategy,
    seed: &str,
    table_name: &str,
    column_name: &str,
    row_identity: &str,
    full_path: &str,
) -> serde_json::Value {
    match strategy {
        MaskStrategy::None => original.clone(),
        MaskStrategy::Redact => serde_json::Value::Null,
        MaskStrategy::Hash => {
            let input = format!("{seed}\0{table_name}\0{column_name}\0{full_path}\0{original}");
            let digest = blake3::hash(input.as_bytes());
            serde_json::Value::String(format!("masked_{}", &digest.to_hex()[..24]))
        }
        MaskStrategy::Fake => {
            let mut rng = derive_rng(
                seed,
                &SeedKey {
                    table: table_name,
                    column: &format!("{column_name}.{full_path}"),
                    row_identity,
                },
            );
            match original {
                serde_json::Value::String(_) => {
                    let key_name = full_path.rsplit('.').next().unwrap_or(full_path);
                    serde_json::Value::String(fake_text_for_key(key_name, &mut rng))
                }
                serde_json::Value::Number(_) => {
                    serde_json::json!(rng.gen_range(0..1_000_000i64))
                }
                serde_json::Value::Bool(_) => serde_json::Value::Bool(rng.gen_bool(0.5)),
                // A nested object/array has no single well-defined "fake"
                // replacement — redact it instead of guessing a shape.
                _ => serde_json::Value::Null,
            }
        }
    }
}

pub(crate) fn redact_literal(column: &Column) -> PgValue {
    match column.type_name.as_str() {
        "bool" => PgValue::Bool(false),
        "int2" => PgValue::Int2(0),
        "int4" => PgValue::Int4(0),
        "int8" => PgValue::Int8(0),
        "numeric" => PgValue::Numeric(rust_decimal::Decimal::ZERO),
        "float4" => PgValue::Float4(0.0),
        "float8" => PgValue::Float8(0.0),
        "date" => PgValue::Date(chrono::NaiveDate::from_ymd_opt(1970, 1, 1).unwrap()),
        "timestamp" => PgValue::Timestamp(
            chrono::NaiveDate::from_ymd_opt(1970, 1, 1)
                .unwrap()
                .and_hms_opt(0, 0, 0)
                .unwrap(),
        ),
        "timestamptz" => PgValue::TimestampTz(chrono::DateTime::from_timestamp(0, 0).unwrap()),
        "json" | "jsonb" => PgValue::Json(serde_json::json!({})),
        _ => match &column.type_kind {
            TypeKind::Array { .. } => PgValue::Array(vec![]),
            _ => PgValue::Text("REDACTED".to_string()),
        },
    }
}

/// Build a stable identity key for a source row: its primary-key tuple
/// rendered as text and NUL-joined (safe — Postgres text/varchar can't
/// contain a NUL byte, and `bytea`'s text literal is hex-encoded, so no
/// raw NUL leaks in from a binary PK either). Falls back to a unique
/// constraint, then to the whole row's values, when there's no primary
/// key — two fully-identical source rows getting the same fake output in
/// that last case is harmless, since they're indistinguishable anyway.
pub fn row_identity_key(table: &Table, columns: &[&Column], row: &[PgValue]) -> String {
    let key_columns: Vec<&String> = if let Some(pk) = &table.primary_key {
        pk.iter().collect()
    } else if let Some(uc) = table.unique_constraints.first() {
        uc.columns.iter().collect()
    } else {
        columns.iter().map(|c| &c.name).collect()
    };

    key_columns
        .iter()
        .filter_map(|name| {
            columns
                .iter()
                .position(|c| &c.name == *name)
                .map(|idx| row[idx].as_text_literal())
        })
        .collect::<Vec<_>>()
        .join("\0")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Identity, TypeKind};

    fn text_column(name: &str, nullable: bool) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "text".to_string(),
            type_schema: "pg_catalog".to_string(),
            type_kind: TypeKind::Scalar,
            max_length: None,
            vector_dimensions: None,
            numeric_precision: None,
            numeric_scale: None,
            check_min: None,
            check_max: None,
            check_allowed_values: None,
            check_null_escape: false,
            check_like_prefix: None,
            nullable,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    fn table_with(
        columns: Vec<Column>,
        primary_key: Option<Vec<String>>,
        fks: Vec<crate::introspect::ForeignKey>,
    ) -> Table {
        Table {
            id: crate::introspect::TableId {
                schema: "public".to_string(),
                name: "t".to_string(),
            },
            columns,
            primary_key,
            foreign_keys: fks,
            unique_constraints: vec![],
            check_constraints: vec![],
        }
    }

    #[test]
    fn null_passes_through_regardless_of_strategy() {
        let col = text_column("ssn", true);
        for strategy in [
            MaskStrategy::Fake,
            MaskStrategy::Hash,
            MaskStrategy::Redact,
            MaskStrategy::None,
        ] {
            let out = mask_value(strategy, &col, None, &PgValue::Null, "seed", "t", "0").unwrap();
            assert_eq!(
                out,
                PgValue::Null,
                "strategy {strategy:?} did not pass NULL through"
            );
        }
    }

    #[test]
    fn fake_masking_is_deterministic_per_row_identity() {
        let col = text_column("email", false);
        let real = PgValue::Text("alice@example.com".to_string());
        let a = mask_value(MaskStrategy::Fake, &col, None, &real, "seed", "users", "42").unwrap();
        let b = mask_value(MaskStrategy::Fake, &col, None, &real, "seed", "users", "42").unwrap();
        assert_eq!(a, b);
        let c = mask_value(MaskStrategy::Fake, &col, None, &real, "seed", "users", "43").unwrap();
        assert_ne!(a, c);
    }

    #[test]
    fn hash_masking_is_deterministic_and_differs_from_input() {
        let col = text_column("notes", false);
        let real = PgValue::Text("sensitive note".to_string());
        let a = mask_value(MaskStrategy::Hash, &col, None, &real, "seed", "t", "1").unwrap();
        let b = mask_value(MaskStrategy::Hash, &col, None, &real, "seed", "t", "1").unwrap();
        assert_eq!(a, b);
        assert_ne!(a, real);
    }

    #[test]
    fn redact_uses_null_on_nullable_and_literal_on_not_null() {
        let nullable = text_column("bio", true);
        let real = PgValue::Text("secret bio".to_string());
        let out = mask_value(
            MaskStrategy::Redact,
            &nullable,
            None,
            &real,
            "seed",
            "t",
            "1",
        )
        .unwrap();
        assert_eq!(out, PgValue::Null);

        let not_null = text_column("bio", false);
        let out = mask_value(
            MaskStrategy::Redact,
            &not_null,
            None,
            &real,
            "seed",
            "t",
            "1",
        )
        .unwrap();
        assert_eq!(out, PgValue::Text("REDACTED".to_string()));
    }

    #[test]
    fn none_strategy_passes_real_value_through() {
        let col = text_column("username", false);
        let real = PgValue::Text("carol".to_string());
        let out = mask_value(MaskStrategy::None, &col, None, &real, "seed", "t", "1").unwrap();
        assert_eq!(out, real);
    }

    #[test]
    fn default_resolution_flags_sensitive_names_as_fake() {
        let email_col = text_column("email", false);
        let t = table_with(vec![email_col.clone()], None, vec![]);
        assert_eq!(
            resolve_mask_strategy(&t, &email_col, None),
            MaskStrategy::Fake
        );
        let other_col = text_column("status", false);
        let t2 = table_with(vec![other_col.clone()], None, vec![]);
        assert_eq!(
            resolve_mask_strategy(&t2, &other_col, None),
            MaskStrategy::None
        );
        assert_eq!(
            resolve_mask_strategy(&t2, &other_col, Some(MaskStrategy::Redact)),
            MaskStrategy::Redact
        );
    }

    #[test]
    fn key_columns_never_resolve_to_masking_even_if_name_looks_sensitive() {
        // An FK column whose name happens to match the "email" pattern
        // must never be masked — masking it would desynchronize it from
        // the referenced table's (unmasked) primary key.
        let fk_col = text_column("email_id", false);
        let fk = crate::introspect::ForeignKey {
            name: "t_email_id_fkey".to_string(),
            columns: vec!["email_id".to_string()],
            ref_table: crate::introspect::TableId {
                schema: "public".to_string(),
                name: "emails".to_string(),
            },
            ref_columns: vec!["id".to_string()],
            deferrable: false,
            initially_deferred: false,
        };
        let t = table_with(vec![fk_col.clone()], None, vec![fk]);
        assert!(is_key_column(&t, "email_id"));
        assert_eq!(resolve_mask_strategy(&t, &fk_col, None), MaskStrategy::None);
        // Even an explicit override is overridden back to `none`, as a
        // second line of defense behind config validation.
        assert_eq!(
            resolve_mask_strategy(&t, &fk_col, Some(MaskStrategy::Fake)),
            MaskStrategy::None
        );

        let pk_col = text_column("id", false);
        let t2 = table_with(vec![pk_col.clone()], Some(vec!["id".to_string()]), vec![]);
        assert!(is_key_column(&t2, "id"));
        assert_eq!(
            resolve_mask_strategy(&t2, &pk_col, None),
            MaskStrategy::None
        );
    }

    fn json_column() -> Column {
        Column {
            name: "profile".to_string(),
            position: 1,
            type_name: "jsonb".to_string(),
            type_schema: "pg_catalog".to_string(),
            type_kind: TypeKind::Scalar,
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
    fn json_path_masking_only_touches_configured_paths() {
        let real = PgValue::Json(serde_json::json!({
            "bio": "loves hiking",
            "contact": { "email": "alice@example.com", "phone": "555-1234" }
        }));
        let mut paths = JsonPathRules::new();
        paths.insert("contact.email".to_string(), MaskStrategy::Redact);

        let masked = mask_json_column_value(&paths, &real, "seed", "users", "profile", "1");
        let PgValue::Json(v) = masked else {
            panic!("expected Json");
        };
        assert_eq!(v["bio"], serde_json::json!("loves hiking"));
        assert_eq!(v["contact"]["phone"], serde_json::json!("555-1234"));
        assert_eq!(v["contact"]["email"], serde_json::Value::Null);
    }

    #[test]
    fn json_path_masking_ignores_a_missing_path() {
        let real = PgValue::Json(serde_json::json!({ "bio": "hello" }));
        let mut paths = JsonPathRules::new();
        paths.insert("contact.email".to_string(), MaskStrategy::Redact);

        let masked = mask_json_column_value(&paths, &real, "seed", "users", "profile", "1");
        let PgValue::Json(v) = masked else {
            panic!("expected Json");
        };
        assert_eq!(v, serde_json::json!({ "bio": "hello" }));
    }

    #[test]
    fn json_path_masking_null_column_passes_through() {
        let paths = JsonPathRules::from([("a.b".to_string(), MaskStrategy::Redact)]);
        let masked = mask_json_column_value(&paths, &PgValue::Null, "seed", "t", "c", "1");
        assert_eq!(masked, PgValue::Null);
    }

    #[test]
    fn json_path_hash_is_deterministic_and_differs_from_the_real_value() {
        let real = PgValue::Json(serde_json::json!({ "ssn": "123-45-6789" }));
        let paths = JsonPathRules::from([("ssn".to_string(), MaskStrategy::Hash)]);
        let a = mask_json_column_value(&paths, &real, "seed", "t", "c", "1");
        let b = mask_json_column_value(&paths, &real, "seed", "t", "c", "1");
        assert_eq!(a, b);
        let PgValue::Json(v) = &a else {
            panic!("expected Json");
        };
        assert_ne!(v["ssn"], serde_json::json!("123-45-6789"));
        assert!(v["ssn"].as_str().unwrap().starts_with("masked_"));
    }

    #[test]
    fn json_path_fake_preserves_leaf_type_and_varies_by_row_identity() {
        let real = PgValue::Json(serde_json::json!({ "age": 30, "active": true }));
        let paths = JsonPathRules::from([
            ("age".to_string(), MaskStrategy::Fake),
            ("active".to_string(), MaskStrategy::Fake),
        ]);
        let PgValue::Json(v) = mask_json_column_value(&paths, &real, "seed", "t", "c", "1") else {
            panic!("expected Json");
        };
        assert!(v["age"].is_number());
        assert!(v["active"].is_boolean());
    }

    #[test]
    fn json_path_none_leaves_the_leaf_unchanged() {
        let real = PgValue::Json(serde_json::json!({ "note": "keep me" }));
        let paths = JsonPathRules::from([("note".to_string(), MaskStrategy::None)]);
        let masked = mask_json_column_value(&paths, &real, "seed", "t", "c", "1");
        assert_eq!(masked, real);
    }

    #[test]
    fn json_paths_and_whole_column_mask_are_mutually_exclusive() {
        let schema = Schema {
            tables: vec![table_with(vec![json_column()], None, vec![])],
        };
        let mut config = FeintConfig {
            version: 1,
            seed: "seed".to_string(),
            tables: BTreeMap::new(),
        };
        config.tables.insert(
            "public.t".to_string(),
            crate::config::TableConfig {
                rows: 1,
                strategy: Default::default(),
                columns: BTreeMap::from([(
                    "profile".to_string(),
                    crate::config::ColumnConfig {
                        generator: None,
                        mask: Some(MaskStrategy::Hash),
                        json_paths: JsonPathRules::from([(
                            "contact.email".to_string(),
                            MaskStrategy::Redact,
                        )]),
                    },
                )]),
            },
        );
        let err = validate_masking_config(&schema, &config).unwrap_err();
        assert!(format!("{err}").contains("both `mask:` and `json_paths:`"));
    }

    #[test]
    fn json_paths_rejected_on_a_non_json_column() {
        let schema = Schema {
            tables: vec![table_with(vec![text_column("bio", true)], None, vec![])],
        };
        let mut config = FeintConfig {
            version: 1,
            seed: "seed".to_string(),
            tables: BTreeMap::new(),
        };
        config.tables.insert(
            "public.t".to_string(),
            crate::config::TableConfig {
                rows: 1,
                strategy: Default::default(),
                columns: BTreeMap::from([(
                    "bio".to_string(),
                    crate::config::ColumnConfig {
                        generator: None,
                        mask: None,
                        json_paths: JsonPathRules::from([("a".to_string(), MaskStrategy::Redact)]),
                    },
                )]),
            },
        );
        let err = validate_masking_config(&schema, &config).unwrap_err();
        assert!(format!("{err}").contains("not `json`/`jsonb`"));
    }
}
