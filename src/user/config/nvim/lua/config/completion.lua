-- Native completion: 'autocomplete' shows the popup while typing; the "o" source in 'complete'
-- pulls LSP candidates through 'omnifunc' (set by Nvim when a server attaches).
-- Accept with <C-y>; <C-n>/<C-p>/<Tab>/<S-Tab> move; <C-e> dismisses. No plugin involved.
vim.opt.autocomplete = true
vim.opt.complete:append("o")
vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "User: LSP completion (also on server trigger characters, e.g. '.', '->', '::')",
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- <Tab>/<S-Tab>: jump in an active snippet, else move through the popup, else insert a tab
vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
	elseif vim.fn.pumvisible() == 1 then
		return "<C-n>"
	else
		return "<Tab>"
	end
end, { expr = true, desc = "Snippet jump / next completion / tab" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	if vim.snippet.active({ direction = -1 }) then
		vim.snippet.jump(-1)
	elseif vim.fn.pumvisible() == 1 then
		return "<C-p>"
	else
		return "<S-Tab>"
	end
end, { expr = true, desc = "Snippet back / previous completion / shift-tab" })
