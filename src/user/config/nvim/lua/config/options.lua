-- see: https://neovim.io/doc/user/options.html#_3.-options-summary
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.clipboard:append("unnamedplus")
vim.opt.undofile = true
vim.opt.mouse = "a"

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tabs by default; per-filetype overrides live in after/ftplugin/
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999

--vim.opt.textwidth = 90
vim.opt.colorcolumn = "91"

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.splitbelow = true
vim.opt.splitright = true
