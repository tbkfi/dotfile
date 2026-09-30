-- Current Target: Neovim 0.12.5
if vim.fn.has("nvim-0.12") == 0 then
	vim.notify("This config requires Neovim 0.12+ (running " .. tostring(vim.version()) .. ")", vim.log.levels.ERROR)
	return
end

require("config.options")
require("config.keymaps")
require("config.pack")
require("config.treesitter")
require("config.mason")
require("config.lsp")
require("config.completion")
