-- TBK DOTFILE
-- nvim/lua/user/plugins.lua
-- 

-- BOOTSTRAP PLUGIN MANAGER
-- see: https://lazy.folke.io/installation 
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- SETUP PLUGINS
-- see: https://lazy.folke.io/spec
require("lazy").setup({
	spec = {
		{ -- Treesitter (Parsing & Syntax)
			"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"
		},
		{ -- LSP (& Mason (Modular Language support))
			"neovim/nvim-lspconfig",
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
			},
		},
		{ -- CMP (Autocompletion)
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-cmdline",
				"hrsh7th/cmp-path",
			},
		},
		-- Themes
		{
			"rebelot/kanagawa.nvim",
			priority = 100,
			config = function()
				require("kanagawa").setup({
					compile = false,
					theme = wave,
					transparent = true,
				})
			end,
		},
		-- Other
		{
			"lervag/vimtex"
		},
	},
	install = {
		colorscheme = { "kanagawa-wave" }
	},
	checker = { enabled = true },
})

-- Set theme
vim.cmd("colorscheme kanagawa-wave")
