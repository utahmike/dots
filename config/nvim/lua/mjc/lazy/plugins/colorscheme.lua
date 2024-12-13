return {
  "savq/melange-nvim",
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true
    vim.cmd.colorscheme "melange"
  end,
}
