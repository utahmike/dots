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
  considering a change done. Treat clippy warnings as errors unless
  explicitly silenced with `#[allow(...)]` + a reason comment.
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
