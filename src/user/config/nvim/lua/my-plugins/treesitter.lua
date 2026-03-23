return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"mason-org/mason.nvim",
	},
	lazy = false,
	branch = "main",
	build = ":TSUpdate",

	config = function()
		-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
		local ts = require("nvim-treesitter")
		local parsers = {
			-- Core
			"asm",
			"c",
			"cpp",
			"python",
			"requirements",
			"bash",
			"lua",
			"rust",
			"go",
			"javascript",
			"typescript",
			"latex",
			"cuda",
			-- Tooling
			"make",
			"cmake",
			"regex",
			"diff",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"gpg",
			"ssh_config",
			"vim",
			"query",
			"jq",
			"dockerfile",
			-- Doc
			"markdown",
			"markdown_inline",
			"vimdoc",
			"luadoc",
			-- Data
			"html",
			"css",
			"scss",
			"json",
			"csv",
			"ini",
			"yaml",
			"toml",
			"xml",
			"bibtex"
		}

		ts.install(parsers)
		ts.update()

		-- YOINK: https://github.com/chrisgrieser/.config/blob/main/nvim/lua/plugin-specs/treesitter.lua
		-- auto-start highlights & indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting",
			callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start, ctx.buf) -- errors for filetypes with no parser

				-- indent
				local dontUseTreesitterIndent = { "zsh", "bash", "markdown", "javascript" }
				if hasStarted and not vim.list_contains(dontUseTreesitterIndent, ctx.match) then
					vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
				end
			end,
		})

		-- comments parser
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: highlights for the Treesitter `comments` parser",
			callback = function()
				-- FIX todo-comments in languages where LSP overwrites their highlight
				-- https://github.com/stsewd/tree-sitter-comment/issues/22
				-- https://github.com/LuaLS/lua-language-server/issues/1809
				vim.api.nvim_set_hl(0, "@lsp.type.comment", {})

				-- Define `@comment.bold` for `queries/comment/highlights.scm`
				vim.api.nvim_set_hl(0, "@comment.bold", { bold = true })
			end,
		})
	end
}
