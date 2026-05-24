---
description: Strict review of the current diff or the project as-is, bucketed by language and dispatched to language subagents for context-isolated review. Aggregates findings with severity labels. Modes — default (diff), --all (whole project), bare path (subtree), --scope <name> (named scope from project CLAUDE.md).
allowed-tools: Read, Glob, Grep, Bash
---

# Review against project practices

## Purpose

Review code against the project's best-practice rules. Each language
is reviewed in an isolated subagent context so the orchestrator never
loads the full ruleset for any single language — only the aggregated
findings flow back.

Two modes:

- **Diff mode** (default) — review the changes in a diff. Use before
  committing or pushing.
- **Whole-project mode** (`--all` or a bare path) — review files
  as-is, regardless of git state. Use for audits, onboarding, or
  pre-refactor surveys.

Be strict. Don't rubber-stamp generated code. Prefer small, idiomatic,
maintainable changes over clever or broad rewrites.

## Input grammar

`$ARGUMENTS` is a space-separated list of tokens, in any order:

- `--all` — whole-project mode (`git ls-files`).
- `--scope <name>` — filter files to the paths defined by the named
  scope in the project `CLAUDE.md` `## Scopes` section.
- A bare path (file, directory, or glob that exists in the working
  tree) — ad-hoc scope filter equivalent to `--scope` but inline.
- A git ref, SHA, or range (`main`, `origin/main`, `<sha>`, `a..b`,
  `a...b`) — diff mode against that target. A bare ref expands to
  `<ref>..HEAD`. Default with no ref is `HEAD` (i.e. uncommitted +
  staged).
- `--last <N>` — diff mode covering the last N commits on HEAD,
  equivalent to `HEAD~<N>..HEAD`. Convenient shorthand when reviewing
  a stack of recent commits without naming a base ref.

Examples:

```
/review-practices                          # diff of uncommitted+staged, all paths
/review-practices main                     # diff main..HEAD, all paths
/review-practices --last 3                 # diff of the last 3 commits
/review-practices --last 5 --scope backend # last 5 commits, backend scope only
/review-practices HEAD~3..HEAD~1           # explicit range (commits ~3, ~2)
/review-practices <sha>                    # diff <sha>..HEAD
/review-practices --all                    # whole project, all paths
/review-practices --scope frontend         # diff, frontend scope only
/review-practices --all --scope backend    # whole project, backend scope only
/review-practices main --scope frontend    # branch diff, frontend scope only
/review-practices web/components/          # diff, scoped to web/components/
/review-practices --all web/components/    # whole project under web/components/
```

Rules:

- At most one scoping input: `--scope <name>` and a bare path are
  mutually exclusive. If both appear, error and ask which the user
  meant.
- `--all` toggles mode; it can combine with any scope input.
- `--last N` is mutually exclusive with `--all` and with an explicit
  git ref/range — they all specify the diff target. If more than one
  appears, error and ask which the user meant.
- A git ref + `--all` is contradictory — `--all` wins, ref is
  ignored (warn in Summary).
- Unknown flags or unrecognized non-path tokens: error with a usage
  hint, don't guess.

## Setup

### 1. Find the project root and read its CLAUDE.md

`git rev-parse --show-toplevel` for the root, then `Read` the
`CLAUDE.md` there. Capture:

- `## Stack` tags — used for the Summary and as fallback rubric.
- `## Scopes` definitions — used to resolve `--scope <name>`.

Expected `## Scopes` format (paths are repo-root-relative):

```
## Scopes
- frontend: web/, packages/ui/
- backend: server/, packages/api/
- shared: packages/common/
```

Parsing: each bullet is `<name>: <comma-separated-paths>`. Trailing
slashes mean directories (recursive). Globs are allowed
(`packages/*/src/`). If `--scope <name>` is used but the project
CLAUDE.md has no `## Scopes` section or the named scope isn't
defined, error and list the available scope names (or "none — add a
## Scopes section").

### 2. Discover files

Based on mode:

- **Diff mode**: `git status --short` for overview; collect the
  changed file list from `git diff --name-only <range>`. Range
  resolution: `--last N` → `HEAD~N..HEAD`; bare ref → `<ref>..HEAD`;
  explicit range passed through; default → `HEAD` (uncommitted +
  staged).
- **Whole-project mode** (`--all` or bare path without a ref):
  `git ls-files <scope-paths>` (or `git ls-files` if no scope).
  Respects `.gitignore` — vendored / generated files already
  excluded.

Then apply scoping filter (if any) by keeping only files whose path
matches a scope path or the bare-path argument.

Skip binary, generated, or vendored files line-by-line but note them
in Summary.

### 3. Check the file count before dispatching

After scoping, count files. If the total exceeds **50**, stop and
report:

```
Scoping produced N files across <buckets>:
  - rust: X files
  - react: Y files
  - general: Z files

This is a large review. Narrow with --scope <name>, a bare path, or
pass --confirm-large to proceed anyway.
```

Wait for the user to narrow or pass `--confirm-large`. Don't dispatch
without that confirmation.

If the total is ≤ 50, proceed silently.

### 4. Bucket files by language

Default extension mapping:

- `.rs` → `rust` subagent
- `.tsx`, `.ts`, `.jsx`, `.js` → `react` subagent
- Anything else → orchestrator-reviewed "general" bucket

Check the Agent tool's listed `subagent_type` values to confirm
which language subagents exist. If an expected subagent is missing,
fall back to in-orchestrator review using `general.md` plus the
relevant stack-tagged practices.

## Per-language dispatch

For each language bucket with a matching subagent, invoke the Agent
tool. Run independent buckets in parallel — they don't depend on
each other:

```
Agent(
  subagent_type="<language>",
  description="Review <N> <lang> files for practice violations",
  prompt="""
You are reviewing code for practice violations. Don't write code.

Mode: <diff | whole-project>
Diff range (if diff mode): <range>
Files in your scope:
  - path/to/file1.<ext>
  - path/to/file2.<ext>

For each file:
1. Read the working-tree version (and the diff if diff mode:
   `git diff <range> -- <path>`).
2. Flag violations of your loaded practices files at BLOCKING /
   IMPORTANT / NIT severity.
3. Cite file:line and the specific practice rule violated.

Run language-appropriate verification commands (typecheck, lint,
tests, build, or the cargo equivalents) and report their results.
Whole-project verification (e.g. `cargo check` on the whole crate)
runs once regardless of file count.

Return the structured summary your subagent definition specifies.
""",
)
```

For the orchestrator-reviewed "general" bucket: load `general.md` and
the matching fallback practices (per the project CLAUDE.md `## Stack`
section), then review those files directly using the same severity
scheme.

## Translating rules into review findings

Each subagent translates its practice rules into findings itself —
you (orchestrator) don't need to know the rules. For general-bucket
files you review directly, translate "rules to follow when writing"
into "things to flag in review":

- "Use theme tokens" → flag literal hex colors and raw pixel values.
- "Named imports only" → flag namespace imports.
- "No `any` without justification" → flag unjustified `any`.

Cite the practice file by name in each finding.

## Aggregate output

```
## Summary
One paragraph: mode (diff/whole-project), scope applied, total file
count and per-bucket breakdown, which subagents ran (and whether any
expected ones were missing), and the overall verdict — safe to
commit, or blocked, or audit summary in whole-project mode.

## Blocking Issues
- **BLOCKING** path/to/file.tsx:42 — <finding>. Cites: <practice file>.
  Why: <one sentence>. (from `react` subagent)

## Non-Blocking Issues
- **IMPORTANT** ...
- **NIT** ...

## Suggested Fixes
Concrete code snippets where useful.

## Verification
- `rust` subagent: cargo check / clippy / test — pass/fail/not run (reason)
- `react` subagent: typecheck / lint / test / build — pass/fail/not run
- General bucket: <commands run, or "none applicable">
- Not verified: <what couldn't be checked and why>
```

Severity labels:

- **BLOCKING** — correctness, accessibility regressions, data loss,
  runtime failure, broken tests, serious maintainability issue.
- **IMPORTANT** — should be fixed soon but may not block if risk is
  low.
- **NIT** — minor readability or style.

## Reviewer behavior

- Cite `file:line` for every finding.
- Each subagent uses its own practice files as the rubric — relay
  its findings verbatim with attribution ("from `<subagent>`
  subagent").
- Don't override or second-guess a subagent's findings unless they
  contradict another bucket's findings; if they do, surface the
  conflict in Summary.
- Distinguish confirmed issues from assumptions; mark assumptions.
- Say when something couldn't be verified.
- Prefer actionable fixes over vague criticism.

## Final commit gate (diff mode only)

In diff mode, before saying the code is ready to commit, confirm:

- No blocking issues remain across any bucket.
- Each subagent's verification ran (or inability is stated per
  subagent).
- General-bucket verification ran (or inability is stated).
- The change is limited to the requested scope.

If these can't be confirmed, don't say the code is ready. Say what
remains uncertain.

In whole-project mode there is no commit gate — the output is an
audit report, not a go/no-go signal.
