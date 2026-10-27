-- Indentation
vim.keymap.set("x", "<Tab>", ">gv", { silent = true })
vim.keymap.set("x", "<S-Tab>", "<gv", { silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Formatting: whatever the attached server offers (clangd -> .clang-format, ruff, ...).
-- `gq` also works on ranges via 'formatexpr'. Opt-in only; no format-on-save.
vim.keymap.set({ "n", "x" }, "<leader>f", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer/selection (LSP)" })
