-- General settings
require("user.mappings")
require("user.settings")

-- Plugins
require("user.plugin")  -- Manager

require("plugin.treesitter")        -- Syntax Highlighting
require("plugin.cmp")               -- Autocompletion
require("plugin.lsp")               -- Language Server Protocol
require("plugin.indent-blankline")  -- Visualise indentation and scope
require("plugin.vimtex")            -- Latex Tools
--require("plugin.markdown-preview")  -- Markdown Preview

-- Language Servers
--vim.lsp.enable("luals")
