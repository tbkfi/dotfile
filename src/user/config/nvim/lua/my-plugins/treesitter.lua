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
			-- TypeScript & Web Ecosystem
			"typescript",
			"tsx",
			"javascript",
			"jsdoc",
			"html",
			"css",
			"scss",
			"json",
			"graphql",
			-- Core & Languages
			"asm",
			"c",
			"cpp",
			"robot",
			"python",
			"requirements",
			"bash",
			"lua",
			"rust",
			"go",
			"latex",
			"cuda",
			-- Tooling & Config
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
			-- Docs & Data
			"markdown",
			"markdown_inline",
			"vimdoc",
			"luadoc",
			"csv",
			"ini",
			"yaml",
			"toml",
			"xml",
			"bibtex",
		}

		-- Install parsers asynchronously without blocking startup
		ts.install(parsers)

		-- Auto-start highlights & selective indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting and indentation",
			callback = function(ctx)
				-- Enable Treesitter highlighting (fails gracefully if parser is missing)
				local has_started = pcall(vim.treesitter.start, ctx.buf)

				-- Disable TS indent for filetypes known to have unstable Treesitter indenting
				local dont_use_ts_indent = { "zsh", "bash", "markdown", "javascript", "typescript", "typescriptreact" }
				if has_started and not vim.list_contains(dont_use_ts_indent, ctx.match) then
					vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
				end
			end,
		})

		-- Comment highlighting tweaks
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: highlights for Treesitter comments",
			callback = function()
				-- Prevent LSP semantic tokens from overriding comment highlights (e.g. todo-comments)
				vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
				vim.api.nvim_set_hl(0, "@comment.bold", { bold = true })
			end,
		})
	end,
}
