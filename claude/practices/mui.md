# MUI best practices

Apply when reading, writing, or reviewing code that uses Material UI
(MUI v5+). Pairs with `react.md` for the React side and `react-mui.md`
for combined-stack sharp edges.

## Operating principles

1. Prefer MUI primitives before inventing custom markup.
2. Keep visual decisions theme-driven, not hard-coded.
3. Use component props first, `sx` second, wrapper components or
   `styled()` for reusable patterns, theme overrides for app-wide
   defaults.
4. Preserve accessibility and semantic HTML.
5. Optimize imports — never pull in the whole namespace.

## Styling hierarchy

Pick the lightest customization that fits the scope.

| Scope | Approach | Notes |
| --- | --- | --- |
| Built-in behavior/layout | Component props | `variant`, `color`, `size`, `disabled`, `fullWidth`, `alignItems` |
| One-off visual adjustment | `sx` prop | Single instance. Theme-aware and colocated. |
| Reused local pattern | Small wrapper component | Encapsulates props, behavior, and `sx`. |
| Reused styled element | `styled()` | When styling is part of a reusable abstraction. |
| App-wide defaults | Theme `components` config | Default props, variants, global overrides. |
| Large custom design system | Dedicated component | Theme `components` config is not tree-shakable — don't dump heavy designs there. |

Be consistent with the surrounding code — don't drop a one-off `sx` into
a file built around `styled()`, or vice versa.

## Theme usage

Reference theme tokens, never literals.

```tsx
<Box sx={{ p: 2, borderRadius: 2, bgcolor: 'background.paper', color: 'text.primary' }} />
```

Spacing scale is `theme.spacing(1) = 8px` by default. Use the palette,
typography variants, shape, breakpoints, shadows, and z-index from the
theme — not raw values.

Use `variant` for visual style and `component` for semantic HTML — they
are independent axes:

```tsx
<Typography variant="h6" component="h2">Account Settings</Typography>
```

For dark-mode safety, prefer semantic palette tokens (`background.paper`,
`text.primary`, `text.secondary`) over hardcoded `white` / `black`. If
you add custom colors, put them in the theme palette and verify contrast
in every supported color scheme.

## `sx` prop

Use object syntax. Use responsive object values for breakpoint-driven
layout:

```tsx
<Box sx={{
  display: 'grid',
  gridTemplateColumns: { xs: '1fr', md: 'repeat(2, minmax(0, 1fr))' },
  gap: 2,
}} />
```

Avoid:

```tsx
<Box sx={{ color: '#1976d2' }} />                       // magic colors
<Box sx={{ '.css-a1b2c3': { color: 'red' } }} />        // generated classes
<Card sx={{ p: 2, borderRadius: 3, boxShadow: 4 }} />   // duplicated complex sx
```

Targeting generated class names (`css-a1b2c3`) is brittle — they change
across builds. Use slot props or documented class names instead:

```tsx
<TextField slotProps={{ input: { 'aria-label': 'Search' } }} />
```

For repeated complex `sx`, extract a wrapper component or move it to a
theme override.

## Imports

Named imports from `@mui/material`. Per-file icon imports from
`@mui/icons-material`.

```tsx
import { Box, Button, Stack, Typography } from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
```

Never:

```tsx
import * as Mui from '@mui/material';
import * as Icons from '@mui/icons-material';
```

Namespace icon imports pull in thousands of components — always import
individually.

## Layout and composition

- `Stack` for one-dimensional layout with spacing.
- `Grid` (or CSS grid via `Box`) for two-dimensional layout.
- `Container` for page-width constraints.
- `Box` as a generic styled `div` — don't reach for it when a semantic
  MUI component would do.

Prefer MUI components where consistency matters (`Button` over
`<button>`, `Link` over `<a>`, `TextField` over `<input>`). Raw HTML is
fine for structural markup MUI doesn't model (`<main>`, `<section>`,
`<article>`).

Use the `component` prop to keep semantics correct without giving up
MUI styling:

```tsx
<Button component="a" href="/settings" variant="outlined">Settings</Button>
```

## Responsive design

Use responsive props and `sx` breakpoint objects. Don't hand-roll media
queries.

```tsx
<Stack
  direction={{ xs: 'column', sm: 'row' }}
  spacing={2}
  alignItems={{ xs: 'stretch', sm: 'center' }}
/>
```

## Theming and global defaults

Use `createTheme` for app-wide defaults and consistent variants:

```tsx
export const theme = createTheme({
  components: {
    MuiButton: {
      defaultProps: { disableElevation: true },
      styleOverrides: {
        root: ({ theme }) => ({
          borderRadius: theme.shape.borderRadius * 2,
          textTransform: 'none',
        }),
      },
    },
  },
});
```

Use theme `components` for:

- Default props across the whole app.
- Small global style overrides.
- Shared variants that represent product conventions.

Don't put large, highly specific component designs into theme overrides
— `components` config is not tree-shakable. Use a reusable wrapper
component instead.

## Reusable app components

When a pattern repeats, build a small wrapper:

```tsx
type SectionCardProps = { title: string; action?: ReactNode; children: ReactNode };

export function SectionCard({ title, action, children }: SectionCardProps) {
  return (
    <Card variant="outlined">
      <CardContent>
        <Stack spacing={2}>
          <Stack direction="row" justifyContent="space-between" alignItems="center" gap={2}>
            <Typography variant="h6" component="h2">{title}</Typography>
            {action}
          </Stack>
          {children}
        </Stack>
      </CardContent>
    </Card>
  );
}
```

Good wrappers:

- Reduce repeated configuration.
- Preserve common MUI props where useful.
- Don't hide important behavior.
- Provide escape hatches (`sx`, `slotProps`) when callers may need
  them.

## Loading, empty, and error states

Every data-driven component handles loading, empty, success, and
error.

```tsx
if (isLoading) return <Skeleton variant="rounded" height={160} />;
if (error) return <Alert severity="error">Unable to load account details.</Alert>;
if (!items.length) return <Alert severity="info">No items found.</Alert>;
```

- `Skeleton` for content placeholders (preserves layout).
- `CircularProgress` for indeterminate actions.
- `LinearProgress` for page or section loading.
- `Alert` for errors, warnings, and status messages.
- `Snackbar` for transient confirmations.

## Forms

Use MUI form components as controlled when the value participates in
validation or submission. For non-trivial forms, prefer a form library
— see `react-mui.md` for the integration pattern.

- Always provide `label`, `aria-label`, or `aria-labelledby`. A
  placeholder is not a label.
- Use `error` and `helperText` together; a blank helper text (`' '`)
  preserves layout when the error toggles.
- Use native input attributes: `type`, `required`, `autoComplete`,
  `inputMode`, `min`, `max`.
- Don't mix controlled and uncontrolled inputs in the same field —
  React will warn when an input switches.

## Accessibility

MUI is accessible *when used correctly* and easy to break when used
wrong.

- Interactive controls have visible text or accessible labels.
- Icon-only buttons (`IconButton`, menu items) need `aria-label`.
- Decorative icons use `aria-hidden`.
- Use `Button` / `IconButton`, not styled `<div onClick>`.
- Dialogs manage focus: moved to the dialog on open, trapped while
  open, restored on close. MUI `Dialog` does this — don't replace it
  with a custom-positioned `Box`.
- Don't strip ARIA attributes MUI ships with its components.
- Don't break heading order. Change the visual style with `variant`,
  not the semantic level (`<Typography variant="h6" component="h2">`).
- Don't communicate state with color alone — pair with an icon or
  text.

```tsx
<IconButton aria-label="Delete item" onClick={onDelete}>
  <DeleteOutlineIcon />
</IconButton>
```

## TypeScript

- Reuse MUI prop types when wrapping:
  `Omit<ButtonProps, 'variant' | 'color'> & { ... }`. `Omit` enforces
  design choices the wrapper makes.
- Let MUI generics flow through: `<Autocomplete<MyOption>>`, not
  casts.
- Forward refs for low-level reusable components.
- See `react.md` for general TypeScript rules and `react-mui.md` for
  MUI-specific event types.

## Performance

- Import only the components and icons you use.
- Code-split heavy routes or rarely-used UI with `React.lazy`.
- For large tables, evaluate MUI X Data Grid or virtualization — don't
  render thousands of `TableRow` directly.
- Don't keep expensive dialogs / menus / panels mounted unless
  preserving state is intentional.

## Do not

- Target generated class names (`.css-a1b2c3`).
- Scatter raw hex colors and pixel values.
- Duplicate complex `sx` across files instead of extracting.
- Overuse global theme overrides for highly specific cases.
- Hide important MUI props behind overly restrictive wrappers.
- Use icons in interactive controls without accessible labels.
- Assume a component is accessible just because it uses MUI.
