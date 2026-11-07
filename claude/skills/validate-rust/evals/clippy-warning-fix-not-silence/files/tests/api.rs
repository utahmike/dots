#[test]
fn public_api() {
    assert_eq!(stats::sum_evens(&vec![10, 11]), 10);
}
