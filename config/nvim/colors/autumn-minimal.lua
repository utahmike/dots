-- autumn-minimal.lua
-- A minimal syntax highlighting scheme following Nikita Prokopov's principles
-- Inspired by autumn landscape colors
-- "If everything is highlighted, nothing is highlighted"

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'autumn-minimal'
vim.o.background = 'dark'

-- Color Palette from Autumn Photo
local colors = {
  -- Base colors
  bg = '#1a1814',           -- Dark brown-black (tree bark/shadows)
  fg = '#d4c5a9',           -- Warm tan (dried grass) - default text
  subtle = '#6b5d4f',       -- Muted brown (for keywords/punctuation)
  dimmed = '#9a8873',       -- Slightly dimmed (for operators)

  -- Strategic accent colors (only 4!)
  string = '#e8b339',       -- Golden yellow (autumn leaves)
  comment = '#e67e22',      -- Bright orange (fall foliage) - NOT grey!
  definition = '#9db668',   -- Lime green (bright leaves) - for function defs
  constant = '#c97a4a',     -- Rust orange (autumn rust) - for constants/numbers

  -- UI colors
  cursor_line = '#221f1a',
  selection = '#3d3529',
  visual = '#4a4034',
  line_nr = '#4a4034',
  cursor_line_nr = '#9a8873',
  sign_column = '#1a1814',

  -- Status/UI
  status_bg = '#0f0d0b',
  pmenu_bg = '#221f1a',
  pmenu_sel = '#3d3529',

  -- Diagnostic/Git
  error = '#c97a4a',
  warning = '#e8b339',
  info = '#7a9fb5',
  hint = '#9db668',
  add = '#9db668',
  change = '#e8b339',
  delete = '#c97a4a',
}

-- Helper function to set highlights
local function hi(group, opts)
  local cmd = 'highlight ' .. group
  if opts.fg then cmd = cmd .. ' guifg=' .. opts.fg end
  if opts.bg then cmd = cmd .. ' guibg=' .. opts.bg end
  if opts.gui then cmd = cmd .. ' gui=' .. opts.gui end
  if opts.guisp then cmd = cmd .. ' guisp=' .. opts.guisp end
  vim.cmd(cmd)
end

-- Editor UI
hi('Normal', { fg = colors.fg, bg = colors.bg })
hi('NormalFloat', { fg = colors.fg, bg = colors.bg })
hi('NormalNC', { fg = colors.fg, bg = colors.bg })
hi('SignColumn', { fg = colors.fg, bg = colors.sign_column })
hi('LineNr', { fg = colors.line_nr, bg = colors.bg })
hi('CursorLineNr', { fg = colors.cursor_line_nr, bg = colors.bg })
hi('CursorLine', { bg = colors.cursor_line })
hi('CursorColumn', { bg = colors.cursor_line })
hi('ColorColumn', { bg = colors.cursor_line })
hi('Visual', { bg = colors.visual })
hi('VisualNOS', { bg = colors.visual })
hi('Pmenu', { fg = colors.fg, bg = colors.pmenu_bg })
hi('PmenuSel', { fg = colors.fg, bg = colors.pmenu_sel })
hi('PmenuSbar', { bg = colors.pmenu_bg })
hi('PmenuThumb', { bg = colors.dimmed })

-- Window/Split
hi('VertSplit', { fg = colors.subtle, bg = colors.bg })
hi('WinSeparator', { fg = colors.subtle, bg = colors.bg })
hi('StatusLine', { fg = colors.fg, bg = colors.status_bg })
hi('StatusLineNC', { fg = colors.subtle, bg = colors.status_bg })
hi('TabLine', { fg = colors.subtle, bg = colors.status_bg })
hi('TabLineSel', { fg = colors.fg, bg = colors.bg })
hi('TabLineFill', { fg = colors.subtle, bg = colors.status_bg })

-- Cursor and Search
hi('Cursor', { fg = colors.bg, bg = colors.fg })
hi('CursorIM', { fg = colors.bg, bg = colors.fg })
hi('TermCursor', { fg = colors.bg, bg = colors.fg })
hi('TermCursorNC', { fg = colors.bg, bg = colors.subtle })
hi('Search', { fg = colors.bg, bg = colors.string })
hi('IncSearch', { fg = colors.bg, bg = colors.comment })
hi('CurSearch', { fg = colors.bg, bg = colors.comment })

-- Syntax: STRATEGIC HIGHLIGHTING ONLY
-- Following Tonsky's principle: highlight only what helps navigate code

-- HIGHLIGHTED: Comments (important, should stand out!)
hi('Comment', { fg = colors.comment })
hi('SpecialComment', { fg = colors.comment })
hi('Todo', { fg = colors.comment, gui = 'bold' })

-- HIGHLIGHTED: Strings (data references)
hi('String', { fg = colors.string })
hi('Character', { fg = colors.string })

-- HIGHLIGHTED: Constants and Numbers (reference points)
hi('Constant', { fg = colors.constant })
hi('Number', { fg = colors.constant })
hi('Float', { fg = colors.constant })
hi('Boolean', { fg = colors.constant })

-- HIGHLIGHTED: Function Definitions (reveals structure)
hi('Function', { fg = colors.definition })

-- NOT HIGHLIGHTED: Keywords (structural, rarely searched)
hi('Keyword', { fg = colors.subtle })
hi('Statement', { fg = colors.subtle })
hi('Conditional', { fg = colors.subtle })
hi('Repeat', { fg = colors.subtle })
hi('Label', { fg = colors.subtle })
hi('Operator', { fg = colors.dimmed })
hi('Exception', { fg = colors.subtle })

-- NOT HIGHLIGHTED: Variable usage (most common, would create noise)
hi('Identifier', { fg = colors.fg })
hi('Variable', { fg = colors.fg })

-- NOT HIGHLIGHTED: Types (structural information)
hi('Type', { fg = colors.fg })
hi('StorageClass', { fg = colors.subtle })
hi('Structure', { fg = colors.subtle })
hi('Typedef', { fg = colors.subtle })

-- Preprocessor
hi('PreProc', { fg = colors.subtle })
hi('Include', { fg = colors.subtle })
hi('Define', { fg = colors.subtle })
hi('Macro', { fg = colors.subtle })
hi('PreCondit', { fg = colors.subtle })

-- Special
hi('Special', { fg = colors.dimmed })
hi('SpecialChar', { fg = colors.constant })
hi('Tag', { fg = colors.definition })
hi('Delimiter', { fg = colors.dimmed })
hi('Debug', { fg = colors.comment })

-- Treesitter Highlights
-- Only highlight what matters for navigation
hi('@comment', { fg = colors.comment })
hi('@string', { fg = colors.string })
hi('@string.documentation', { fg = colors.comment })
hi('@number', { fg = colors.constant })
hi('@boolean', { fg = colors.constant })
hi('@constant', { fg = colors.constant })
hi('@constant.builtin', { fg = colors.constant })
hi('@function', { fg = colors.definition })
hi('@function.builtin', { fg = colors.definition })
hi('@function.method', { fg = colors.definition })
hi('@function.call', { fg = colors.fg })  -- Calls NOT highlighted
hi('@method.call', { fg = colors.fg })    -- Calls NOT highlighted
hi('@keyword', { fg = colors.subtle })
hi('@keyword.function', { fg = colors.subtle })
hi('@keyword.operator', { fg = colors.subtle })
hi('@keyword.return', { fg = colors.subtle })
hi('@operator', { fg = colors.dimmed })
hi('@variable', { fg = colors.fg })
hi('@variable.builtin', { fg = colors.fg })
hi('@parameter', { fg = colors.fg })
hi('@property', { fg = colors.fg })
hi('@field', { fg = colors.fg })
hi('@type', { fg = colors.fg })
hi('@type.builtin', { fg = colors.fg })
hi('@namespace', { fg = colors.fg })
hi('@punctuation.bracket', { fg = colors.dimmed })
hi('@punctuation.delimiter', { fg = colors.dimmed })
hi('@tag', { fg = colors.definition })
hi('@tag.attribute', { fg = colors.fg })
hi('@tag.delimiter', { fg = colors.dimmed })

-- Markdown
hi('@markup.heading', { fg = colors.definition, gui = 'bold' })
hi('@markup.strong', { gui = 'bold' })
hi('@markup.italic', { gui = 'italic' })
hi('@markup.link', { fg = colors.string })
hi('@markup.link.url', { fg = colors.string })
hi('@markup.raw', { fg = colors.constant })

-- LSP Semantic Tokens
hi('@lsp.type.function', { fg = colors.definition })
hi('@lsp.type.method', { fg = colors.definition })
hi('@lsp.type.variable', { fg = colors.fg })
hi('@lsp.type.parameter', { fg = colors.fg })
hi('@lsp.type.property', { fg = colors.fg })
hi('@lsp.type.namespace', { fg = colors.fg })

-- Diagnostics
hi('DiagnosticError', { fg = colors.error })
hi('DiagnosticWarn', { fg = colors.warning })
hi('DiagnosticInfo', { fg = colors.info })
hi('DiagnosticHint', { fg = colors.hint })
hi('DiagnosticUnderlineError', { guisp = colors.error, gui = 'underline' })
hi('DiagnosticUnderlineWarn', { guisp = colors.warning, gui = 'underline' })
hi('DiagnosticUnderlineInfo', { guisp = colors.info, gui = 'underline' })
hi('DiagnosticUnderlineHint', { guisp = colors.hint, gui = 'underline' })

-- Git Signs
hi('GitSignsAdd', { fg = colors.add })
hi('GitSignsChange', { fg = colors.change })
hi('GitSignsDelete', { fg = colors.delete })
hi('DiffAdd', { fg = colors.add, bg = colors.bg })
hi('DiffChange', { fg = colors.change, bg = colors.bg })
hi('DiffDelete', { fg = colors.delete, bg = colors.bg })
hi('DiffText', { fg = colors.change, bg = colors.cursor_line })

-- Telescope
hi('TelescopeNormal', { fg = colors.fg, bg = colors.bg })
hi('TelescopeBorder', { fg = colors.subtle, bg = colors.bg })
hi('TelescopePromptNormal', { fg = colors.fg, bg = colors.bg })
hi('TelescopePromptBorder', { fg = colors.subtle, bg = colors.bg })
hi('TelescopePromptTitle', { fg = colors.definition, bg = colors.bg })
hi('TelescopePreviewTitle', { fg = colors.definition, bg = colors.bg })
hi('TelescopeResultsTitle', { fg = colors.definition, bg = colors.bg })
hi('TelescopeSelection', { fg = colors.fg, bg = colors.visual })
hi('TelescopeMatching', { fg = colors.string, gui = 'bold' })

-- Which-key
hi('WhichKey', { fg = colors.definition })
hi('WhichKeyGroup', { fg = colors.comment })
hi('WhichKeyDesc', { fg = colors.fg })
hi('WhichKeySeparator', { fg = colors.subtle })
hi('WhichKeyFloat', { bg = colors.bg })

-- Misc
hi('Directory', { fg = colors.definition })
hi('Title', { fg = colors.definition, gui = 'bold' })
hi('Question', { fg = colors.comment })
hi('MoreMsg', { fg = colors.comment })
hi('ModeMsg', { fg = colors.comment })
hi('NonText', { fg = colors.subtle })
hi('SpecialKey', { fg = colors.subtle })
hi('Whitespace', { fg = colors.subtle })
hi('Conceal', { fg = colors.subtle })
hi('MatchParen', { fg = colors.comment, bg = colors.visual, gui = 'bold' })
hi('Error', { fg = colors.error })
hi('ErrorMsg', { fg = colors.error })
hi('WarningMsg', { fg = colors.warning })
hi('Folded', { fg = colors.subtle, bg = colors.cursor_line })
hi('FoldColumn', { fg = colors.subtle, bg = colors.bg })
