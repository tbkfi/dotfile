local lspconfig = require('lspconfig')

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })


local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

require('mason').setup()
require('mason-lspconfig').setup {
	automatic_installation = true,
	ensure_installed = {
		"clangd",
		"pylsp",
		"lua_ls",
	}
}
lspconfig.clangd.setup({
	on_attach = on_attach,
	cmd = { vim.fn.expand('~') .. "/.local/share/nvim/mason/bin/clangd" }, -- use Mason clangd
})
lspconfig.pylsp.setup({
	on_attach = on_attach,
})
lspconfig.lua_ls.setup({
	on_attach = on_attach,
})

-- keybinds
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
