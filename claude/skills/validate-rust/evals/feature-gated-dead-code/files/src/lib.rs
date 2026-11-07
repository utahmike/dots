pub struct Counter {
    n: u64,
}

impl Counter {
    pub fn new() -> Self {
        Counter { n: 0 }
    }

    pub fn bump(&mut self) -> u64 {
        self.n += 1;
        #[cfg(feature = "metrics")]
        eprintln!("{}", format_metric("counter", self.n));
        self.n
    }
}

impl Default for Counter {
    fn default() -> Self {
        Self::new()
    }
}

fn format_metric(name: &str, v: u64) -> String {
    format!("{name}={v}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bumps() {
        let mut c = Counter::new();
        assert_eq!(c.bump(), 1);
        assert_eq!(c.bump(), 2);
    }
}
