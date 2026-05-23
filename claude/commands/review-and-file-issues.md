---
description: Review the current changes or codebase and file actionable issues in the repo's configured issue system
allowed-tools: Read, Glob, Grep, Bash, WebFetch
---

Review the current changes or codebase for actionable issues.

## Scope

If there are uncommitted changes or a checked-out feature branch ahead of the
main branch, focus on that diff. Otherwise review the area indicated by the
user's invocation context (or ask if it's unclear).

## For each candidate issue

- Confirm it's reproducible or strongly supported by direct code evidence —
  cite file:line.
- Check for duplicates in the existing issue tracker before creating anything
  new (the adapter spells out the search command).
- Write a concise title (under ~70 chars) that names the problem, not the fix.
- Include in the body: affected files/functions, reproduction or evidence,
  severity, and a suggested fix or next step.

## Filing

Use the `issue-system` skill to create the issues. It will read the repo's
`CLAUDE.md` `## Issue System` section, dispatch to the matching adapter, and
use the exact commands/tools the adapter specifies.

If the repo has no `## Issue System` configured, stop and report the findings
inline instead of creating issues — don't guess at a tracker.

## Output

After filing, print a short summary: one line per issue with title and tracker
ID/URL.
