-- settings
vim.g.mkdp_browser = "firefox"
vim.g.mkdp_port = 8181
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_filetypes = { "markdown" }

vim.g.mkdp_theme = "dark"
vim.g.mkdp_marked = "marked" -- markdown renderer program

-- mappings
vim.api.nvim_set_keymap('n', '<localleader>mp', ':MarkdownPreviewToggle<CR>', { noremap = true, silent = true })
