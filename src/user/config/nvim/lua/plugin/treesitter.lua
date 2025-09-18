-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "bash", "c", "cpp", "python", "html", "javascript", "lua", },
			sync_install = true,
			highlight = { enable = true },
		})
	end,
}
