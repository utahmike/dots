---
description: Strict pre-commit review of React + MUI code changes — flags correctness, types, MUI usage, a11y, forms, state, perf, tests, and consistency issues
allowed-tools: Read, Glob, Grep, Bash
---

# React + MUI code review

## Purpose

Run a strict review of React code that uses Material UI (MUI). Use this
before committing changes. The goal is to catch regressions, inconsistent
patterns, fragile UI code, accessibility issues, and avoidable complexity
introduced by agent-generated code.

Be strict. Do not rubber-stamp generated code. Prefer small, idiomatic,
maintainable changes over clever or broad rewrites.

---

## Review Priorities

Review changes in this order:

1. Correctness and runtime safety
2. TypeScript correctness
3. React component design
4. MUI usage and styling consistency
5. Accessibility
6. State management and data flow
7. Performance
8. Test coverage
9. Maintainability and readability

If any high-priority issue exists, call it out clearly before commenting on
lower-priority style issues.

---

## Required Checks

### 1. Correctness

Verify that the code does what the surrounding feature expects.

Check for:

- Broken prop names or mismatched component APIs
- Incorrect conditional rendering
- Missing loading, empty, and error states
- Event handlers that do not handle edge cases
- Incorrect assumptions about nullable or optional values
- Incorrect date, number, or string formatting
- Client-side behavior that conflicts with server/API behavior
- Accidental changes to existing behavior outside the requested scope

Do not assume generated code is correct because it compiles.

### 2. TypeScript

Prefer precise types over broad escape hatches.

Flag:

- `any`, `unknown`, or type assertions used without a clear reason
- Non-null assertions (`!`) where the value may actually be absent
- Incorrect event types, especially for MUI inputs and buttons
- Props that are optional but used as required
- Duplicated local types that should reuse existing project types
- Weak object shapes where discriminated unions or stricter interfaces would
  be clearer

Prefer:

- Explicit component prop types
- Existing shared domain types
- Narrow helper types close to the code that uses them
- `React.ReactNode` only when truly accepting arbitrary renderable content

### 3. React Component Design

Components should be small, predictable, and easy to test.

Check for:

- Components doing too many unrelated things
- Business logic mixed deeply into JSX
- Derived state stored unnecessarily in `useState`
- Effects used for work that could be done during render or in event handlers
- Missing effect dependencies
- Effects that cause render loops
- Inline functions or objects that cause unnecessary child re-renders where
  it matters
- Unstable keys, especially array indexes for dynamic lists
- Mutating props, state, query results, or context values

Prefer extracting helpers only when it improves clarity. Avoid premature
abstraction.

### 4. MUI Usage

Use MUI idiomatically and consistently with the existing codebase.

Check for:

- Raw HTML elements where MUI components would be more consistent
- Overuse of `Box` where semantic components would be better
- Styling that bypasses the theme unnecessarily
- Hard-coded colors, spacing, typography, shadows, or breakpoints
- Inconsistent use of `sx`, styled components, theme overrides, or CSS
  modules compared with the surrounding code
- Incorrect use of layout components such as `Grid`, `Stack`, `Box`, and
  `Container`
- Components missing important props such as `aria-*`, `label`, `id`,
  `htmlFor`, `disabled`, `error`, or `helperText`
- Incorrect `TextField`, `Select`, `Autocomplete`, `Dialog`, `Menu`,
  `Tooltip`, `DataGrid`, or `Snackbar` patterns
- Deprecated MUI APIs or props

Prefer:

- Theme tokens over literal values
- MUI spacing values over raw pixel spacing
- `Stack` for simple one-dimensional layout
- `Grid` only when a true two-dimensional responsive layout is needed
- Typography variants instead of custom font sizes
- Existing shared components before introducing new visual patterns

Example concerns:

```tsx
// Avoid hard-coded visual constants when theme tokens are available.
<Box sx={{ color: '#1976d2', marginTop: '12px' }} />
// Prefer theme-aware values.
<Box sx={{ color: 'primary.main', mt: 1.5 }} />
```

### 5. Accessibility

Review accessibility as a functional requirement, not a nice-to-have.

Check for:

- Buttons or icon buttons without accessible names
- Form controls without labels
- Incorrect heading order
- Clickable non-interactive elements
- Keyboard traps or mouse-only behavior
- Dialogs that do not manage focus correctly
- Menus, popovers, and tooltips used in inaccessible ways
- Color-only communication of state
- Missing `aria-describedby` for errors or helper text where needed
- Disabled controls that hide necessary context

MUI handles many accessibility concerns, but only when used correctly.

### 6. Forms

For forms, verify correctness, validation, and user feedback.

Check for:

- Controlled/uncontrolled input warnings
- Validation that runs too late or too early
- Error text not connected to the relevant field
- Submit buttons that can double-submit
- Missing pending state during async submission
- Lost form state after re-render
- Incorrect parsing of numbers, dates, booleans, or select values
- `Autocomplete` equality issues, especially missing `isOptionEqualToValue`

### 7. State Management and Data Flow

State should live at the lowest useful level and have a clear owner.

Check for:

- Duplicated state that can diverge
- Parent state updated by deeply nested components without a clear reason
- Context used for local state
- Global state introduced unnecessarily
- Query/cache updates that do not match mutation behavior
- Optimistic updates without rollback behavior
- Race conditions in async flows

### 8. Performance

Do not optimize blindly, but flag obvious performance problems.

Check for:

- Expensive calculations during render without memoization
- Large lists rendered without pagination or virtualization
- Repeated filtering/sorting of large arrays during render
- Objects, arrays, or callbacks recreated in hot paths and passed to
  memoized children
- Unnecessary network requests caused by effect dependencies
- Heavy MUI components imported where lighter alternatives already exist

Avoid adding `useMemo` or `useCallback` everywhere. Use them only when they
solve a real stability or cost issue.

### 9. Tests

Review whether the change is adequately covered.

Check for:

- Missing tests for changed behavior
- Tests that only assert implementation details
- Tests that rely on brittle selectors
- Missing coverage for error, loading, and empty states
- Missing accessibility-oriented queries in React Testing Library
- Snapshots that obscure meaningful behavior changes

Prefer tests that assert user-visible behavior.

Good patterns:

- `screen.getByRole(...)`
- `screen.getByLabelText(...)`
- `screen.getByText(...)` when appropriate
- `userEvent` for interactions

Avoid relying on MUI-generated class names.

### 10. Codebase Consistency

Before accepting a new pattern, compare it to nearby code.

Check for:

- Existing shared components that should have been reused
- Existing hooks that already solve the problem
- Existing formatting, naming, and file organization conventions
- Existing error handling and notification patterns
- Existing API/client/query patterns
- Existing theme extensions or design tokens

Do not introduce a second way to do the same thing unless there is a clear
benefit.

---

## MUI-Specific Review Checklist

Use this checklist for every React/MUI change:

- Uses theme tokens instead of hard-coded visual values where practical
- Uses `sx` consistently with surrounding code
- Uses semantic HTML or appropriate MUI components
- Form fields have labels and error/helper text where needed
- Icon-only buttons have `aria-label`
- Dialogs have meaningful titles and actions
- Menus/popovers are keyboard accessible
- Responsive behavior is intentional
- Layout uses `Stack`, `Grid`, `Box`, and `Container` appropriately
- Avoids deprecated MUI APIs
- Does not rely on generated MUI class names
- Does not duplicate theme overrides locally

---

## Review Output Format

When reviewing, provide findings in this format:

```
## Summary
Briefly describe whether the change is safe to commit.

## Blocking Issues
List issues that must be fixed before commit.

## Non-Blocking Issues
List improvements that are worth considering but should not block commit.

## Suggested Fixes
Provide concrete code-level fixes when possible.

## Verification
List what was checked: typecheck, lint, tests, build, manual review, or
anything that could not be run.
```

Use severity labels:

- **BLOCKING**: correctness, accessibility, data loss, runtime failure,
  broken tests, or serious maintainability issue
- **IMPORTANT**: should be fixed soon but may not block if risk is low
- **NIT**: minor readability or style concern

---

## Review Behavior

The reviewer must:

- Be specific and cite files, components, functions, and lines when possible
- Explain why an issue matters
- Prefer actionable fixes over vague criticism
- Avoid broad rewrites unless the current approach is flawed
- Avoid inventing project conventions that are not visible in the repo
- Distinguish between confirmed issues and assumptions
- Say when something could not be verified

The reviewer must not:

- Approve code solely because it compiles
- Ignore accessibility issues
- Normalize unnecessary `any` or unsafe assertions
- Introduce new dependencies without a strong reason
- Rewrite working code for personal preference
- Suggest patterns that conflict with nearby code

---

## Commands to Run When Available

Run the relevant project commands before approving, using the package
manager already used by the repo.

Common examples:

```bash
npm run typecheck
npm run lint
npm test
npm run build
```

or:

```bash
yarn typecheck
yarn lint
yarn test
yarn build
```

or:

```bash
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

If a command does not exist, do not invent it. Report that it was
unavailable.

---

## Final Commit Gate

Before saying the code is ready to commit, confirm:

- No blocking issues remain
- Type checking passes or the inability to run it is stated
- Linting passes or the inability to run it is stated
- Relevant tests pass or the inability to run them is stated
- MUI usage is consistent with the project
- Accessibility concerns have been reviewed
- The change is limited to the requested scope

If these cannot be confirmed, do not say the code is ready to commit. Say
what remains uncertain.
