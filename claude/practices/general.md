# General best practices

Apply these regardless of language, framework, or platform. Language- and
stack-specific files override anything here when they conflict.

## Naming

- Match the project's existing vocabulary. If the codebase calls something
  an `Order`, don't introduce `Purchase` for the same concept.
- Descriptive over short. `userPreferences` over `up`. Exceptions: short
  loop indices (`i`, `j`), well-established conventions (`req`, `res`, `ctx`).
- Functions are verb phrases (`calculateTotal`, `parseConfig`). Types and
  variables are noun phrases (`InvoiceLine`, `pendingRequest`).
- Booleans as positive predicates: `isReady`, `hasPermission`, `canEdit` —
  not `notReady`, `isMissing`. Negatives invert badly (`if (!notReady)`).
- No abbreviations unless universal (`url`, `http`, `id` are fine;
  `cfg`, `mgr`, `acc` are not).

## UX writing and presentation

- **Title case for non-prose UX elements**: button labels, menu items,
  navigation labels, table column headers, tab names, modal titles, form
  field labels, and page titles. *"Save Changes"*, not *"Save changes"*.
- **Sentence case for prose**: paragraph copy, help text, tooltips, error
  messages, confirmation body text, descriptions. These are full sentences;
  capitalize like sentences.
- **Numbers get thousands separators**: `1,000` not `1000`; `1,234,567` not
  `1234567`. Applies to counts, currency, durations, anything user-visible.
  Use the platform's locale-aware formatter (`Intl.NumberFormat`,
  `NumberFormatter`, etc.) rather than hand-rolling — it handles locale
  differences (`1,000` vs `1.000` vs `1 000`).
- **Don't end button labels with periods.** "Save Changes", not "Save Changes."
- **Error messages tell the user what to do**, not just what failed.
  "Couldn't reach the server. Check your connection and retry." beats
  "Network error."
- **Confirmations are specific.** "Delete 3 invoices?" beats "Are you sure?".
  Include what will be deleted, how many, and the action verb in the button.
- **Consistent terminology.** Pick one verb per action and stick to it
  across the UI — don't say "Delete" here and "Remove" there for the same
  operation.
- **Consistent verb tense in actions.** Buttons are imperative present
  ("Save", "Delete"); status text is past or progressive ("Saved",
  "Saving…").
- **No technical jargon in user-facing copy.** "Connection timed out"
  beats "ETIMEDOUT".
- Format dates and times with the user's locale and timezone; never assume
  UTC or a fixed format.

## Error handling

- Errors carry context: what was being attempted, with what inputs. Bare
  "operation failed" is useless when debugging.
- Don't silently swallow errors. If you catch one, do something with it
  (log, transform, recover) — and if you're intentionally discarding it,
  leave a comment explaining why.
- Fail fast at system boundaries (parse / validate inputs as early as
  possible); be tolerant inside trusted code.
- Distinguish user-facing errors (need friendly messaging) from system
  errors (need stack traces and context). Don't show stack traces to users.
- Don't use exceptions for control flow in languages where they're
  expensive (Python is more forgiving here than Java or C#).

## Logging

- Prefer structured logging (key/value pairs) over format strings — the
  data stays queryable.
- Log enough to debug a failure post-hoc: include the relevant IDs, the
  operation, and what went wrong. Not so much that signal drowns in noise.
- Use levels with discipline: `error` for things that need attention,
  `warn` for unexpected-but-recoverable, `info` for milestones, `debug`
  for development-time detail.
- Never log secrets, tokens, passwords, or PII. Mask or redact if the
  context requires inclusion (last 4 of a card number, hashed email).
- Don't log inside tight loops without sampling — log volume blows up fast.

## Security baseline

- Validate at system boundaries (HTTP request, CLI args, file inputs,
  external API responses). Trust internal code that's already been
  validated.
- Database queries: parameterized only. Never string-concatenate user input
  into SQL.
- Escape output for the destination context: HTML escape for HTML, shell
  escape for shell, URL encode for URLs. Don't reuse one escape function
  for all contexts.
- Secrets stay out of code, commits, logs, and error messages. Use the
  platform's secret store (env vars, secret managers, keychains).
- Don't trust client-supplied data — even from "your own" frontend.
  Authentication and authorization happen server-side.
- Default deny: explicit allowlists beat blocklists; missing permissions
  mean no access, not implicit grant.

## Testing

- Test observable behavior, not implementation details. Refactoring should
  not break tests.
- One reason to fail per test. If a test asserts five unrelated things, a
  failure tells you the test failed but not what's actually broken.
- Setup helpers when the same setup appears in 3+ tests. Once or twice is
  fine inline.
- Use realistic data — `"foo"` and `42` hide bugs that real names and
  amounts catch.
- Don't test framework code or third-party libraries. Test the seams where
  your code meets them.

## Performance posture

- Don't preempt. Measure before optimizing. Most code is not on the hot path.
- Watch for accidental quadratic behavior: nested loops over collections,
  repeated linear scans, calling an O(n) function inside another O(n)
  function. Fine at n=10, catastrophic at n=10,000.
- N+1 query problems are the most common server-side perf bug. When
  iterating over records and accessing related data, batch the related
  query.
- Lazy-load expensive resources; release them when done.

## Dependencies

- Don't pull in a library for a single function you could write in 10 lines.
- Prefer maintained packages with active commits, an issue tracker that
  gets responses, and a license compatible with the project.
- Pin versions for applications (reproducible builds); use ranges for
  libraries (compatibility). Commit lockfiles for apps; gitignore them for
  libraries.
- Audit transitive dependencies when adding something new — a small package
  pulling in 200 sub-dependencies is a smell.

## Documentation

- Document WHY, not WHAT. The code shows what it does; comments explain
  why a non-obvious decision was made.
- Public API surfaces get docs: function purpose, parameters with units
  where ambiguous (`timeoutMs` not just `timeout`), error conditions,
  examples for non-trivial usage.
- Commit messages explain motivation, not file lists. "Fix race condition
  in checkout submit" beats "update checkout.tsx".
- README updates when user-visible behavior changes.

## Git and version control

- One logical change per commit. Bug fix and unrelated refactor go in
  separate commits.
- Don't commit generated files, build artifacts, secrets, or large
  binaries.
- Branch names describe the work: `fix/checkout-double-submit`, not
  `mike/branch-2`.
- Rebase or merge per the project's convention; don't fight the repo's
  style.
