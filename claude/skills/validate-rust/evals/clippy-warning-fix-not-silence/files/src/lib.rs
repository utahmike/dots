/// Sum of the even numbers in `xs`.
pub fn sum_evens(xs: &Vec<i64>) -> i64 {
    let mut total = 0;
    for i in 0..xs.len() {
        if xs[i] % 2 == 0 {
            total = total + xs[i];
        }
    }
    return total;
}

/// True when `xs` has nothing in it.
pub fn is_blank(xs: &[i64]) -> bool {
    let count = xs.len();
    xs.len() == 0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sums_only_evens() {
        assert_eq!(sum_evens(&vec![1, 2, 3, 4]), 6);
    }

    #[test]
    fn blank_detects_empty() {
        assert!(is_blank(&[]));
        assert!(!is_blank(&[1]));
    }
}
