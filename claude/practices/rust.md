# Rust best practices

Apply these when reading, writing, or reviewing Rust code.

## Error handling

- Use `?` to propagate errors. Reserve `unwrap()` / `expect()` for tests, `main`,
  or invariants you can prove locally — and prefer `expect("reason")` over
  bare `unwrap()` so the failure message names the violated invariant.
- Library crates: define typed errors with `thiserror`. Application crates:
  use `anyhow::Result` with `.context("...")` to attach call-site detail.
- Don't swallow errors with `let _ = ...` unless you've thought about why
  silence is correct; leave a comment if you do.
- `Result<T, E>` over `Option<T>` whenever the failure has a *reason* worth
  conveying. `Option` is for genuinely-absent values, not for errors.

## Function structure

- **Functions are at most 50 lines** (blank and comment lines don't count).
  When one grows past that, extract named helpers rather than compressing
  the code. *Enforced by validate-rust:* `clippy::too_many_lines`.
- **Bail out early instead of nesting.** Handle the error, empty, or
  not-applicable case first and return, using `?`, `let ... else { return/continue }`,
  and guard `if`s, so the main path runs at the top indentation level. Two
  nested blocks inside a function body are the limit. *Enforced by
  validate-rust:* `clippy::excessive_nesting` (threshold 3).
- **Write pure functions wherever possible.** Logic takes its inputs as
  arguments and returns its result; it doesn't read clocks, environment,
  files, network, or randomness, and it doesn't mutate shared state. That
  makes it testable without setup. *Not enforced by a tool; checked in review.*
- **Test every output the types allow.** For functions that return or match
  on a sum type (`enum`, `Result`, `Option`), write a unit test for each
  variant the function can produce, and for each input variant it branches
  on. Table-driven tests keep this compact. *Not enforced by a tool; checked
  in review.*
- **Put side effects behind traits.** I/O, time, randomness, and process or
  environment access go through a trait (`trait Clock`, `trait Store`, ...)
  that the pure core takes as a parameter or generic. Production code passes
  the real implementation; tests pass a fake. Where it fits, describe effects
  as data (an "action" enum the core returns and a thin shell executes)
  instead of performing them. *Not enforced by a tool; checked in review.*

## Ownership & borrowing

- Prefer borrows in function parameters: `&str` over `String`, `&[T]` over
  `Vec<T>`, `&Path` over `PathBuf`. Take ownership only when the function
  needs to keep or transform the value.
- Avoid `.clone()` to silence the borrow checker — first try restructuring so
  the borrow fits. `Arc<T>` / `Rc<T>` only when shared ownership is genuinely
  needed.
- Use `Cow<'_, str>` for conditional ownership (e.g., returning either a
  borrowed slice or an owned modification).

## API design

- Newtype pattern (`struct UserId(u64);`) for IDs and other domain-meaningful
  primitives — prevents mixing them up at compile time.
- Builder pattern for structs with many optional fields. For small structs,
  prefer plain `Default` + struct-update syntax.
- Return `impl Trait` for opaque return types when callers don't need the
  concrete type; return concrete types when they do.
- Make invalid states unrepresentable: enums over booleans-plus-comments,
  non-empty types over `Vec<T>` with runtime assertions.

## Concurrency & async

- Default to message passing (`tokio::sync::mpsc`, `crossbeam_channel`) over
  shared state. Reach for `Arc<Mutex<T>>` only when you've ruled out
  channel-based designs.
- In async code: never call blocking I/O directly. Use `tokio::fs`,
  `tokio::process`, `reqwest`, etc. For unavoidable blocking work, wrap with
  `tokio::task::spawn_blocking`.
- Don't hold a `MutexGuard` across `.await` — it's a deadlock waiting to
  happen, and clippy will catch it (`await_holding_lock`).
- Pick one async runtime per binary (usually Tokio) and don't mix.

## Cargo & tooling

- Run `cargo fmt`, `cargo clippy --all-targets`, and `cargo test` before
  considering a change done. Treat clippy warnings as errors and fix the
  code. If a lint is genuinely wrong for a piece of code, raise it with the
  user instead of silencing it; an agreed exception uses
  `#[expect(lint, reason = "...")]`, which warns once it's no longer needed,
  rather than `#[allow(...)]`.
- `cargo check` for fast feedback during iteration; `cargo build` only when
  you actually need the binary.
- Pin patch versions for binaries (`= "1.2.3"`); allow caret ranges for
  libraries. Don't commit `Cargo.lock` for libraries; do commit it for
  binaries.
- Workspaces for multi-crate projects with shared `[workspace.dependencies]`
  to keep versions aligned.

## Testing

- Unit tests in a `#[cfg(test)] mod tests { ... }` block at the bottom of the
  module they cover. Integration tests in `tests/`.
- Use `assert_eq!` / `assert_ne!` for value checks (the diff on failure is
  useful); `assert!` for boolean predicates.
- Prefer table-driven tests over many near-duplicate functions when checking
  multiple inputs.
- `#[should_panic]` is rarely the right tool — assert on the `Result`'s `Err`
  variant instead.

## Unsafe

- Every `unsafe` block needs a `// SAFETY: ...` comment explaining the
  invariants that make it sound. No exceptions.
- Push `unsafe` to the smallest possible scope; wrap it in a safe abstraction
  with a documented contract.

## Documentation

- `///` doc comments on every public item. Include `# Examples` doctests for
  non-trivial APIs — they double as tests.
- Use `# Errors` and `# Panics` sections to document failure modes on public
  functions that return `Result` or can panic.
