# React + MUI best practices

Apply these when reading, writing, or reviewing React code that uses
Material UI (MUI v5+). Assumes function components and hooks throughout.

## Components

- Function components only — no class components in new code.
- One component per file by default. Co-locate styles, tests, and small
  helper components in the same file or a sibling.
- Prefer composition over configuration: small focused components that
  compose, not a single component with 15 boolean props.
- Type props with a named `interface` (`interface FooProps { ... }`), not
  an inline anonymous type. Export the interface alongside the component if
  consumers need it.

## State management

- `useState` for local UI state. `useReducer` once the state has multiple
  fields that change together or transitions worth naming.
- Lift state to the closest common ancestor; don't reach for context
  reflexively. Context is for *genuinely* tree-wide values (theme, auth,
  locale) — overusing it causes wide re-renders.
- For cross-tree shared state, prefer a small external store (Zustand,
  Jotai) over Redux unless the project already uses Redux.
- Server state belongs in a server-state library (TanStack Query, SWR), not
  in `useState` + `useEffect`. Hand-rolled fetch-in-effect is almost always
  the wrong call.

## Effects

- `useEffect` only for synchronization with something outside React (DOM
  APIs, subscriptions, external stores). Don't use effects to derive state
  from props — compute it during render or via `useMemo`.
- Dependency arrays must be complete. If the linter says to add a
  dependency, either add it or restructure — don't silence the warning.
- Always return a cleanup function from effects that subscribe, time out,
  or attach listeners.
- `useLayoutEffect` only for DOM measurements that must run before paint;
  it blocks rendering.

## Performance

- Don't preemptively wrap things in `React.memo` / `useMemo` / `useCallback`.
  Reach for them when profiling shows a real re-render problem, or when
  prop-identity matters (passing callbacks to memoized children, deps of
  another hook).
- Lazy-load route-level components with `React.lazy` + `<Suspense>`.
- Virtualize long lists (TanStack Virtual, react-window). Anything over a
  few hundred rows.

## MUI styling

- `sx` prop for one-off styles. `styled(Component)` for reusable styled
  variants. Avoid raw CSS / CSS modules unless the project already uses them.
- Reference theme tokens, not literals: `sx={{ p: 2, color: 'primary.main' }}`,
  not `sx={{ padding: '16px', color: '#1976d2' }}`. Spacing scale is
  `theme.spacing(1) = 8px` by default.
- Customize globally via `createTheme({ components: { MuiButton: { ... } } })`,
  not by overriding styles in every consumer.

## MUI components

- Prefer MUI's layout primitives (`Box`, `Stack`, `Grid`) over raw `<div>` +
  flexbox CSS. `Stack` for one-dimensional layouts with spacing; `Grid` for
  two-dimensional / responsive.
- Use MUI form components (`TextField`, `Select`, `Checkbox`, etc.) with
  `react-hook-form` via `Controller` for validation-aware forms. Don't mix
  controlled and uncontrolled inputs in the same form.
- Use the responsive object syntax for breakpoints:
  `<Box sx={{ width: { xs: '100%', md: '50%' } }} />`. Don't hand-roll
  media queries.
- Icons: `@mui/icons-material`. Import individual icons, not the whole
  package (`import MenuIcon from '@mui/icons-material/Menu'`) — saves bundle
  size.

## Accessibility

- MUI components are accessible by default. Don't strip their ARIA
  attributes or replace them with custom-styled `div`s.
- Every interactive element must be keyboard-reachable. `IconButton` over
  styled `<div onClick>`.
- Form inputs need a label — either a `<label>`, MUI's `label` prop, or an
  `aria-label`. Placeholder is not a label.

## TypeScript

- Strict mode on. No `any` without an inline `// eslint-disable-next-line`
  + reason comment.
- Let MUI's generic types flow through: `<Autocomplete<MyOption>>` not
  `(value as MyOption)`.
- Type `useState` explicitly when the initial value doesn't fully constrain
  the type (e.g., `useState<User | null>(null)`).

## File structure

- Co-locate by feature, not by type. `features/checkout/` containing
  components, hooks, types, and tests beats `components/`, `hooks/`,
  `types/`, `tests/` split at the root.
- Barrel files (`index.ts` re-exports) sparingly — they hurt tree-shaking
  and create circular-import risk.
