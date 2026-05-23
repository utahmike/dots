---
name: mr-resolve
description: Execute the MR plan in .claude/mr-plan.md — plan, implement, commit, push, and reply per changeset. Safe to re-run after interruption; skips already-completed changesets.
allowed-tools: Bash(glab:*), Bash(git:*), Read, Write, Edit, EnterPlanMode, ExitPlanMode
---

# mr-resolve — Execute the MR plan and reply to threads

Read `.claude/mr-plan.md`, and for each `pending` changeset: enter
planning mode to design the implementation, execute the plan, commit,
push, and post a detailed reply to each thread — all before moving to
the next changeset. Designed to be re-run safely after interruption —
changesets marked `committed` or `done` are never re-implemented.

## Step 1 — Preconditions

Check all of the following before doing anything else. If any fail,
tell the user what went wrong and stop.

**1a. Plan file exists:**
```bash
test -f .claude/mr-plan.md
```
If missing, tell the user to run `/mr-review <url>` first.

**1b. Working tree is clean:**
```bash
git status --porcelain
```
If there is any output, tell the user to stash or commit their changes
before running `/mr-resolve`.

**1c. Branch matches plan:**
Parse `source_branch` from the `## Metadata` block in the plan.
Compare to `git branch --show-current`. If they differ, warn the user
and ask whether to continue before proceeding.

## Step 2 — Parse the plan

From the `## Metadata` block extract:
- `$MR_URL`
- `$IID`
- `$PROJECT_PATH`
- `$ENCODED_PATH`
- `$SOURCE_BRANCH`
- `$TARGET_BRANCH`

Parse each `## Changeset $LETTER: $TITLE` block and extract:
- `$LETTER` and `$TITLE`
- `$STATUS` — the value of the `Status` field
- `$NOTE_IDS` — all `#NNN` values from the `Note IDs` field
- `$DISCUSSION_IDS` — all UUIDs from the `Discussion IDs` field
- `$APPROACH` — the full Approach paragraph
- Thread entries (note ID, author, file, line, full body) from the
  `### Threads` subsection

Build an ordered list of all changesets. Process only those with
`Status: pending` or `Status: committed`. If all changesets are `done`,
tell the user the plan is fully resolved and stop.

If any changeset is `committed ($SHA)` — meaning it was committed in a
prior run but the push or reply failed — skip the plan, implement, and
commit steps but still attempt push and reply.

## Step 3 — Process each changeset

Iterate through changesets in document order, one at a time. Each
changeset is fully resolved (planned, implemented, committed, pushed,
and replied to) before moving to the next.

### 3a — Announce

Print a header before starting:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Changeset $LETTER: $TITLE
Note IDs: $NOTE_IDS
Files: $FILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3b — Plan

**Skip this step if the changeset status is `committed`.**

Enter planning mode using the `EnterPlanMode` tool. Read the `Approach`
paragraph and the full thread bodies for this changeset. Explore the
relevant files and surrounding code to understand the current state.
Write a detailed implementation plan covering:

- Which files need to change and what the specific edits are
- The order of changes if it matters
- Any edge cases or risks identified during exploration
- Whether the approach from the MR plan needs adjustment (and why)

Once the plan is complete, exit planning mode using `ExitPlanMode` and
wait for the user to approve before proceeding.

### 3c — Implement

**Skip this step if the changeset status is `committed`.**

Execute the approved plan from 3b. Make all required code changes. If
changes span multiple files, edit all of them before committing. If
mid-implementation you discover the approach needs adjusting, adjust it
and note the deviation — you will include it in the thread reply.

### 3d — Commit

**Skip this step if the changeset status is `committed`.**

Stage and commit:
```bash
git add -A
git commit -m "$COMMIT_MESSAGE"
```

Commit message format:
```
$VERB $SHORT_DESCRIPTION

Addresses MR !$IID threads: $NOTE_IDS

$OPTIONAL_BODY — include when the change is non-obvious; explain the
why, not just the what.
```

Example:
```
Extract JWT verification to shared utility

Addresses MR !42 threads: #312, #318, #341

Inline token logic in the middleware duplicated the verifyJWT helper in
src/utils/jwt.ts. Centralising this ensures expiry handling and error
logging are applied consistently across all auth paths.
```

Record the full SHA:
```bash
git rev-parse HEAD
```

### 3e — Update plan file status

Immediately after committing, update the changeset's `Status` line in
`.claude/mr-plan.md` from:
```
- **Status:** pending
```
to:
```
- **Status:** committed $FULL_SHA
```

This write must happen before moving to the next sub-step. If the
process is interrupted after a commit but before the status is written,
the commit SHA is still recoverable from `git log`, but writing it
immediately avoids ambiguity on re-run.

### 3f — Push

Push the commit for this changeset:
```bash
git push origin HEAD
```

If the push fails (remote has diverged, permission error, etc.), stop
immediately. Do not force-push. Report the exact error and suggest:
- `git pull --rebase origin $TARGET_BRANCH` if the remote diverged
- Contacting a repo admin if it is a permission issue

Do not proceed to the reply step until the push succeeds.

### 3g — Reply to threads

After a successful push, post a reply to each thread in this changeset.

#### Reply content

For each thread, write a reply with this structure:

---

**Addressed in [`$SHORT_SHA`]($MR_URL/commit/$FULL_SHA)**

$EXPLANATION — a full paragraph (3–6 sentences) addressed to the
reviewer, not just to the commit log. Cover:
- What specifically changed and where (file, function, line range)
- Why this approach was chosen, especially if it differs from the
  reviewer's suggestion
- Any trade-offs or follow-on considerations worth flagging
- If this thread was resolved together with others: "This was addressed
  alongside #318 and #341 as part of a broader refactor of the auth
  middleware."

---

#### API call

```bash
glab api "projects/$ENCODED_PATH/merge_requests/$IID/discussions/$DISCUSSION_ID/notes" \
  --method POST \
  -f "body=$REPLY_BODY"
```

Use the UUID from `Discussion IDs` (not the `#NNN` note ID) for
`$DISCUSSION_ID`.

After all replies for this changeset succeed, update the changeset's
`Status` line in `.claude/mr-plan.md` from:
```
- **Status:** committed $SHA
```
to:
```
- **Status:** done $SHA
```

If a reply POST fails, print a warning with the error, leave the status
as `committed $SHA`, and continue to the next changeset. Do not abort
the entire run for a single failed reply. On a subsequent `/mr-resolve`
run, any changeset still in `committed` state will have its push and
reply retried automatically.

### 3h — Continue

Print the short SHA and a one-line summary, then continue to the next
changeset without waiting for input.

## Step 4 — Final summary

Print a closing summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done — MR !$IID
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Changesets resolved:  $N
  $LETTER: $SHORT_SHA — $TITLE
  ...
Replies posted: $N/$TOTAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If any replies failed (`committed` changesets remain in the plan),
remind the user they can re-run `/mr-resolve` to retry only those
outstanding replies — no code changes will be made on a re-run when
all changesets are `committed` or `done`.

Remind the user that resolving threads in the GitLab UI must be done
manually — the API does not permit resolving another user's thread.
