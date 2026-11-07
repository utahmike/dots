pub fn greet(name: &str) -> String {
    format!("hello, {name}")
}

#[cfg(test)]
mod tests {
    #[test]
    fn greets() {
        assert_eq!(super::greet("ada"), "hello, ada");
    }
}
