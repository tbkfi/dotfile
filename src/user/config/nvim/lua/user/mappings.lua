-- TBK DOTFILE
-- nvim/lua/user/mappings.lua
-- 

vim.g.mapleader = ' ' 
vim.g.maplocalleader = ','

vim.keymap.set('v', "<Tab>", ">gv", { noremap = true, silent = true })
vim.keymap.set('v', "<S-Tab>", "<gv", { noremap = true, silent = true })

-- LSP (plugin-dependant)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)


local diagnostics_visible = true
vim.keymap.set('n', "<Leader>td", function()
    diagnostics_visible = not diagnostics_visible
    if diagnostics_visible then
        vim.diagnostic.enable(0)
    else
        vim.diagnostic.disable(0)
    end
end, { noremap = true, silent = true, desc = "Toggle LSP diagnostics" })
