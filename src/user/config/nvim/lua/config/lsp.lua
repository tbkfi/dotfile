-- Native LSP: configs are merged from nvim-lspconfig's lsp/*.lua; we only override what we need.
-- Binaries come from Mason (config/mason.lua), which prepends its bin dir to PATH.
-- Built-in mappings: K hover, grn rename, gra code action, grr references, gri implementation,
-- grt type definition, gO document symbols, <C-]> definition (via tagfunc), <C-s> signature help.
vim.o.winborder = "rounded"

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

local diagnostics_visible = true
vim.keymap.set("n", "<leader>td", function()
	diagnostics_visible = not diagnostics_visible
	vim.diagnostic.enable(diagnostics_visible)
end, { desc = "Toggle diagnostics" })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "User: buffer-local LSP mappings",
	callback = function(ev)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "LSP definition" })
	end,
})

-- C/C++ (x86 + embedded ARM). Needs compile_commands.json in the project (clangd also finds
-- it in a parent's build/ dir). --query-driver whitelists cross-compilers that clangd may run
-- to learn their real system include paths; without a match it silently falls back to the
-- host's headers (wrong libc). Covers distro arm-none-eabi-* and the Zephyr SDK.
local zephyr_sdk = vim.env.ZEPHYR_SDK_INSTALL_DIR or (vim.env.HOME .. "/zephyr-sdk*")
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--query-driver=" .. table.concat({
			"/usr/bin/arm-none-eabi-*",
			"/usr/local/bin/arm-none-eabi-*",
			zephyr_sdk .. "/**/bin/*-gcc",
			zephyr_sdk .. "/**/bin/*-g++",
		}, ","),
	},
})

-- pyright does hover/definitions/types; ruff does lint/format/organize-imports.
vim.lsp.config("ruff", {
	on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
			diagnostics = { globals = { "vim" } },
		},
	},
})

vim.lsp.enable({
	"clangd",
	"pyright",
	"ruff",
	"bashls",
	"lua_ls",
	"rust_analyzer",
	"gopls",
	"texlab",
	"html",
	"cssls",
	"jsonls",
	"ts_ls",
	"robotcode", -- Robot Framework; resolves libraries from $VIRTUAL_ENV if set
})
