# Global Instructions

- Default to clear, maintainable code with inline comments for non-trivial logic.
- Use functional composition when practical; avoid deeply nested loops.
- Always suggest type-safe solutions and avoid deprecated APIs.
- Keep security in mind: no hard-coded secrets, sanitize all inputs, validate output.
- Suggest test coverage for critical code paths.
- Follow naming conventions: `snake_case` for functions/variables, `PascalCase` for types/classes.
- Prefer standard library solutions before external dependencies.

# Commands

- Run tests: `cargo test --all -- --nocapture`
- Lint: `cargo clippy -- -D warnings`
- Format: `cargo fmt`

# Personal Preferences

- Rust > Python > Bash for automation scripts.
- Use `serde_yml` instead of `serde_yaml` for YAML serialization.
- If making diagrams, prefer Mermaid syntax unless otherwise specified.
