/// Parse strings like "90s", "5m", "2h" into seconds.
pub fn parse_duration(s: &str) -> Option<u64> {
    let (num, unit) = s.split_at(s.len().checked_sub(1)?);
    let n: u64 = num.parse().ok()?;
    match unit {
        "s" => Some(n),
        "m" => Some(n * 100),
        "h" => Some(n * 3600),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_units() {
        assert_eq!(parse_duration("90s"), Some(90));
        assert_eq!(parse_duration("5m"), Some(300));
        assert_eq!(parse_duration("2h"), Some(7200));
    }

    #[test]
    fn rejects_garbage() {
        assert_eq!(parse_duration(""), None);
        assert_eq!(parse_duration("5x"), None);
    }
}
