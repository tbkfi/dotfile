-- settings
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_syntax_conceal = 1
vim.g.vimtex_fold_enabled = 1
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_autostart = 1

-- mappings
vim.keymap.set('n', '<LocalLeader>lc', ':VimtexCompile<CR>', { noremap = true, silent = true, desc = "Compile LaTeX" })
vim.keymap.set('n', '<LocalLeader>lv', ':VimtexView<CR>', { noremap = true, silent = true, desc = "View PDF" })
vim.keymap.set('n', '<LocalLeader>lq', ':VimtexToc<CR>', { noremap = true, silent = true, desc = "Open LaTeX TOC" })
vim.keymap.set('n', '<LocalLeader>le', ':cnext<CR>', { noremap = true, silent = true, desc = "Next error" })
vim.keymap.set('n', '<LocalLeader>lE', ':cprev<CR>', { noremap = true, silent = true, desc = "Previous error" })
vim.keymap.set('n', '<LocalLeader>lf', ':VimtexFold<CR>', { noremap = true, silent = true, desc = "Toggle folding" })
