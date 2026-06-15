# Gitea adapter

Use the Gitea REST API via `curl` (+ `python3`/`yq` for JSON) through the Bash tool.
Auth is a personal access token at `~/.gitea-token`, sent as the header
`Authorization: token <token>`. Never echo the token into output.

(If `~/.gitea-token` is missing: create one in Gitea → Settings → Applications →
"Generate New Token" with the `repository` (issues) scope, and save it there.)

## Required repo CLAUDE.md parameters

```
## Issue System
type: gitea
host: https://git.example.org     # Gitea base URL (API is <host>/api/v1)
owner: <user-or-org>              # e.g. mjc
repo: <repo>                      # e.g. aspengrove
```

Conventions a repo may add — honor them over defaults:
- **app labels**: in a monorepo, tag app-specific issues with a scoped, exclusive
  `app/<name>` label (e.g. `app/watches`) so they stay filterable per app.

## Setup (run once per shell)

```bash
TOK="Authorization: token $(cat ~/.gitea-token)"
API="https://git.example.org/api/v1"   # from `host`
OWNER=mjc; REPO=aspengrove              # from `owner` / `repo`
```

Examples use `curl -s`. If the host's TLS cert doesn't validate for you, add `-k`
(only then — prefer validating).

## Labels: resolve names → IDs first

Gitea's **create-issue** API takes label **IDs**, not names. List them:

```bash
curl -s -H "$TOK" "$API/repos/$OWNER/$REPO/labels?limit=100" \
  | yq -p json '.[] | (.id|tostring) + "  " + .name'
```

Create a missing label (scoped/exclusive example):

```bash
curl -s -X POST -H "$TOK" -H 'Content-Type: application/json' \
  "$API/repos/$OWNER/$REPO/labels" \
  -d '{"name":"app/watches","color":"#1f6feb","description":"watches app","exclusive":true}'
```

## Operations

### search  (always run before create — deduplicate)

```bash
curl -s -H "$TOK" \
  "$API/repos/$OWNER/$REPO/issues?type=issues&state=all&q=<keywords>&limit=50" \
  | yq -p json '.[] | (.number|tostring) + ": [" + .state + "] " + .title'
```

`type=issues` excludes pull requests (Gitea returns both otherwise). Add
`&labels=<name>` to filter by label. Surface matches so the caller can comment/update
instead of duplicating.

### create

Build the JSON with a tool so the markdown body is escaped correctly — do **not**
hand-assemble JSON in the shell. `labels` is an array of label **IDs** (resolve first).

```bash
cat > /tmp/body.md <<'EOF'
<markdown body>
EOF
python3 -c 'import json;print(json.dumps({"title":"<title>","body":open("/tmp/body.md").read(),"labels":[<id>]}))' > /tmp/issue.json
curl -s -X POST -H "$TOK" -H 'Content-Type: application/json' \
  --data @/tmp/issue.json "$API/repos/$OWNER/$REPO/issues" \
  | yq -p json '{"number": .number, "url": .html_url}'
rm -f /tmp/body.md /tmp/issue.json
```

Always include in the body:
- affected files (`path/to/file.ext:line`)
- reproduction steps or evidence
- suggested fix / next step

Return the issue `number` + `html_url` to the caller.

### update

Patch only the fields you're changing (`title`, `body`, `state`, `labels`). `labels`
**replaces** the full set (IDs). Close with `state: "closed"`, reopen with `"open"`:

```bash
curl -s -X PATCH -H "$TOK" -H 'Content-Type: application/json' \
  "$API/repos/$OWNER/$REPO/issues/<number>" -d '{"state":"closed"}'
```

To add/remove labels without replacing the set, use the label sub-resource:
`POST` (add) / `DELETE` `$API/repos/$OWNER/$REPO/issues/<number>/labels`.

### comment

```bash
python3 -c 'import json,sys;print(json.dumps({"body":sys.argv[1]}))' "<markdown>" \
  | curl -s -X POST -H "$TOK" -H 'Content-Type: application/json' \
      --data @- "$API/repos/$OWNER/$REPO/issues/<number>/comments" >/dev/null
```

### show

```bash
curl -s -H "$TOK" "$API/repos/$OWNER/$REPO/issues/<number>" \
  | yq -p json '{"number": .number, "title": .title, "state": .state, "labels": [.labels[].name], "body": .body}'
curl -s -H "$TOK" "$API/repos/$OWNER/$REPO/issues/<number>/comments" \
  | yq -p json '.[] | .user.login + ": " + .body'
```

(Note: `yq` here is mikefarah/yq (Go) — construct objects with explicit `"key": .value`
pairs; the jq-style `{number, title}` shorthand is not supported.)

## Notes

- The path segment after `/issues/` is the per-repo issue **number** (`index`), e.g.
  `/issues/1`.
- `#N` references in commits/PRs auto-link; `fixes #N` / `closes #N` auto-closes the issue
  when the PR merges to the default branch.
- Gitea has no built-in priority sort; if the repo uses scoped labels for it
  (`priority/P0..P4`, `type/{bug,task,feature}`), apply them as labels.
