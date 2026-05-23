# Linear adapter

Use the Linear MCP tools. The exact tool names depend on which Linear MCP
server is installed in the user's Claude Code config — typical names are
`mcp__linear__create_issue`, `mcp__linear__search_issues`,
`mcp__linear__update_issue`, `mcp__linear__add_comment`,
`mcp__linear__get_issue`. If the available tool names differ, use what's
actually in the tool list (don't invent names).

## Required repo CLAUDE.md parameters

```
## Issue System
Type: linear
Team: <team key, e.g. PLAT>
Project: <project name or ID, optional>
Labels: <comma-separated default labels to apply, optional>
```

## Severity mapping (default — override per repo if needed)

- P0 / critical / outage → Urgent
- P1 / high → High
- P2 / medium / normal → Medium
- P3 / low / cleanup / docs → Low

## Operations

### search

Use the Linear search tool with the issue title or a key phrase from the
error/symptom. Filter by team if specified. Return existing matches so the
caller can decide to comment, update, or skip rather than duplicate.

### create

Required fields: title, description (markdown ok), team. Optional: project,
labels, priority (mapped from severity above), assignee.

Always include in the description:
- affected files (`path/to/file.ext:line`)
- reproduction steps or evidence
- suggested fix / next step

### update

Look up the issue by ID, then patch the fields the caller asked to change.

### comment

Add a markdown comment to the named issue ID.

### show

Fetch and return the issue body plus its comments for the caller to read.
