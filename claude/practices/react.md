# React best practices

Apply when reading, writing, or reviewing React code. Assumes function
components and hooks throughout. For MUI-specific guidance see `mui.md`;
for combined-stack sharp edges see `react-mui.md`.

## Consistency with the codebase comes first

Before introducing any pattern, look at neighboring code. If there's
already a shared component, hook, formatter, error pattern, query
helper, or theme extension that solves the problem, use it. Don't
introduce a second way to do the same thing unless there's a clear
benefit — and say what the benefit is. Don't invent conventions that
aren't visible in the repo.

## Components

- Function components only. No class components in new code.
- One component per file by default. Co-locate small helpers, styles,
  and tests in the same file or a sibling.
- Prefer composition over configuration: small focused components that
  compose, not one component with 15 boolean props.
- Keep business logic out of JSX. Extract it to hooks, helpers, or the
  parent that owns the data.
- Type props with a named `interface` (`interface FooProps { ... }`),
  not an inline anonymous type. Export it if consumers need it.

## State management

State lives in different buckets that need different tools. Don't reach
for `useReducer` or `useState` for things that belong elsewhere.

- **Server state** (data from APIs): use a server-state library —
  TanStack Query or SWR. Never hand-roll fetch-in-`useEffect` with
  `useState`. That pattern misses cache, dedup, refetch, error handling,
  and race conditions.
- **Cross-tree client state** (current user, theme, locale, auth):
  React Context is for *genuinely* tree-wide values that change rarely.
  For cross-tree state that updates often, use a small external store
  (Zustand, Jotai) — Redux only if the project already uses it.
- **Local component state**: `useState` for simple values. Reach for
  `useReducer` only when the state has multiple fields that change
  together with named transitions worth modeling (a multi-step form, a
  complex toggle machine). Don't use `useReducer` for "app state" —
  that's a different problem.

Other rules:

- State should live at the lowest useful level and have a clear owner.
  Lift state up only as far as the closest common ancestor that needs
  it.
- Don't duplicate state — it'll diverge. Derive instead.
- Don't store derived values in `useState`; compute them during render
  or with `useMemo` if cost matters.
- Don't mutate props, state, query results, or context values.

## Effects

- `useEffect` only for synchronization with something outside React
  (DOM APIs, subscriptions, external stores, the URL). Don't use
  effects to derive state from props — compute during render.
- Dependency arrays must be complete. If the linter says to add a
  dependency, either add it or restructure — don't silence the warning.
- Always return a cleanup function from effects that subscribe, time
  out, or attach listeners.
- `useLayoutEffect` only for DOM measurements that must run before
  paint; it blocks rendering.
- Don't write effects that depend on values they themselves update —
  that's a render loop.

## Performance

Don't preemptively wrap things in `React.memo` / `useMemo` /
`useCallback`. Reach for them when:

- Profiling shows a real re-render problem.
- Prop identity matters (passing callbacks to memoized children, deps
  of another hook).
- A computation is genuinely expensive (sorting/filtering large arrays,
  parsing/transforming complex data).

Other rules:

- Lazy-load route-level components with `React.lazy` + `<Suspense>`.
- Virtualize long lists (TanStack Virtual, react-window) — anything
  over a few hundred rows.
- Don't filter/sort large arrays during render without memoization.
- Use stable keys in lists — never array index for dynamic lists.

## TypeScript

- Strict mode on. No `any` without an inline
  `// eslint-disable-next-line` + reason comment. `unknown` is
  acceptable when you genuinely don't know the type, but narrow it
  before use.
- No non-null assertions (`!`) unless you can prove the value is
  present at that line. If you can prove it, prefer a refactor that
  makes it visible in the type.
- Type `useState` explicitly when the initial value doesn't constrain
  the type (`useState<User | null>(null)`).
- Use correct event types — `React.ChangeEvent<HTMLInputElement>`,
  `React.MouseEvent<HTMLButtonElement>`. Don't `(e: any) => ...`.
- Reuse shared domain types rather than redefining them locally.

## File structure

- Co-locate by feature, not by type. `features/checkout/` containing
  components, hooks, types, and tests beats `components/`, `hooks/`,
  `types/`, `tests/` split at the root.
- One component per file by default. Tiny private subcomponents can
  live in the same file.
- Barrel files (`index.ts` re-exports) sparingly — they hurt
  tree-shaking and create circular-import risk.
