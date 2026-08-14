//! Runtime-typed Postgres value.
//!
//! `tokio_postgres`'s `ToSql`/`FromSql` are normally implemented for
//! compile-time-known Rust types. feint introspects arbitrary schemas at
//! runtime (unknown enums, domains, composites, extension types like
//! `citext`/`inet`), so there's no way to have a Rust type per column.
//! `PgValue` is the single runtime value type everything in feint routes
//! through instead: well-known scalars use the driver's normal binary
//! wire format, everything else falls back to Postgres's textual
//! representation (which is always a valid encoding for any type via an
//! explicit `::type` cast in the SQL template).

use std::error::Error as StdError;

use bytes::BytesMut;
use chrono::{DateTime, NaiveDate, NaiveDateTime, Utc};
use postgres_types::{FromSql, IsNull, Kind, ToSql, Type};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// `Serialize`/`Deserialize` back `snapshot.rs`'s file format: a snapshot
/// captures exactly the already-masked values a `clone` run would have
/// written, so replaying them at restore time needs no repeat trip to a
/// source database. `rust_decimal`'s `serde-str` feature is load-bearing
/// here — `Decimal`'s default serde representation round-trips through
/// self-describing formats but not through bincode's compact binary one.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum PgValue {
    Null,
    Bool(bool),
    Int2(i16),
    Int4(i32),
    Int8(i64),
    Numeric(Decimal),
    Float4(f32),
    Float8(f64),
    Text(String),
    Bytea(Vec<u8>),
    Uuid(Uuid),
    Timestamp(NaiveDateTime),
    TimestampTz(DateTime<Utc>),
    Date(NaiveDate),
    /// Serialized as its JSON text, not as `serde_json::Value` directly:
    /// `Value`'s `Deserialize` impl needs `deserialize_any`, which bincode
    /// (a fixed, non-self-describing format) cannot provide.
    Json(#[serde(with = "json_as_string")] serde_json::Value),
    /// Homogeneous array of values, rendered via Postgres array-literal
    /// text syntax (`{a,b,c}`) rather than the binary array wire format —
    /// simpler and correct for any element type, at a small perf cost.
    Array(Vec<PgValue>),
    /// (enum type name, variant label). Enum wire format is identical in
    /// text and binary (the label bytes), so this is unconditionally cheap
    /// and correct.
    Enum(String, String),
    /// Pre-formatted Postgres text literal for anything else: domains,
    /// citext, inet/cidr, ranges/multiranges, composites. Always sent in
    /// text format; the SQL template must pair this with an explicit
    /// `::type` cast so Postgres knows how to parse it.
    Raw(String),
}

impl PgValue {
    /// Render as a Postgres array-literal element: quote if it contains
    /// characters that are special in `{...}` syntax, or is empty; NULL is
    /// unquoted.
    fn as_array_element_literal(&self) -> String {
        match self {
            PgValue::Null => "NULL".to_string(),
            PgValue::Array(items) => {
                let inner: Vec<String> = items
                    .iter()
                    .map(PgValue::as_array_element_literal)
                    .collect();
                format!("{{{}}}", inner.join(","))
            }
            other => {
                let text = other.as_text_literal();
                let needs_quoting = text.is_empty()
                    || text
                        .chars()
                        .any(|c| matches!(c, '{' | '}' | ',' | '"' | '\\' | ' ' | '\t' | '\n'))
                    || text.eq_ignore_ascii_case("null");
                if needs_quoting {
                    let escaped = text.replace('\\', "\\\\").replace('"', "\\\"");
                    format!("\"{escaped}\"")
                } else {
                    text
                }
            }
        }
    }

    /// Render the value as a plain Postgres text-literal payload (no outer
    /// quotes) — what would appear inside `'...'` in SQL, or the payload of
    /// a text-format wire parameter.
    pub fn as_text_literal(&self) -> String {
        match self {
            PgValue::Null => String::new(),
            PgValue::Bool(b) => if *b { "t" } else { "f" }.to_string(),
            PgValue::Int2(v) => v.to_string(),
            PgValue::Int4(v) => v.to_string(),
            PgValue::Int8(v) => v.to_string(),
            PgValue::Numeric(v) => v.to_string(),
            PgValue::Float4(v) => v.to_string(),
            PgValue::Float8(v) => v.to_string(),
            PgValue::Text(v) => v.clone(),
            PgValue::Bytea(v) => format!("\\x{}", hex_encode(v)),
            PgValue::Uuid(v) => v.to_string(),
            PgValue::Timestamp(v) => v.format("%Y-%m-%d %H:%M:%S%.f").to_string(),
            PgValue::TimestampTz(v) => v.format("%Y-%m-%d %H:%M:%S%.f%:z").to_string(),
            PgValue::Date(v) => v.format("%Y-%m-%d").to_string(),
            PgValue::Json(v) => v.to_string(),
            PgValue::Array(items) => {
                let inner: Vec<String> = items
                    .iter()
                    .map(PgValue::as_array_element_literal)
                    .collect();
                format!("{{{}}}", inner.join(","))
            }
            PgValue::Enum(_, label) => label.clone(),
            PgValue::Raw(text) => text.clone(),
        }
    }

    pub fn is_null(&self) -> bool {
        matches!(self, PgValue::Null)
    }
}

mod json_as_string {
    use serde::{Deserialize, Deserializer, Serialize, Serializer};

    pub fn serialize<S: Serializer>(value: &serde_json::Value, s: S) -> Result<S::Ok, S::Error> {
        value.to_string().serialize(s)
    }

    pub fn deserialize<'de, D: Deserializer<'de>>(d: D) -> Result<serde_json::Value, D::Error> {
        let text = String::deserialize(d)?;
        serde_json::from_str(&text).map_err(serde::de::Error::custom)
    }
}

fn hex_encode(bytes: &[u8]) -> String {
    use std::fmt::Write;
    let mut s = String::with_capacity(bytes.len() * 2);
    for b in bytes {
        let _ = write!(s, "{b:02x}");
    }
    s
}

impl ToSql for PgValue {
    fn to_sql(
        &self,
        ty: &Type,
        out: &mut BytesMut,
    ) -> Result<IsNull, Box<dyn StdError + Sync + Send>> {
        match self {
            PgValue::Null => Ok(IsNull::Yes),
            PgValue::Bool(v) => v.to_sql(ty, out),
            PgValue::Int2(v) => v.to_sql(ty, out),
            PgValue::Int4(v) => v.to_sql(ty, out),
            PgValue::Int8(v) => v.to_sql(ty, out),
            PgValue::Numeric(v) => v.to_sql(ty, out),
            PgValue::Float4(v) => v.to_sql(ty, out),
            PgValue::Float8(v) => v.to_sql(ty, out),
            PgValue::Text(v) => v.as_str().to_sql(ty, out),
            PgValue::Bytea(v) => v.to_sql(ty, out),
            PgValue::Uuid(v) => v.to_sql(ty, out),
            PgValue::Timestamp(v) => v.to_sql(ty, out),
            PgValue::TimestampTz(v) => v.to_sql(ty, out),
            PgValue::Date(v) => v.to_sql(ty, out),
            PgValue::Json(v) => v.to_sql(ty, out),
            // Arrays, enums, and raw literals are always sent in text
            // format (see `encode_format`), so `to_sql` just writes the
            // literal's UTF-8 bytes verbatim.
            PgValue::Array(_) | PgValue::Enum(..) | PgValue::Raw(_) => {
                out.extend_from_slice(self.as_text_literal().as_bytes());
                Ok(IsNull::No)
            }
        }
    }

    fn accepts(_ty: &Type) -> bool
    where
        Self: Sized,
    {
        // PgValue is a universal carrier; the caller is responsible for
        // pairing the right variant with the right column, matching what
        // introspection reported for that column's type.
        true
    }

    fn encode_format(&self, _ty: &Type) -> postgres_types::Format {
        match self {
            PgValue::Array(_) | PgValue::Enum(..) | PgValue::Raw(_) => postgres_types::Format::Text,
            _ => postgres_types::Format::Binary,
        }
    }

    postgres_types::to_sql_checked!();
}

impl<'a> FromSql<'a> for PgValue {
    fn from_sql(ty: &Type, raw: &'a [u8]) -> Result<Self, Box<dyn StdError + Sync + Send>> {
        Ok(match *ty {
            Type::BOOL => PgValue::Bool(bool::from_sql(ty, raw)?),
            Type::INT2 => PgValue::Int2(i16::from_sql(ty, raw)?),
            Type::INT4 => PgValue::Int4(i32::from_sql(ty, raw)?),
            Type::INT8 => PgValue::Int8(i64::from_sql(ty, raw)?),
            Type::NUMERIC => PgValue::Numeric(Decimal::from_sql(ty, raw)?),
            Type::FLOAT4 => PgValue::Float4(f32::from_sql(ty, raw)?),
            Type::FLOAT8 => PgValue::Float8(f64::from_sql(ty, raw)?),
            Type::TEXT | Type::VARCHAR | Type::BPCHAR | Type::NAME => {
                PgValue::Text(String::from_sql(ty, raw)?)
            }
            Type::BYTEA => PgValue::Bytea(Vec::<u8>::from_sql(ty, raw)?),
            Type::UUID => PgValue::Uuid(Uuid::from_sql(ty, raw)?),
            Type::TIMESTAMP => PgValue::Timestamp(NaiveDateTime::from_sql(ty, raw)?),
            Type::TIMESTAMPTZ => PgValue::TimestampTz(DateTime::<Utc>::from_sql(ty, raw)?),
            Type::DATE => PgValue::Date(NaiveDate::from_sql(ty, raw)?),
            Type::JSON | Type::JSONB => PgValue::Json(serde_json::Value::from_sql(ty, raw)?),
            _ => match ty.kind() {
                // Enum wire format (text and binary) is just the label
                // bytes; safe to decode as UTF-8 regardless of requested
                // format.
                Kind::Enum(_) => PgValue::Enum(
                    ty.name().to_string(),
                    String::from_utf8_lossy(raw).into_owned(),
                ),
                // Best-effort fallback for domains/citext/other types whose
                // wire format happens to be UTF-8 text (true for citext and
                // text-based domains; NOT byte-correct for inet/cidr/range
                // binary encodings — those round-trip incorrectly today,
                // tracked as a known MVP limitation).
                _ => PgValue::Raw(String::from_utf8_lossy(raw).into_owned()),
            },
        })
    }

    fn from_sql_null(_ty: &Type) -> Result<Self, Box<dyn StdError + Sync + Send>> {
        Ok(PgValue::Null)
    }

    fn accepts(_ty: &Type) -> bool {
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn round_trip_binary<T: ToSql + for<'a> FromSql<'a> + PartialEq + std::fmt::Debug>(
        ty: &Type,
        value: T,
    ) {
        let mut buf = BytesMut::new();
        value.to_sql(ty, &mut buf).unwrap();
        let decoded = T::from_sql(ty, &buf).unwrap();
        assert_eq!(value, decoded);
    }

    #[test]
    fn bool_round_trips() {
        round_trip_binary(&Type::BOOL, PgValue::Bool(true));
        round_trip_binary(&Type::BOOL, PgValue::Bool(false));
    }

    #[test]
    fn integers_round_trip() {
        round_trip_binary(&Type::INT4, PgValue::Int4(-42));
        round_trip_binary(&Type::INT8, PgValue::Int8(9_000_000_000));
    }

    #[test]
    fn text_round_trips() {
        round_trip_binary(&Type::TEXT, PgValue::Text("hello, world".to_string()));
    }

    #[test]
    fn uuid_round_trips() {
        let u = Uuid::new_v4();
        round_trip_binary(&Type::UUID, PgValue::Uuid(u));
    }

    #[test]
    fn null_encodes_as_is_null() {
        let mut buf = BytesMut::new();
        let is_null = PgValue::Null.to_sql(&Type::INT4, &mut buf).unwrap();
        assert!(matches!(is_null, IsNull::Yes));
        assert!(buf.is_empty());
    }

    #[test]
    fn enum_round_trips_as_text() {
        let ty = Type::new(
            "mood".to_string(),
            0,
            Kind::Enum(vec![
                "sad".to_string(),
                "ok".to_string(),
                "happy".to_string(),
            ]),
            "public".to_string(),
        );
        let mut buf = BytesMut::new();
        let v = PgValue::Enum("mood".to_string(), "happy".to_string());
        v.to_sql(&ty, &mut buf).unwrap();
        assert_eq!(&buf[..], b"happy");
        let decoded = PgValue::from_sql(&ty, &buf).unwrap();
        assert_eq!(
            decoded,
            PgValue::Enum("mood".to_string(), "happy".to_string())
        );
    }

    #[test]
    fn array_literal_quotes_special_chars() {
        let v = PgValue::Array(vec![
            PgValue::Text("hello".to_string()),
            PgValue::Text("has,comma".to_string()),
            PgValue::Null,
        ]);
        assert_eq!(v.as_text_literal(), r#"{hello,"has,comma",NULL}"#);
    }

    #[test]
    fn raw_literal_passes_through() {
        let v = PgValue::Raw("192.168.1.0/24".to_string());
        assert_eq!(v.as_text_literal(), "192.168.1.0/24");
    }

    /// `snapshot.rs`'s file format bincode-serializes `PgValue` directly,
    /// so every variant must round-trip through it byte-exact, not just
    /// through the wire-format tests above. `Decimal` is the one variant
    /// with a documented gap here (its default serde repr doesn't survive
    /// bincode) — this is exactly what the `serde-str` feature fixes, and
    /// this test would fail without it.
    #[test]
    fn every_variant_round_trips_through_bincode() {
        let values = vec![
            PgValue::Null,
            PgValue::Bool(true),
            PgValue::Bool(false),
            PgValue::Int2(-7),
            PgValue::Int4(-42),
            PgValue::Int8(9_000_000_000),
            PgValue::Numeric(Decimal::new(123456, 3)),
            PgValue::Float4(1.5),
            PgValue::Float8(2.25),
            PgValue::Text("hello, world".to_string()),
            PgValue::Bytea(vec![0xDE, 0xAD, 0xBE, 0xEF]),
            PgValue::Uuid(Uuid::new_v4()),
            PgValue::Timestamp(
                NaiveDate::from_ymd_opt(2026, 8, 14)
                    .unwrap()
                    .and_hms_opt(1, 2, 3)
                    .unwrap(),
            ),
            PgValue::TimestampTz(DateTime::from_timestamp(1_723_000_000, 0).unwrap()),
            PgValue::Date(NaiveDate::from_ymd_opt(2026, 1, 1).unwrap()),
            PgValue::Json(serde_json::json!({"a": 1, "b": [true, null]})),
            PgValue::Array(vec![PgValue::Int4(1), PgValue::Null, PgValue::Int4(3)]),
            PgValue::Enum("mood".to_string(), "happy".to_string()),
            PgValue::Raw("192.168.1.0/24".to_string()),
        ];

        for v in values {
            let bytes = bincode::serialize(&v).unwrap_or_else(|e| {
                panic!("failed to serialize {v:?}: {e}");
            });
            let decoded: PgValue = bincode::deserialize(&bytes).unwrap_or_else(|e| {
                panic!("failed to deserialize {v:?}: {e}");
            });
            assert_eq!(v, decoded, "round trip changed the value");
        }
    }
}
