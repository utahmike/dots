# Beads adapter

Beads is a CLI-driven issue tracker; all operations go through the `bd`
binary. Shell out via the Bash tool. Add `--json` to any read command for
machine-parseable output.

## Required repo CLAUDE.md parameters

```
## Issue System
Type: beads
Labels: <comma-separated default labels, optional>
Default type: <bug | feature | task | epic | chore | decision> (optional, default: task)
```

Beads stores its database inside the repo (`.beads/*.db`), so no project or
team identifier is needed.

## Defer to bd's own workflow context

If the repo has `bd hooks install` set up, `bd prime` output is already in the
session context — read it before improvising. Otherwise run `bd prime`
manually once at the start of issue work to pick up the project's actual
workflow conventions (label vocabulary, type usage, dedup policy).

## Severity mapping (native priority — override per repo if needed)

Beads has a real priority field (0–4, lower = higher priority). Map severity
directly, no labels needed:

- P0 / critical / security / outage / data-loss → `--priority 0`
- P1 / high / major-bug → `--priority 1`
- P2 / medium / normal → `--priority 2` (default)
- P3 / low / polish → `--priority 3`
- cleanup / docs / backlog → `--priority 4`

## Operations

### search

```bash
bd search "<query>" --json
```

Useful filters:
- `--status open|in_progress|blocked|deferred|closed|all` (default excludes closed)
- `--label foo` (AND across multiple `--label`) or `--label-any foo,bar` (OR)
- `--desc-contains "<text>"` to also search descriptions (titles-only otherwise)
- `--priority-min 0 --priority-max 1` for critical/high only
- `--limit N` (default 50)

For semantic dedup (recommended before any `create`):

```bash
bd find-duplicates --method ai --threshold 0.5 --json
```

If `ANTHROPIC_API_KEY` isn't set, fall back to the default mechanical mode
(`--method mechanical`, also the default if `--method` is omitted).

### create

For short bodies, pass `--description` directly:

```bash
bd create "<title>" \
  --type bug \
  --priority 1 \
  --labels "ai-found,backend" \
  --description "<short markdown body>" \
  --silent
```

For multi-line / markdown-heavy bodies (the common case for review issues),
pipe via stdin to avoid shell quoting issues:

```bash
bd create "<title>" \
  --type bug \
  --priority 1 \
  --labels "ai-found,backend" \
  --stdin \
  --silent <<'EOF'
## Affected
- path/to/file.ext:42
- path/to/other.ext:108

## Evidence
<reproduction or code excerpt>

## Suggested fix
<one paragraph>
EOF
```

`--silent` makes `bd create` print only the new issue ID — capture it for the
caller. Other useful flags:
- `--external-ref "<system>-<id>"` to link to an upstream tracker entry
- `--parent bd-N` to file under an existing epic
- `--deps "blocks:bd-15,discovered-from:bd-20"` for dependency wiring
- `--dry-run` to preview without writing

Always include in the body:
- affected files (`path/to/file.ext:line`)
- reproduction steps or evidence
- suggested fix or next step

### update

```bash
bd update <id> \
  --title "<new title>" \
  --description "<new body>" \
  --priority 1 \
  --status in_progress \
  --add-label new-label \
  --remove-label old-label
```

Only pass the flags for fields you're actually changing. For label work prefer
`--add-label` / `--remove-label` over `--set-labels` (the latter replaces
everything). Use `--append-notes` to add to existing notes without overwriting.

For just changing priority, the shorthand is:

```bash
bd priority <id> <0-4>
```

### comment

```bash
bd comment <id> "<short comment>"
```

For long comments, use stdin:

```bash
bd comment <id> --stdin <<'EOF'
<multi-line markdown>
EOF
```

### show

```bash
bd show <id> --json
```

Useful flags:
- `--long` for all metadata (gates, agent identity, etc.)
- `--children` to list child issues only
- `--refs` for reverse lookup (issues that reference this one)
- `--thread` for the full comment conversation

## Notes

- The `bd q "<title>"` (quick capture) command creates an issue and prints
  only the ID — useful for one-liners but skips fields like priority, type,
  labels. Prefer `bd create ... --silent` for anything non-trivial.
- Beads has native dependency wiring (`bd link`, `bd dep`, `bd blocked`).
  If the repo's workflow uses dependency chains, surface them when filing
  related issues (e.g., a fix issue that `blocks` the originating bug).
- Beads' default agent-instructions convention is `AGENTS.md` (per
  `bd onboard`), not `CLAUDE.md`. For repos that already follow that pattern,
  the `## Issue System` block can equally live in `AGENTS.md` — the dispatch
  works the same way.
