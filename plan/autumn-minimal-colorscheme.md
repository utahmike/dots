# Autumn Minimal Color Scheme Design

## Design Philosophy
Following Nikita Prokopov's (tonsky) principles: "If everything is highlighted, nothing is highlighted."

This scheme uses minimal, strategic colors inspired by the autumn landscape photo, highlighting only what matters for quick code navigation.

## Color Palette (Extracted from Autumn Photo)

### Base Colors
- **Background**: `#1a1814` (dark brown-black, like tree bark/shadows)
- **Foreground**: `#d4c5a9` (warm tan, like dried grass - default text)
- **Subtle**: `#6b5d4f` (muted brown, for keywords/punctuation)

### Accent Colors (Strategic Highlighting Only)
- **Golden Yellow**: `#e8b339` (autumn leaves - for strings)
- **Bright Orange**: `#e67e22` (fall foliage - for comments, to make them stand out)
- **Lime Green**: `#9db668` (bright leaves - for top-level definitions/functions)
- **Rust Orange**: `#c97a4a` (autumn rust - for constants/numbers)

## Highlighting Strategy (Tonsky's Principles)

### HIGHLIGHT (Strategic, Memorable)
1. **Strings** → Golden Yellow `#e8b339`
   - Important data references
   - Visual anchor points

2. **Comments** → Bright Orange `#e67e22`
   - NOT grey! Comments add value and should stand out
   - Bold color for explanatory comments

3. **Top-level Definitions** → Lime Green `#9db668`
   - Function definitions, class definitions
   - Reveals code structure at a glance
   - Helps locate where things are defined

4. **Constants & Numbers** → Rust Orange `#c97a4a`
   - Used sparingly as reference points
   - Includes booleans, null/nil

### DO NOT HIGHLIGHT (Keep Subtle)
1. **Keywords** → Subtle Brown `#6b5d4f` (same as foreground or dimmed)
   - `if`, `else`, `class`, `function`, `return`, `import`
   - Rarely searched for directly
   - Part of code structure, not content

2. **Variable Usage** → Foreground `#d4c5a9`
   - Most common element (75% of code)
   - Highlighting would create noise
   - Should blend with normal text

3. **Function Calls** → Foreground `#d4c5a9`
   - Very common, would clutter if highlighted
   - Only definition is highlighted, not usage

4. **Punctuation** → Slightly dimmed `#9a8873`
   - Brackets, parentheses, semicolons
   - Subtle, not distracting

## Terminal Colors (for Wezterm)

Using the same palette for terminal consistency:

- **Black/Dark**: `#1a1814` (background)
- **Red**: `#c97a4a` (rust, for errors)
- **Green**: `#9db668` (lime, for success)
- **Yellow**: `#e8b339` (golden, for warnings)
- **Blue**: `#7a9fb5` (muted blue-gray from sky)
- **Magenta**: `#b08968` (brown-purple, subdued)
- **Cyan**: `#8faa8f` (sage green)
- **White**: `#d4c5a9` (warm tan)

Bright variants: slightly lighter versions of each.

## Neovim Syntax Groups

```
Normal: #d4c5a9 on #1a1814
Comment: #e67e22 (bright orange - important!)
String: #e8b339 (golden yellow)
Number: #c97a4a (rust orange)
Boolean: #c97a4a (rust orange)
Constant: #c97a4a (rust orange)
Function: #9db668 (lime green - definitions only)
Identifier: #d4c5a9 (foreground - variable usage)
Keyword: #6b5d4f (subtle brown - structural)
Operator: #9a8873 (slightly dimmed)
Type: #d4c5a9 (foreground - not highlighted)
```

## Key Principles Applied

1. **Minimal Palette**: Only 4 accent colors (can be memorized)
2. **Strategic Highlighting**: Only strings, comments, definitions, constants
3. **High Contrast**: Dark background enables vibrant colors
4. **Natural Feel**: Warm, earthy tones from autumn landscape
5. **Cognitive Load**: Most code (variables, keywords) stays subtle

## Expected Benefits

- Quick location of string literals
- Comments stand out (as they should)
- Function definitions easy to spot
- Less visual noise
- Faster code scanning
- Reduced eye strain
