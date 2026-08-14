//! Best-effort migration from other tools' configs to `feint.yaml`.
//!
//! Neither source tool has a format that maps onto feint 1:1. Snaplet
//! Seed's real config is TypeScript, and its per-column generators are
//! arbitrary JS closures, not data. Neosync has no static config file at
//! all — jobs live in its own backend, configured through its UI/API.
//! Both migrators are deliberately honest about this: they convert what
//! can be converted mechanically and report, precisely, what they
//! couldn't, rather than pretending to a completeness they don't have.

pub mod neosync;
pub mod snaplet;

/// How confidently a source tool's column-level transform was converted.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConversionConfidence {
    /// A direct, faithful equivalent exists in feint.
    Exact,
    /// The closest available feint strategy, but not a perfect match —
    /// see the accompanying note for what's different.
    Approximate,
}

#[derive(Debug, Clone)]
pub struct ConvertedColumn {
    pub table: String,
    pub column: String,
    pub confidence: ConversionConfidence,
    pub note: Option<String>,
}

#[derive(Debug, Clone)]
pub struct SkippedColumn {
    pub table: String,
    pub column: String,
    pub reason: String,
}

#[derive(Debug, Clone, Default)]
pub struct MigrationReport {
    pub converted: Vec<ConvertedColumn>,
    pub skipped: Vec<SkippedColumn>,
    /// Notes not tied to one specific column — e.g. a glob table selector
    /// that needs a live schema to resolve, or "no mappings found".
    pub general_notes: Vec<String>,
}
