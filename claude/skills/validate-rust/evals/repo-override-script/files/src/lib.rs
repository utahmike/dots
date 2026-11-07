/// Lower-case greeting.
pub fn whisper(s: &str) -> String {
    s.to_lowercase()
}

/// Upper-case greeting.
pub fn shout(s: &str) -> String {
    s.to_uppercase()
}

#[cfg(test)]
mod tests {
    #[test]
    fn shouts() {
        assert_eq!(super::shout("hi"), "HI");
    }
}
