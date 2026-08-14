//! Deterministic value generation.
//!
//! Every generated value is produced by a `ChaCha8Rng` seeded from a
//! `blake3` hash of `(global seed, table, column, row identity)`. Same
//! seed + same schema => byte-for-byte identical output. `row_identity` is
//! a string (currently just the row index formatted as text) rather than a
//! raw integer so that a future production-derived mode can key it off a
//! source row's logical identity instead, without touching the hashing
//! machinery itself.

use chrono::{DateTime, TimeZone, Utc};
use fake::faker::internet::en::SafeEmail;
use fake::faker::lorem::en::{Sentence, Word};
use fake::faker::name::en::{FirstName, LastName, Name};
use fake::faker::phone_number::en::PhoneNumber;
use fake::Fake;
use rand::Rng;
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;
use rust_decimal::Decimal;
use uuid::Builder as UuidBuilder;

use crate::error::{FeintError, Result};
use crate::introspect::{Column, TypeKind};
use crate::value::PgValue;

pub struct SeedKey<'a> {
    pub table: &'a str,
    pub column: &'a str,
    pub row_identity: &'a str,
}

pub fn derive_rng(global_seed: &str, key: &SeedKey) -> ChaCha8Rng {
    let input = format!(
        "{global_seed}\0{}\0{}\0{}",
        key.table, key.column, key.row_identity
    );
    let hash = blake3::hash(input.as_bytes());
    ChaCha8Rng::from_seed(*hash.as_bytes())
}

/// Resolve a column to a value, honoring (in order) an explicit
/// `feint.yaml` override, a column-name heuristic, then a column-type
/// heuristic.
pub fn generate_value(
    column: &Column,
    override_generator: Option<&str>,
    rng: &mut ChaCha8Rng,
) -> Result<PgValue> {
    if let Some(name) = override_generator {
        return dispatch_named(name, column, rng);
    }
    if let Some(name) = name_heuristic(&column.name) {
        return dispatch_named(name, column, rng);
    }
    dispatch_by_type(&column.type_name, &column.type_kind, column.nullable, rng)
}

/// Column-name based heuristic: only fires for name patterns that are a
/// strong, unambiguous signal (email/phone/person names). Everything else
/// falls through to the type-based heuristic, which is a safer default
/// than guessing from an arbitrary column name.
fn name_heuristic(column_name: &str) -> Option<&'static str> {
    let n = column_name.to_ascii_lowercase();
    if n.contains("email") {
        Some("email")
    } else if n.contains("phone") {
        Some("phone")
    } else if n == "first_name" || n == "firstname" {
        Some("first_name")
    } else if n == "last_name" || n == "lastname" || n == "surname" {
        Some("last_name")
    } else if n == "name" || n == "full_name" || n.ends_with("_name") {
        Some("person_name")
    } else {
        None
    }
}

/// Fake text for a bare key name (no [`Column`] to consult), keyed by the
/// same [`name_heuristic`] patterns used for a real column's name. Used for
/// masking a leaf inside a JSON/JSONB value at a specific path — see
/// [`crate::mask::mask_json_column_value`] — where there is no schema
/// column to dispatch on, only the JSON object key itself.
pub fn fake_text_for_key(key_name: &str, rng: &mut ChaCha8Rng) -> String {
    match name_heuristic(key_name) {
        Some("email") => SafeEmail().fake_with_rng(rng),
        Some("phone") => PhoneNumber().fake_with_rng(rng),
        Some("first_name") => FirstName().fake_with_rng(rng),
        Some("last_name") => LastName().fake_with_rng(rng),
        Some("person_name") => Name().fake_with_rng(rng),
        _ => Sentence(3..7).fake_with_rng(rng),
    }
}

/// Broader PII-pattern detector used only for the `feint init` "sensitive
/// fields detected" banner — informational, not a masking decision (there
/// is no masking in GENERATE mode: every value is synthetic regardless).
/// Deliberately wider than [`name_heuristic`], which only covers the
/// patterns that map to a specific generator.
pub fn classify_sensitive(column_name: &str) -> Option<&'static str> {
    let n = column_name.to_ascii_lowercase();
    if n.contains("email") {
        Some("email")
    } else if n.contains("phone") {
        Some("phone")
    } else if n == "name" || n == "full_name" || n.ends_with("_name") {
        Some("person_name")
    } else if n.contains("ssn") || n.contains("social_security") {
        Some("ssn")
    } else if n.contains("passport")
        || n.contains("license")
        || n.contains("national_id")
        || n.contains("card")
        || n.contains("cvv")
        || n.contains("iban")
        || n.contains("account_number")
    {
        Some("potential_identifier")
    } else if n.contains("address") || n.contains("street") {
        Some("address")
    } else if n.contains("dob") || n.contains("birth_date") || n.contains("date_of_birth") {
        Some("date_of_birth")
    } else if n == "ip" || n.contains("ip_address") {
        Some("ip_address")
    } else {
        None
    }
}

/// Recursively scan a sampled JSON/JSONB value for object keys that look
/// sensitive by name (via [`classify_sensitive`]), returning each hit's
/// full dot-separated path (e.g. `"contact.email"`) and the matched kind.
/// Only walks object members — array elements are skipped, since an
/// array's "keys" (indices) carry no name to classify. `max_depth` bounds
/// how far into nested objects this recurses (0 = top-level keys only).
///
/// Used only for `feint init`'s informational "sensitive fields detected"
/// banner: this looks at *key names* in a bounded sample of real rows,
/// never at the values themselves, and nothing it finds is written
/// anywhere — matches [`classify_sensitive`]'s own report-only role for
/// plain columns.
pub fn detect_sensitive_json_keys(
    value: &serde_json::Value,
    max_depth: usize,
) -> Vec<(String, &'static str)> {
    let mut found = Vec::new();
    collect_sensitive_json_keys(value, "", max_depth, &mut found);
    found
}

fn collect_sensitive_json_keys(
    value: &serde_json::Value,
    prefix: &str,
    depth_remaining: usize,
    out: &mut Vec<(String, &'static str)>,
) {
    let serde_json::Value::Object(map) = value else {
        return;
    };
    for (key, child) in map {
        let path = if prefix.is_empty() {
            key.clone()
        } else {
            format!("{prefix}.{key}")
        };
        if let Some(kind) = classify_sensitive(key) {
            out.push((path.clone(), kind));
        }
        if depth_remaining > 0 {
            collect_sensitive_json_keys(child, &path, depth_remaining - 1, out);
        }
    }
}

fn dispatch_by_type(
    type_name: &str,
    type_kind: &TypeKind,
    nullable: bool,
    rng: &mut ChaCha8Rng,
) -> Result<PgValue> {
    match type_kind {
        TypeKind::Enum(variants) => {
            if variants.is_empty() {
                return Ok(PgValue::Null);
            }
            let idx = rng.gen_range(0..variants.len());
            Ok(PgValue::Enum(type_name.to_string(), variants[idx].clone()))
        }
        TypeKind::Domain { base_type } => {
            // Domains are wire-transparent over their base type — generate
            // as if this were a plain column of the base type. Nested
            // domains-of-domains aren't resolved recursively by
            // introspection (only one level of `typbasetype` is followed),
            // so this treats the base type name as scalar; acceptable for
            // the common case.
            dispatch_by_type(base_type, &TypeKind::Scalar, nullable, rng)
        }
        TypeKind::Array { elem_type } => {
            let len = rng.gen_range(1..=3usize);
            let mut items = Vec::with_capacity(len);
            for _ in 0..len {
                items.push(dispatch_by_type(elem_type, &TypeKind::Scalar, false, rng)?);
            }
            Ok(PgValue::Array(items))
        }
        TypeKind::Composite | TypeKind::Other => {
            if nullable {
                Ok(PgValue::Null)
            } else {
                Err(FeintError::UnsupportedType(format!(
                    "type `{type_name}` has no built-in generator; add an explicit `generator:` override in feint.yaml for this column"
                )))
            }
        }
        TypeKind::Scalar => dispatch_named(
            scalar_type_generator(type_name),
            &placeholder_column(type_name, nullable),
            rng,
        ),
    }
}

/// Minimal stand-in `Column` used only to pass type context into
/// `dispatch_named` when recursing from `dispatch_by_type` (which doesn't
/// have a real `Column` for array elements / domain base types).
fn placeholder_column(type_name: &str, nullable: bool) -> Column {
    Column {
        name: String::new(),
        position: 0,
        type_name: type_name.to_string(),
        type_kind: TypeKind::Scalar,
        nullable,
        identity: crate::introspect::Identity::None,
        is_stored_generated: false,
        has_default: false,
        is_serial_default: false,
    }
}

fn scalar_type_generator(type_name: &str) -> &'static str {
    match type_name {
        "bool" => "bool",
        "int2" => "int2_range",
        "int4" => "int4_range",
        "int8" => "int8_range",
        "numeric" => "decimal",
        "float4" => "float4",
        "float8" => "float8",
        "uuid" => "uuid",
        "timestamp" => "timestamp",
        "timestamptz" => "timestamptz",
        "date" => "date",
        "json" | "jsonb" => "json_object",
        "bytea" => "bytea",
        "inet" | "cidr" => "inet",
        _ => "lorem_word",
    }
}

fn dispatch_named(name: &str, column: &Column, rng: &mut ChaCha8Rng) -> Result<PgValue> {
    Ok(match name {
        "email" => PgValue::Text(SafeEmail().fake_with_rng(rng)),
        "phone" => PgValue::Text(PhoneNumber().fake_with_rng(rng)),
        "first_name" => PgValue::Text(FirstName().fake_with_rng(rng)),
        "last_name" => PgValue::Text(LastName().fake_with_rng(rng)),
        "person_name" => PgValue::Text(Name().fake_with_rng(rng)),
        "lorem_word" => {
            let text_kind = column.type_name.as_str();
            if text_kind == "citext" {
                PgValue::Raw(Word().fake_with_rng::<String, _>(rng))
            } else {
                PgValue::Text(Sentence(3..7).fake_with_rng(rng))
            }
        }
        "bool" => PgValue::Bool(rng.gen_bool(0.5)),
        "int2_range" => PgValue::Int2(rng.gen_range(-1000..1000)),
        "int4_range" => PgValue::Int4(rng.gen_range(0..1_000_000)),
        "int8_range" => PgValue::Int8(rng.gen_range(0..1_000_000_000i64)),
        "decimal" => {
            let cents = rng.gen_range(0..10_000_000i64);
            PgValue::Numeric(Decimal::new(cents, 2))
        }
        "float4" => PgValue::Float4(rng.gen_range(0.0..1_000.0)),
        "float8" => PgValue::Float8(rng.gen_range(0.0..1_000.0)),
        "uuid" => {
            let bytes: [u8; 16] = rng.gen();
            PgValue::Uuid(UuidBuilder::from_random_bytes(bytes).into_uuid())
        }
        "timestamp" => {
            let dt = random_datetime(rng);
            PgValue::Timestamp(dt.naive_utc())
        }
        "timestamptz" => PgValue::TimestampTz(random_datetime(rng)),
        "date" => {
            let dt = random_datetime(rng);
            PgValue::Date(dt.date_naive())
        }
        "json_object" => {
            PgValue::Json(serde_json::json!({ "note": Word().fake_with_rng::<String, _>(rng) }))
        }
        "bytea" => {
            let len = rng.gen_range(4..16usize);
            PgValue::Bytea((0..len).map(|_| rng.gen()).collect())
        }
        "inet" => {
            let octets: [u8; 4] = rng.gen();
            PgValue::Raw(format!(
                "{}.{}.{}.{}",
                octets[0], octets[1], octets[2], octets[3]
            ))
        }
        other => {
            return Err(FeintError::Generation(format!(
                "unknown generator `{other}` for column `{}`",
                column.name
            )))
        }
    })
}

fn random_datetime(rng: &mut ChaCha8Rng) -> DateTime<Utc> {
    let start = Utc.with_ymd_and_hms(2015, 1, 1, 0, 0, 0).unwrap();
    let end = Utc::now();
    let span_secs = (end - start).num_seconds().max(1);
    let offset = rng.gen_range(0..span_secs);
    start + chrono::Duration::seconds(offset)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::Identity;

    fn text_column(name: &str) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "text".to_string(),
            type_kind: TypeKind::Scalar,
            nullable: false,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    #[test]
    fn same_seed_same_key_is_deterministic() {
        let key = SeedKey {
            table: "users",
            column: "email",
            row_identity: "0",
        };
        let mut rng1 = derive_rng("seed-a", &key);
        let mut rng2 = derive_rng("seed-a", &key);
        let col = text_column("email");
        let v1 = generate_value(&col, None, &mut rng1).unwrap();
        let v2 = generate_value(&col, None, &mut rng2).unwrap();
        assert_eq!(v1, v2);
    }

    #[test]
    fn different_seed_differs() {
        let key_a = SeedKey {
            table: "users",
            column: "email",
            row_identity: "0",
        };
        let key_b = SeedKey {
            table: "users",
            column: "email",
            row_identity: "1",
        };
        let mut rng1 = derive_rng("seed-a", &key_a);
        let mut rng2 = derive_rng("seed-a", &key_b);
        let col = text_column("email");
        let v1 = generate_value(&col, None, &mut rng1).unwrap();
        let v2 = generate_value(&col, None, &mut rng2).unwrap();
        assert_ne!(v1, v2);
    }

    #[test]
    fn name_heuristic_picks_email_generator() {
        assert_eq!(name_heuristic("user_email"), Some("email"));
        assert_eq!(name_heuristic("home_phone"), Some("phone"));
        assert_eq!(name_heuristic("display_name"), Some("person_name"));
        assert_eq!(name_heuristic("status"), None);
    }

    #[test]
    fn enum_generator_picks_a_declared_variant() {
        let col = Column {
            type_kind: TypeKind::Enum(vec!["sad".into(), "ok".into(), "happy".into()]),
            type_name: "mood".to_string(),
            ..text_column("mood")
        };
        let mut rng = derive_rng(
            "seed",
            &SeedKey {
                table: "t",
                column: "mood",
                row_identity: "0",
            },
        );
        let v = generate_value(&col, None, &mut rng).unwrap();
        match v {
            PgValue::Enum(ty, label) => {
                assert_eq!(ty, "mood");
                assert!(["sad", "ok", "happy"].contains(&label.as_str()));
            }
            other => panic!("expected Enum, got {other:?}"),
        }
    }

    #[test]
    fn detect_sensitive_json_keys_finds_a_nested_match_within_depth() {
        let value = serde_json::json!({
            "bio": "hello",
            "contact": { "email": "a@b.com", "note": "fine" }
        });
        let found = detect_sensitive_json_keys(&value, 2);
        assert!(found.contains(&("contact.email".to_string(), "email")));
        assert!(!found.iter().any(|(p, _)| p == "bio"));
        assert!(!found.iter().any(|(p, _)| p == "contact.note"));
    }

    #[test]
    fn detect_sensitive_json_keys_respects_max_depth() {
        let value = serde_json::json!({ "a": { "b": { "ssn": "123-45-6789" } } });
        // depth 0: only top-level keys ("a") are checked — no match.
        assert!(detect_sensitive_json_keys(&value, 0).is_empty());
        // depth 2 reaches "a.b.ssn".
        let found = detect_sensitive_json_keys(&value, 2);
        assert!(found.iter().any(|(p, _)| p == "a.b.ssn"));
    }

    #[test]
    fn detect_sensitive_json_keys_ignores_array_elements() {
        let value = serde_json::json!({ "tags": ["email", "phone"] });
        assert!(detect_sensitive_json_keys(&value, 2).is_empty());
    }

    #[test]
    fn fake_text_for_key_is_deterministic_and_type_appropriate_by_key_name() {
        let mut rng_a = derive_rng(
            "seed",
            &SeedKey {
                table: "t",
                column: "profile.contact.email",
                row_identity: "1",
            },
        );
        let mut rng_b = derive_rng(
            "seed",
            &SeedKey {
                table: "t",
                column: "profile.contact.email",
                row_identity: "1",
            },
        );
        let a = fake_text_for_key("email", &mut rng_a);
        let b = fake_text_for_key("email", &mut rng_b);
        assert_eq!(a, b);
        assert!(a.contains('@'), "expected an email-shaped fake value");
    }
}
