# React + MUI combined best practices

Sharp edges that only appear when React and MUI are used together. For
React rules see `react.md`; for MUI rules see `mui.md`. This file
assumes both are loaded.

If a project tags only `react-mui`, prefer updating its `## Stack`
section to list `react` and `mui` separately so the underlying guidance
loads too — composite tags are reserved for genuinely combined
concerns.

## Forms

Prefer `react-hook-form` with MUI's `Controller` for validation-aware
forms.

```tsx
<Controller
  name="email"
  control={control}
  rules={{ required: 'Email is required' }}
  render={({ field, fieldState }) => (
    <TextField
      {...field}
      label="Email"
      error={Boolean(fieldState.error)}
      helperText={fieldState.error?.message ?? ' '}
      autoComplete="email"
      fullWidth
    />
  )}
/>
```

- Submit buttons must guard against double-submit — disable while
  pending and show a clear pending state.
- Don't lose form state across unrelated re-renders. If the form
  unmounts, state goes with it; lift it or use the form library's
  state.
- Parse explicitly: number inputs come back as strings, dates as
  `Date` or `null`, selects as the option's `value` not its label,
  booleans from checkboxes as booleans.
- Validate at the right time: on blur for individual fields, on submit
  for cross-field rules. Validating on every keystroke is noisy.
- Wire error text to the field with MUI's `error` + `helperText`
  props, and `aria-describedby` if you're rolling your own message
  element.

## Autocomplete with object options

`Autocomplete<T>` defaults to reference equality, so passing the same
option object from a different source (a fresh fetch, a re-render)
makes the selection appear broken.

```tsx
<Autocomplete<User>
  options={users}
  value={selectedUser}
  onChange={(_, value) => setSelectedUser(value)}
  isOptionEqualToValue={(option, value) => option.id === value.id}
  getOptionLabel={(option) => option.name}
  getOptionKey={(option) => option.id}
  renderInput={(params) => <TextField {...params} label="User" />}
/>
```

Always provide `isOptionEqualToValue` when options are objects. Set
`getOptionLabel` and `getOptionKey` when the defaults don't fit.

## TypeScript event types

Use MUI's event types for MUI components, not the raw DOM equivalents:

- `SelectChangeEvent<T>` for `Select`'s `onChange`, not
  `React.ChangeEvent`.
- Let MUI's generics flow through (`Autocomplete<MyOption>`,
  `DataGrid<MyRow>`) rather than casting at the call site.
- For `TextField`, the `onChange` handler is
  `React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>` — MUI
  passes the native event through unchanged.
