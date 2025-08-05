-- nvim/lua/user/settings.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999

vim.opt.textwidth = 90
vim.opt.colorcolumn = "91"

vim.opt.clipboard:append("unnamedplus")

vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.splitbelow = true
vim.opt.splitright = true


-- NO TAB
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "yaml", "toml" },
	callback = function()
		vim.opt.expandtab = true
	end,
})

-- TAB-4
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "html", "css", "scss", "json", "yaml", "toml" },
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
	end,
})


-- TAB-2
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript" },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
	end,
})
