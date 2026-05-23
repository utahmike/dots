## Best practices

At the start of any non-trivial task, read `~/.claude/practices/general.md`
in full and apply its guidance.

Additionally, look in the project-level `CLAUDE.md` for a section like:

```
## Stack
- <tag>
- <tag>
```

For each tag listed, read `~/.claude/practices/<tag>.md` in full and apply
that file's guidance to any code you read or write in that language/platform.
If a referenced file doesn't exist, note it briefly and continue — don't
invent guidance from memory.

Stack tags are one per line. Composite tags (e.g. `react-mui`) are allowed
when the combination has practices specific to using the technologies
together; otherwise prefer single-technology tags so guidance composes
across stacks.

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
