pub fn total(xs: &[u32]) -> u32 {
    xs.iter().sum()
}

#[cfg(test)]
mod tests {
    #[test]
    fn totals() {
        assert_eq!(super::total(&[1, 2]), 3);
    }
}
