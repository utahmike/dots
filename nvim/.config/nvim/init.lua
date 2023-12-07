vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "sainnhe/everforest",
  "dracula/vim",
  "lewis6991/gitsigns.nvim",
  "savq/melange-nvim",
  "shaunsingh/nord.nvim",
  "morhetz/gruvbox",
  "aktersnurra/no-clown-fiesta.nvim",
  "kvrohit/rasmus.nvim",

  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  "nvim-tree/nvim-tree.lua",
  { "catppuccin/nvim", name = "catppuccin" },

  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = "TSUpdate"
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" }
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },


  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/nvim-cmp",
  "L3MON4D3/LuaSnip",
  "rafamadriz/friendly-snippets",
})

require 'luasnip'.setup()

local cmp = require 'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'friendly-snippets' },
      { name = 'luasnip' },
    },
    {
      { name = 'buffer' },
    })
})


require('nvim-treesitter.configs').setup {
  textobjects = {
    select = {
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true
      },
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
  },
}

--------------------------------------------------------------------------------
--
-- General (n)vim configurations
--
--------------------------------------------------------------------------------

-- Show numbers in the left gutter, and make them relative to the cursor.
vim.opt.nu = true
vim.opt.relativenumber = true

-- Tab stops are 2 characters rather than 4, and tabs should be expanded into
-- spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

-- Searches should be incremental, and the highlighting of found text should
-- not linger outside of the search mode.
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Update time (in ms) for calling plug-ins that monitor the contents of the
-- buffer to work. For example, the language server.
vim.opt.updatetime = 50

--------------------------------------------------------------------------------
--
-- Symbols for the diagnostic markers in the gutter and elsewhere. To use these,
-- you need to have a patched font installed an in use on your terminal.
--
-- https://www.nerdfonts.com/
--
--------------------------------------------------------------------------------
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

--------------------------------------------------------------------------------
--
-- Custom Keyboard Bindings I prefer
--
--------------------------------------------------------------------------------

-- Shortcuts to longer function names functions.
local keymap = vim.keymap.set
local telescope = require('telescope.builtin')
local lspconfig = require('lspconfig')

-- Use control-direction to navigate splits.
keymap("n", '<C-j>', '<c-w>j')
keymap("n", '<C-h>', '<c-w>h')
keymap("n", '<C-k>', '<c-w>k')
keymap("n", '<C-l>', '<c-w>l')

-- Quick binding to the this file.
keymap("n", '<Leader>.', ':tabnew $MYVIMRC<cr>')

-- Close all windows but the one the cursor is in.
keymap("n", '<Leader>1', ':only<CR>')

-- Open the file explorer.
keymap("n", '<Leader>t', ':NvimTreeToggle<CR>')

-- Git mappings. Will fail at call time if fugitive is not
-- installed.
keymap("n", 'gs', ':Git<cr>')
keymap("n", 'gb', ':Git blame<cr>')

-- Telescope bindings.
keymap('n', '<C-p>', telescope.find_files, {})
keymap('n', '<leader>/', telescope.live_grep, {})

--------------------------------------------------------------------------------
--
-- Load and configure packages that need no custom configuration.
--
--------------------------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup()
require("nvim-tree").setup()

require("gitsigns").setup {
  signcolumn = true,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
    delay = 500,
  }
}


require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = " >  ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.60,
        results_width = 0.40,
      },
      vertical = {
        mirror = false
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
  },

  extensions_list = { "themes", "terms" },
}


--------------------------------------------------------------------------------
--
-- Setup language servers.
--
--------------------------------------------------------------------------------
lspconfig.rust_analyzer.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        allFeatures = true,
        overrideCommand = {
          'cargo', 'clippy', '--workspace', '--message-format=json',
          '--all-targets', '--all-features'
        }
      }
    },
  },
}

require 'lspconfig'.lua_ls.setup {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
            }
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}




-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {

  -- group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    keymap("n", "gr", telescope.lsp_references, opts)
    keymap("n", "gi", telescope.lsp_implementations, opts)

    keymap('n', 'gd', vim.lsp.buf.definition, opts)
    keymap("n", "gy", vim.lsp.buf.type_definition, opts)

    keymap('n', 'K', vim.lsp.buf.hover, opts)
    keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    keymap('n', '<space>rn', vim.lsp.buf.rename, opts)
    keymap('n', 'gr', vim.lsp.buf.references, opts)

    keymap('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)

    keymap("n", "<leader>D", telescope.diagnostics, opts)
    keymap("n", "gj", vim.diagnostic.goto_next, opts)
    keymap("n", "gk", vim.diagnostic.goto_prev, opts)
    keymap("n", "<leader>D", telescope.diagnostics, opts)
  end,
})

-- Set the preferred color scheme.
vim.cmd [[colorscheme melange]]
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format{async = false}]]
