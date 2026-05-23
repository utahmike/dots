# GitLab adapter

Use the `glab` CLI via the Bash tool. Assumes `glab` is authenticated for the
target project (`glab auth status` should show a token).

## Required repo CLAUDE.md parameters

```
## Issue System
Type: gitlab
Project: <group/repo>
Labels: <comma-separated default labels, optional>
```

The `Project` value is passed to `glab -R <group/repo> issue ...`. If omitted,
`glab` infers it from the current git remote.

## Severity mapping (default — override per repo if needed)

GitLab uses labels for severity. Default mapping:

- P0 / critical → `severity::1`
- P1 / high → `severity::2`
- P2 / medium → `severity::3`
- P3 / low / cleanup / docs → `severity::4`

## Operations

### search

```bash
glab -R <group/repo> issue list --search "<query>" --state opened
```

Show candidate IDs + titles for duplicate review before creating.

### create

```bash
glab -R <group/repo> issue create \
  --title "<title>" \
  --description "<markdown body>" \
  --label "<comma-separated labels>"
```

Always include in the description:
- affected files (`path/to/file.ext:line`)
- reproduction steps or evidence
- suggested fix / next step

Capture the issue URL/IID from stdout and return it to the caller.

### update

```bash
glab -R <group/repo> issue update <iid> \
  --title "<new title>" \
  --description "<new body>" \
  --label "<labels>"
```

Only pass the flags for fields you're actually changing.

### comment

```bash
glab -R <group/repo> issue note <iid> --message "<markdown comment>"
```

### show

```bash
glab -R <group/repo> issue view <iid> --comments
```
