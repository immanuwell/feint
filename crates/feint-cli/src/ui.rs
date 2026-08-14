use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;

pub fn check(msg: impl std::fmt::Display) {
    println!("{} {msg}", "✓".green().bold());
}

pub fn warn(msg: impl std::fmt::Display) {
    println!("{} {msg}", "⚠".yellow().bold());
}

pub fn error(msg: impl std::fmt::Display) {
    eprintln!("{} {msg}", "✗".red().bold());
}

pub fn heading(msg: impl std::fmt::Display) {
    println!("{}", msg.to_string().bold());
}

pub fn spinner(msg: impl Into<String>) -> ProgressBar {
    let pb = ProgressBar::new_spinner();
    pb.set_style(
        ProgressStyle::with_template("{spinner:.cyan} {msg}")
            .unwrap()
            .tick_chars("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"),
    );
    pb.set_message(msg.into());
    pb.enable_steady_tick(std::time::Duration::from_millis(80));
    pb
}

pub fn table_bar(table: &str, total: u64) -> ProgressBar {
    let pb = ProgressBar::new(total);
    pb.set_style(
        ProgressStyle::with_template("{msg:<32} [{bar:30.cyan/blue}] {pos}/{len}")
            .unwrap()
            .progress_chars("█▓░"),
    );
    pb.set_message(table.to_string());
    pb
}

/// Comma-group a row count for display, e.g. `23410` -> `"23,410"`.
pub fn format_count(n: u64) -> String {
    let digits = n.to_string();
    let mut out = String::with_capacity(digits.len() + digits.len() / 3);
    for (i, c) in digits.chars().rev().enumerate() {
        if i > 0 && i % 3 == 0 {
            out.push(',');
        }
        out.push(c);
    }
    out.chars().rev().collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn formats_thousands_separators() {
        assert_eq!(format_count(0), "0");
        assert_eq!(format_count(42), "42");
        assert_eq!(format_count(999), "999");
        assert_eq!(format_count(1000), "1,000");
        assert_eq!(format_count(23_410), "23,410");
        assert_eq!(format_count(1_234_567), "1,234,567");
    }
}
