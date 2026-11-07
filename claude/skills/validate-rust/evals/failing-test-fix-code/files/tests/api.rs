#[test]
fn hours() {
    assert_eq!(durations::parse_duration("1h"), Some(3600));
}
