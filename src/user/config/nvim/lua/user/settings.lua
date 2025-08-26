-- TBK DOTFILE
-- nvim/lua/user/settings.lua
-- 


-- BASIC OPTIONS
-- see: https://neovim.io/doc/user/options.html#_3.-options-summary
vim.opt.clipboard:append("unnamedplus")

vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999

--vim.opt.textwidth = 90
vim.opt.colorcolumn = "91"

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.splitbelow = true
vim.opt.splitright = true


-- DIAGNOSTIC OPTIONS
-- see: https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.Opts
vim.diagnostic.config({
	signs = true,
	virtual_lines = {
		current_line = true,
	},
})


-- CUSTOM SHENANIGANS
-- see: https://neovim.io/doc/user/api.html#nvim_create_autocmd()

-- NO-TABS
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "yaml", "toml" },
	callback = function()
		vim.opt.expandtab = true
	end,
})

-- TAB = 4 spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "html", "css", "scss", "json", "yaml", "toml" },
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
	end,
})

-- TAB = 2 spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript" },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
	end,
})
