---
name: validate-rust
description: Run the Rust validation gate (fmt, build, clippy -D warnings, tests) on a crate or Cargo workspace and fix what it reports. Use when asked to validate Rust code.
---

# validate-rust

One script decides whether a Rust change is ready. It exists so "done" means the
same thing every time, instead of whichever subset of cargo commands felt
relevant in the moment.

## Running it

The script is `validate.sh`, next to this SKILL.md (normally
`~/.claude/skills/validate-rust/validate.sh`):

```bash
<skill-dir>/validate.sh fast   # default
<skill-dir>/validate.sh full
```

Run it from anywhere inside the repo; it `cd`s to the git root (or stays in the
current directory when there's no git repo).

- **fast**: fmt check → build (all targets) → clippy (`-D warnings`) →
  structure (function length ≤ 50 lines and nesting depth; production code
  only, tests are exempt) → unit tests (`--lib --bins`). Use after edits,
  while iterating.
- **full**: fast plus integration tests (the `tests/` targets) and the repo's
  `./.validate-extra.sh` if present. Use before a commit, before a PR, or when
  the user asks for a full check.

Per-repo hooks:
- An executable `./validate.sh` at the repo root replaces this script entirely
  (it's called with the tier). Trust it; that repo knows its own gate.
- An executable `./.validate-extra.sh` adds steps on the full tier only
  (hardware, swtpm, etc.).

Exit codes: `0` passed, `1` one or more steps failed (named on the last line),
`2` no `Cargo.toml` at the repo root — tell the user rather than improvising
some other check.

All cargo calls use `--locked`. If a step fails because `Cargo.lock` is missing
or out of date, report that; don't regenerate the lockfile without asking,
since that changes dependency versions.

## When it fails

Fix the cause and re-run until it passes, then report. Each failed step shows
the last 40 lines of its output; if that's not enough, rerun the single cargo
command directly to see everything.

- **fmt**: run `cargo fmt --all` and move on.
- **build / clippy**: fix the code. Don't silence lints with `#[allow(...)]`,
  `_`-prefixing used things, or loosening `RUSTFLAGS` — the point of
  `-D warnings` is that warnings are real. If a lint is genuinely wrong for
  this code, stop and ask, explaining why.
- **too_many_lines / excessive_nesting**: restructure. Extract named helper
  functions, and turn nested conditionals into early returns (`?`,
  `let ... else`, guard `if`s). Don't add or edit a `clippy.toml` to raise the
  thresholds. A repo's own `clippy.toml` replaces the shipped defaults, so that
  decision belongs to the repo owner, not to a fix.
- **tests**: work out whether the code or the test is wrong. Don't delete,
  `#[ignore]`, or weaken an assertion just to get green; if the test encodes
  behaviour the user intentionally changed, say so and confirm.
- **extra**: these usually need environment (devices, daemons). If it fails
  for environmental reasons, report it as such instead of trying to fix it.

If you've gone around a few times without progress, stop and show the user the
remaining failure rather than flailing.

## Reporting

End with the script's final line verbatim (`VALIDATION PASSED (fast)` or
`VALIDATION FAILED: clippy test`), plus a short note of what you fixed along
the way. Say which tier ran — "passes fast" is not "passes full".
