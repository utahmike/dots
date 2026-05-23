---
name: issue-system
description: Create, update, and search issues in the repository's configured issue tracker. Reads the project CLAUDE.md to determine which adapter to use (Linear, Beads, GitLab, etc.) and follows that adapter's recipe verbatim.
---

# Issue system dispatcher

This skill is a thin dispatcher. The real per-tracker recipes live in
`adapters/<type>.md` next to this file. Your job is to identify the tracker
type from the active repository's `CLAUDE.md` and then follow the matching
adapter file.

## Step 1 — Read the repo configuration

Look in the project's `CLAUDE.md` (the one in the repo root, not the
user-level one) for a section like:

```
## Issue System
Type: <linear | beads | gitlab>
... (other parameters specific to the tracker)
```

If no such section exists, stop and tell the user — do not guess at a
tracker. Suggest they add an `## Issue System` section to the repo CLAUDE.md.

## Step 2 — Read the adapter in full

Once you know the `Type`, open
`~/.claude/skills/issue-system/adapters/<type>.md` and read it end-to-end
**before doing anything**. Do not paraphrase from memory — the adapter is the
source of truth for exact tool names, CLI flags, and required fields.

## Step 3 — Follow the adapter

Each adapter defines the same conceptual operations (`search`, `create`,
`update`, `comment`, `show`) but with tracker-specific commands. The repo
CLAUDE.md may override parameters (default labels, project/team IDs, severity
mapping) — honor those overrides over any defaults baked into the adapter.

## Step 4 — Always deduplicate before creating

Run the adapter's `search` step first. If a clearly matching issue exists,
either comment on it or surface it to the user rather than creating a
duplicate.

## When the adapter is missing

If `Type:` names a tracker with no adapter file (e.g. `Type: jira` and no
`adapters/jira.md`), stop and tell the user. Don't fall back to a similar
tracker.
