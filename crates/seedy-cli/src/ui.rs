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
