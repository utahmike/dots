vim.g.mapleader = " "

local keymap = vim.keymap

-- Use control-direction to navigate splits.
keymap.set("n", "<C-j>", "<c-w>j")
keymap.set("n", "<C-h>", "<c-w>h")
keymap.set("n", "<C-k>", "<c-w>k")
keymap.set("n", "<C-l>", "<c-w>l")

-- Quick binding to the main init.lua file.
keymap.set("n", "<Leader>.", ":tabnew $MYVIMRC<cr>")

-- Close all windows but the one the cursor is in.
keymap.set("n", "<Leader>1", ":only<CR>")

-- Git mappings. Will fail at call time if fugitive is not
-- installed.
keymap.set("n", "<leader>gs", ":Git<cr>")
keymap.set("n", "<leader>gb", ":Git blame<cr>")
