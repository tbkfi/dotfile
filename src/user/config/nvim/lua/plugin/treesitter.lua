require('nvim-treesitter.configs').setup({
	ensure_installed = {
		"bash",
		"c",
		"cpp",
		"python",
		"lua",
	},
	highlight = {
		enable = true,
	},
})
