-- Plugins via native vim.pack. Revisions are pinned in nvim-pack-lock.json (commit it);
-- `vim.pack.update()` shows a reviewable diff before anything changes.
local gh = function(repo) return "https://github.com/" .. repo end

vim.pack.add({
	gh("loctvl842/monokai-pro.nvim"),
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" }, -- default branch is the legacy 'master'
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
})

-- Colorscheme
local ok, monokai = pcall(require, "monokai-pro")
if ok then
	monokai.setup({
		transparent_background = true,
		terminal_colors = false,
		devicons = true,
		-- classic | octagon | pro | machine | ristretto | spectrum
		filter = "ristretto",
	})
	vim.cmd.colorscheme("monokai-pro")
end
