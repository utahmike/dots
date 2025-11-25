-- OpenSCAD filetype settings
-- OpenSCAD uses C-style comments: // for single-line, /* */ for multi-line
vim.bo.commentstring = "// %s"

-- Match LSP formatter: 2-space indentation
vim.bo.tabstop = 2        -- Display width of tab character
vim.bo.shiftwidth = 2     -- Indentation width for auto-indent
vim.bo.softtabstop = 2    -- Number of spaces inserted/removed on Tab/Backspace
vim.bo.expandtab = true   -- Use spaces instead of tabs (explicit for clarity)
