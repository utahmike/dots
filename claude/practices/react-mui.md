# React + MUI best practices

Apply these when reading, writing, or reviewing React code that uses
Material UI (MUI v5+). Assumes function components and hooks throughout.

## Consistency with the codebase comes first

Before introducing any pattern, look at neighboring code. If there's already
a shared component, hook, formatter, error pattern, query helper, or theme
extension that solves the problem, use it. Don't introduce a second way to
do the same thing unless there's a clear benefit — and say what the benefit
is. Don't invent conventions that aren't visible in the repo.

## Components

- Function components only. No class components in new code.
- One component per file by default. Co-locate small helpers, styles, and
  tests in the same file or a sibling.
- Prefer composition over configuration: small focused components that
  compose, not one component with 15 boolean props.
- Keep business logic out of JSX. Extract it to hooks, helpers, or the
  parent that owns the data.
- Type props with a named `interface` (`interface FooProps { ... }`), not an
  inline anonymous type. Export it if consumers need it.

## State management

State lives in different buckets that need different tools. Don't reach for
`useReducer` or `useState` for things that belong elsewhere.

- **Server state** (data from APIs): use a server-state library — TanStack
  Query or SWR. Never hand-roll fetch-in-`useEffect` with `useState`. That
  pattern misses cache, dedup, refetch, error handling, and race conditions.
- **Cross-tree client state** (current user, theme, locale, auth): React
  Context is for *genuinely* tree-wide values that change rarely. For
  cross-tree state that updates often, use a small external store (Zustand,
  Jotai) — Redux only if the project already uses it.
- **Local component state**: `useState` for simple values. Reach for
  `useReducer` only when the state has multiple fields that change together
  with named transitions worth modeling (a multi-step form, a complex
  toggle machine). Don't use `useReducer` for "app state" — that's a
  different problem.

Other rules:

- State should live at the lowest useful level and have a clear owner. Lift
  state up only as far as the closest common ancestor that needs it.
- Don't duplicate state — it'll diverge. Derive instead.
- Don't store derived values in `useState`; compute them during render or
  with `useMemo` if cost matters.
- Don't mutate props, state, query results, or context values.

## Effects

- `useEffect` only for synchronization with something outside React (DOM
  APIs, subscriptions, external stores, the URL). Don't use effects to
  derive state from props — compute during render.
- Dependency arrays must be complete. If the linter says to add a
  dependency, either add it or restructure — don't silence the warning.
- Always return a cleanup function from effects that subscribe, time out, or
  attach listeners.
- `useLayoutEffect` only for DOM measurements that must run before paint; it
  blocks rendering.
- Don't write effects that depend on values they themselves update — that's
  a render loop.

## Forms

Forms are where the MUI sharp edges live. Prefer `react-hook-form` with
MUI's `Controller` for validation-aware forms.

- Don't mix controlled and uncontrolled inputs in the same form. Decide
  per-field and stick to it; React will warn if you switch.
- Wire error text to the field with MUI's `error` + `helperText` props, and
  `aria-describedby` if you're rolling your own message element.
- Submit buttons must guard against double-submit — disable while pending
  and have a clear pending state visible to the user.
- Don't lose form state across unrelated re-renders. If the form unmounts,
  state goes with it; lift it or use the form library's state.
- Parse explicitly: number inputs come back as strings, dates as `Date` or
  `null`, selects as the option's `value` not its label, booleans from
  checkboxes as booleans.
- `Autocomplete` with object options **must** define `isOptionEqualToValue`
  — without it, equality compares references and selection appears broken.
  Also set `getOptionLabel` and `getOptionKey` when defaults aren't right.
- Validate at the right time: on blur for individual fields, on submit for
  cross-field rules. Validating on every keystroke is noisy.

## MUI styling

- Use the `sx` prop for one-off styles. Use `styled(Component)` for reusable
  styled variants. Avoid raw CSS / CSS modules unless the project already
  uses them.
- Reference theme tokens, not literals: `sx={{ p: 2, color: 'primary.main' }}`,
  not `sx={{ padding: '16px', color: '#1976d2' }}`. The spacing scale is
  `theme.spacing(1) = 8px` by default.
- Use `Typography` variants (`h1`–`h6`, `body1`, `body2`, etc.) instead of
  custom font sizes — they wire into the theme.
- Customize globally via `createTheme({ components: { MuiButton: { ... } } })`,
  not by overriding styles in every consumer. Don't duplicate theme
  overrides locally.
- Use `sx` consistently with the surrounding code — if the file uses
  `styled()`, don't drop a one-off `sx`; if it uses `sx`, don't extract a
  styled component for a one-off.

## MUI components

- Use MUI's layout primitives over raw `<div>` + flexbox. `Stack` for
  one-dimensional layouts with spacing; `Grid` only when you genuinely need
  two-dimensional / responsive layout; `Container` for page-width
  constraints; `Box` as a generic styled `div` when nothing more semantic
  fits — but don't reach for `Box` when a semantic MUI component would do
  the job.
- Prefer MUI components over raw HTML where consistency matters (`Button`
  over `<button>`, `Link` over `<a>`, `TextField` over `<input>` in forms).
  Raw HTML is fine for genuinely structural markup (`<main>`, `<section>`,
  `<article>`) that MUI doesn't have a direct equivalent for.
- Use the responsive object syntax for breakpoints:
  `<Box sx={{ width: { xs: '100%', md: '50%' } }} />`. Don't hand-roll
  media queries.
- Icons: `@mui/icons-material`. Import individual icons, not the whole
  package (`import MenuIcon from '@mui/icons-material/Menu'`) — saves
  bundle size.
- Avoid deprecated APIs. When the docs say a prop or component is
  deprecated, use the replacement.

## Accessibility

Accessibility is a functional requirement, not polish. MUI components are
accessible by default *when used correctly* — and easy to break when used
wrong.

- Every interactive element must be keyboard-reachable. Use `Button` /
  `IconButton` for clickable things, not styled `<div onClick>`.
- Icon-only buttons need `aria-label`. So do icon-only menu items.
- Form inputs need a label — either a `<label>`, MUI's `label` prop, or an
  `aria-label`. A placeholder is not a label.
- Don't break heading order (`h1` → `h2` → `h3`). Skipping levels for
  styling reasons is wrong — change the visual style, not the semantic
  level.
- Dialogs must manage focus: focus moves to the dialog on open, trapped
  while open, restored on close. MUI's `Dialog` does this; don't replace it
  with a custom-positioned `Box`.
- Don't communicate state with color alone. Pair color with an icon, text,
  or both.
- Don't strip the ARIA attributes MUI ships with its components.

## Performance

Don't preemptively wrap things in `React.memo` / `useMemo` / `useCallback`.
Reach for them when:

- Profiling shows a real re-render problem
- Prop identity matters (passing callbacks to memoized children, deps of
  another hook)
- A computation is genuinely expensive (sorting/filtering large arrays,
  parsing/transforming complex data)

Other rules:

- Lazy-load route-level components with `React.lazy` + `<Suspense>`.
- Virtualize long lists (TanStack Virtual, react-window) — anything over a
  few hundred rows.
- Don't filter/sort large arrays during render without memoization.
- Don't import heavy MUI components when lighter alternatives already exist
  in the codebase.
- Use stable keys in lists — never array index for dynamic lists.

## TypeScript

- Strict mode on. No `any` without an inline `// eslint-disable-next-line` +
  reason comment. `unknown` is acceptable when you genuinely don't know the
  type, but narrow it before use.
- No non-null assertions (`!`) unless you can prove the value is present at
  that line. If you can prove it, prefer a refactor that makes it visible
  in the type.
- Let MUI's generic types flow through: `<Autocomplete<MyOption>>`, not
  `(value as MyOption)`. Same for `Select`, `DataGrid`, etc.
- Type `useState` explicitly when the initial value doesn't constrain the
  type (`useState<User | null>(null)`).
- Use correct event types — `React.ChangeEvent<HTMLInputElement>`,
  `React.MouseEvent<HTMLButtonElement>`, MUI's `SelectChangeEvent<T>` for
  `Select`. Don't `(e: any) => ...`.
- Reuse shared domain types rather than redefining them locally.

## File structure

- Co-locate by feature, not by type. `features/checkout/` containing
  components, hooks, types, and tests beats `components/`, `hooks/`,
  `types/`, `tests/` split at the root.
- One component per file by default. Tiny private subcomponents can live in
  the same file.
- Barrel files (`index.ts` re-exports) sparingly — they hurt tree-shaking
  and create circular-import risk.
