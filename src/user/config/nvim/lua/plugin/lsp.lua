return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim", -- LSP Server manager
		"hrsh7th/cmp-nvim-lsp",    -- Autocompletion for LSP
	},
	config = function()
		local mason = require("mason")

		mason.setup()

		local mason_registry = require("mason-registry")
		local servers = {
			"bash-language-server",
			"clangd",
			"python-lsp-server",
			"html-lsp",
			"css-lsp",
			"typescript-language-server",
			"lua-language-server",
		}
		-- Install servers
		for _, server in ipairs(servers) do
			if not mason_registry.is_installed(server) then
				mason_registry.get_package(server):install()
			end
		end

		-- Diagnostics configuration
		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Style borders
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

		-- Toggle Diagnostics
		local diagnostics_visible = true
		vim.keymap.set("n", "<leader>td", function()
			diagnostics_visible = not diagnostics_visible
			vim.diagnostic.enable(diagnostics_visible)
		end, { noremap = true, silent = true, desc = "Toggle LSP diagnostics" })

		-- Mappings
		local opts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

		-- Enable Language Servers (Neovim +11.0)
		-- see: ':help lspconfig-all'
		-- note: uses the provided lsp-configurations in lspconfig!
		vim.lsp.enable('bashls')
		vim.lsp.enable('clangd')
		vim.lsp.enable('pylsp')
		vim.lsp.enable('html')
		vim.lsp.enable('cssls')
		vim.lsp.enable('ts_ls')
		vim.lsp.enable('lua_ls')
	end,
}
