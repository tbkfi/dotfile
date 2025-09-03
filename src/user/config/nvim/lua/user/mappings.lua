-- Leaders
vim.g.mapleader = ' ' 
vim.g.maplocalleader = ','

-- Indentation
vim.keymap.set('v', "<Tab>", ">gv", { noremap = true, silent = true })
vim.keymap.set('v', "<S-Tab>", "<gv", { noremap = true, silent = true })
