//! `COPY ... FROM STDIN` bulk loading — the volume path `clone`, `restore`,
//! and (for tables nothing references) `up` use instead of chunked,
//! parameterized `INSERT` statements.
//!
//! `execute_batched_insert` (`insert.rs`) is correct and stays the path
//! for anything that needs `RETURNING` or `OVERRIDING SYSTEM VALUE`, but
//! it pays two real costs at real volume: every batch is its own
//! statement (parsed and planned by Postgres separately, capped at
//! whatever fits under the bind-parameter limit, a few hundred rows at a
//! time for a typical table), and the SQL text itself grows with the
//! batch. `COPY` has neither limit — one stream, no per-row statement
//! overhead, no bind-parameter ceiling — and is the standard way any
//! Postgres tool moves a real volume of rows.
//!
//! Uses `FORMAT text`, not `binary`: it reuses [`PgValue::as_text_literal`]
//! (already implemented and tested for every variant, including arrays,
//! enums, and the citext/inet/domain fallback) with one additional
//! escaping pass for COPY's own delimiter/escape rules, rather than
//! hand-rolling a second, binary-specific encoding per type.

use bytes::Bytes;
use futures_util::SinkExt;
use tokio_postgres::Transaction;

use crate::error::Result;
use crate::introspect::{Column, Table};
use crate::value::PgValue;

/// Rows per `Sink::send` call. Keeps peak buffered payload size bounded
/// without attempting full constant-memory streaming — `rows` is already
/// fully materialized in memory by every caller today, so this only
/// smooths the network write, it doesn't change the overall memory
/// profile of a run.
const FLUSH_ROWS: usize = 5_000;

/// COPY's text-format escaping: backslash, tab, newline, and carriage
/// return each get backslash-escaped; everything else (including
/// multi-byte UTF-8) passes through unchanged. This applies uniformly on
/// top of whatever [`PgValue::as_text_literal`] produced, regardless of
/// the value's actual type — an array literal's `{}/,/"` stay untouched
/// (COPY doesn't treat them specially), and a `bytea` value's `\x...`
/// hex-format backslash gets doubled correctly by the same pass that
/// handles every other backslash.
fn escape_copy_field(text: &str, out: &mut String) {
    for ch in text.chars() {
        match ch {
            '\\' => out.push_str("\\\\"),
            '\t' => out.push_str("\\t"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            _ => out.push(ch),
        }
    }
}

fn encode_copy_row(row: &[PgValue], out: &mut String) {
    for (i, value) in row.iter().enumerate() {
        if i > 0 {
            out.push('\t');
        }
        if value.is_null() {
            out.push_str("\\N");
        } else {
            escape_copy_field(&value.as_text_literal(), out);
        }
    }
    out.push('\n');
}

/// Loads `rows` into `table` via `COPY ... FROM STDIN`. A zero-column row
/// (every column is server-assigned) cannot be represented by COPY, so that
/// rare case falls back to `INSERT ... DEFAULT VALUES`. Never uses
/// `RETURNING` or `OVERRIDING SYSTEM VALUE` — callers that need either
/// (GENERATE mode on a table something else references; CLONE/restore on a
/// table with a `GENERATED ALWAYS AS IDENTITY` column) must use
/// `insert::execute_batched_insert` instead. `columns` must already exclude
/// any column that shouldn't be written (stored-generated, server-assigned
/// where the caller wants Postgres to assign it), same contract as
/// `execute_batched_insert`.
pub(crate) async fn copy_rows(
    txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    rows: &[Vec<PgValue>],
) -> Result<u64> {
    if rows.is_empty() {
        return Ok(0);
    }
    if columns.is_empty() {
        // COPY cannot express a row made entirely of defaults. Fall back
        // to `INSERT ... DEFAULT VALUES` so an unreferenced table whose
        // every column is server-assigned still receives its planned rows.
        crate::insert::execute_batched_insert(txn, table, columns, rows, &[], false).await?;
        return Ok(rows.len() as u64);
    }

    let col_list = columns
        .iter()
        .map(|c| format!("\"{}\"", c.name))
        .collect::<Vec<_>>()
        .join(", ");
    let sql = format!(
        "COPY \"{}\".\"{}\" ({col_list}) FROM STDIN WITH (FORMAT text)",
        table.id.schema, table.id.name
    );

    let sink = txn.copy_in::<_, Bytes>(&sql).await?;
    let mut sink = Box::pin(sink);

    let mut buf = String::new();
    for (i, row) in rows.iter().enumerate() {
        encode_copy_row(row, &mut buf);
        if (i + 1) % FLUSH_ROWS == 0 {
            sink.as_mut()
                .send(Bytes::from(std::mem::take(&mut buf).into_bytes()))
                .await?;
        }
    }
    if !buf.is_empty() {
        sink.as_mut().send(Bytes::from(buf.into_bytes())).await?;
    }

    let count = sink.as_mut().finish().await?;
    Ok(count)
}

/// The dispatch every RETURNING-free bulk load (`clone`, `restore`) makes:
/// `COPY` unless `overriding_system_value` is set, since `COPY` has no
/// equivalent of `INSERT ... OVERRIDING SYSTEM VALUE` — a table with a
/// `GENERATED ALWAYS AS IDENTITY` column whose real value CLONE mode
/// needs to preserve falls back to the existing chunked `INSERT` path,
/// unchanged. Every other table takes the `COPY` path.
pub(crate) async fn bulk_insert_no_returning(
    txn: &Transaction<'_>,
    table: &Table,
    columns: &[&Column],
    rows: &[Vec<PgValue>],
    overriding_system_value: bool,
) -> Result<()> {
    if overriding_system_value {
        crate::insert::execute_batched_insert(txn, table, columns, rows, &[], true).await?;
    } else {
        copy_rows(txn, table, columns, rows).await?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn row_text(row: &[PgValue]) -> String {
        let mut out = String::new();
        encode_copy_row(row, &mut out);
        out
    }

    #[test]
    fn null_encodes_as_backslash_n() {
        assert_eq!(row_text(&[PgValue::Null]), "\\N\n");
    }

    #[test]
    fn plain_values_are_tab_separated() {
        assert_eq!(
            row_text(&[PgValue::Int4(42), PgValue::Text("hello".to_string())]),
            "42\thello\n"
        );
    }

    #[test]
    fn backslash_tab_newline_and_cr_are_escaped() {
        let v = PgValue::Text("a\\b\tc\nd\re".to_string());
        assert_eq!(row_text(&[v]), "a\\\\b\\tc\\nd\\re\n");
    }

    #[test]
    fn bytea_hex_prefix_backslash_is_doubled() {
        let v = PgValue::Bytea(vec![0xDE, 0xAD]);
        assert_eq!(v.as_text_literal(), "\\xdead");
        assert_eq!(row_text(&[v]), "\\\\xdead\n");
    }

    #[test]
    fn array_literal_braces_pass_through_unescaped() {
        let v = PgValue::Array(vec![PgValue::Int4(1), PgValue::Null, PgValue::Int4(3)]);
        assert_eq!(row_text(&[v]), "{1,NULL,3}\n");
    }

    #[test]
    fn json_own_escaping_is_re_escaped_correctly_for_copy() {
        // serde_json already escapes a newline inside a JSON string as the
        // two-character sequence `\n` (backslash + n), never a raw
        // newline byte — that backslash is exactly what COPY's own
        // escaping must double, the same as any other backslash.
        let v = PgValue::Json(serde_json::json!({"note": "line1\nline2"}));
        let json_text = v.as_text_literal();
        assert!(
            json_text.contains("line1\\nline2"),
            "sanity check: JSON's own serialization escapes the newline: {json_text:?}"
        );

        let text = row_text(&[v]);
        assert_eq!(
            text.matches('\n').count(),
            1,
            "only the row terminator may be a literal newline byte: {text:?}"
        );
        assert!(
            text.contains("line1\\\\nline2"),
            "the JSON's own backslash must be re-escaped for COPY: {text:?}"
        );
    }

    #[test]
    fn multiple_columns_and_a_trailing_newline() {
        let rows = [
            vec![PgValue::Int4(1), PgValue::Null],
            vec![PgValue::Int4(2), PgValue::Text("x".to_string())],
        ];
        let mut out = String::new();
        for row in &rows {
            encode_copy_row(row, &mut out);
        }
        assert_eq!(out, "1\t\\N\n2\tx\n");
    }
}
