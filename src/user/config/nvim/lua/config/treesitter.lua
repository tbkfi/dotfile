-- Parsers and queries come from nvim-treesitter (main branch); highlighting itself is native.
-- Parsers are compiled locally: needs the `tree-sitter` CLI and a C compiler on PATH.
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local parsers = {
	-- Systems
	"c", "cpp", "asm", "cuda", "rust", "go",
	-- Scripting
	"python", "requirements", "bash", "lua", "luadoc",
	-- Web
	"html", "css", "scss", "javascript", "jsdoc", "typescript", "tsx", "json", "graphql",
	-- Test / build
	"robot", "make", "cmake", "dockerfile",
	-- Docs / typesetting
	"latex", "bibtex", "markdown", "markdown_inline", "vimdoc",
	-- Data / config
	"yaml", "toml", "ini", "xml", "csv", "jq",
	-- Git / misc
	"diff", "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
	"gpg", "ssh_config", "regex", "vim", "query",
}

if vim.fn.executable("tree-sitter") == 0 then
	vim.notify("tree-sitter CLI not found; skipping parser installation", vim.log.levels.WARN)
else
	-- Asynchronous; already-installed parsers are skipped.
	require("nvim-treesitter").install(parsers)
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: enable treesitter highlighting and indentation",
	callback = function(ctx)
		-- Fails quietly if no parser exists for this filetype
		local started = pcall(vim.treesitter.start, ctx.buf)

		-- nvim-treesitter's indentexpr is experimental; skip where it is known to be unstable
		local no_ts_indent = { "zsh", "bash", "markdown", "javascript", "typescript", "typescriptreact" }
		if started and not vim.list_contains(no_ts_indent, ctx.match) then
			vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
		end
	end,
})

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: highlights for Treesitter comments",
	callback = function()
		-- Keep LSP semantic tokens from overriding comment highlights
		vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
		vim.api.nvim_set_hl(0, "@comment.bold", { bold = true })
	end,
})
