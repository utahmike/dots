## Best practices

At the start of any non-trivial task, read `~/.claude/practices/general.md`
in full and apply its guidance. This file is general principles and stays
in the orchestrator context.

### Language subagents — preferred path for code work

For any work that involves writing, modifying, or reviewing code in a
language with a matching custom subagent (listed in the Agent tool's
available `subagent_type` values, e.g. `rust`, `react`), delegate to
that subagent via the Agent tool. The subagent loads its
language-specific practices in its own context — don't load them in
the orchestrator.

Match by file extension or explicit language mention. Briefing the
subagent: include the spec or diff scope, the file paths in its
bucket, and whether you want implementation or review. The subagent's
final response is what you relay; don't second-guess its findings
unless they conflict across language boundaries.

Reserve in-orchestrator code work for: one-line edits where dispatch
overhead exceeds the work, languages without a configured subagent,
or cross-cutting coordination the subagents can't handle alone.

### Stack-tagged practices — fallback when no subagent exists

The project-level `CLAUDE.md` may declare its stack:

```
## Stack
- <tag>
- <tag>
```

For each tag **without** a matching subagent, read
`~/.claude/practices/<tag>.md` in full and apply its guidance to any
code you read or write in that language/platform. If a referenced
file doesn't exist, note it briefly and continue — don't invent
guidance from memory.

Stack tags are one per line. Composite tags (e.g. `react-mui`) are
allowed when the combination has practices specific to using the
technologies together; otherwise prefer single-technology tags so
guidance composes across stacks.

### Scopes — optional named path bundles

A project `CLAUDE.md` may also declare named scopes, which
`/review-practices --scope <name>` (and any other scope-aware
commands) use to filter files:

```
## Scopes
- frontend: web/, packages/ui/
- backend: server/, packages/api/
- shared: packages/common/
```

Each bullet is `<name>: <comma-separated paths>`, repo-root-relative,
trailing slash meaning directory (recursive). Globs are allowed
(`packages/*/src/`). Scopes are independent of language — a scope
can mix languages, and a language can appear in multiple scopes.
Define only the scopes that are useful for review and dispatch in
this project; small repos don't need any.

## Issue system abstraction

When I say "the issue system" (or "file an issue", "open a ticket", "log a bug",
etc.), use the issue tracker configured for the current repository. Do not
assume Linear, Beads, GitLab, or GitHub — look at the project-level `CLAUDE.md`
for an `## Issue System` section that names the tracker type and any
repo-specific parameters (team, project, labels, etc.).

If the project CLAUDE.md has no `## Issue System` section, ask before creating
or modifying issues — don't guess.

Dispatch is handled by the `issue-system` skill. After identifying the tracker
type from the repo CLAUDE.md, read
`~/.claude/skills/issue-system/adapters/<type>.md` in full and follow its
recipe verbatim. Do not improvise tracker-specific tool names or CLI flags
from memory.
