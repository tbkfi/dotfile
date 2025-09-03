return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-path",     -- Filesystem path completion
		"hrsh7th/cmp-cmdline",  -- Commandline completion
		"hrsh7th/cmp-buffer",   -- Current buffer completion
		"hrsh7th/cmp-nvim-lsp", -- LSP completion
	},
	event = { "InsertEnter", "CmdlineEnter" },

	config = function()
		local cmp = require("cmp")

		cmp.setup({
			sources = cmp.config.sources({
				{ name = "path" },
				{ name = "buffer" },
				{ name = "nvim_lsp" },
			}),
			mapping = {
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<CR>"]  = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			},
			experimental = {
				ghost_text = true,
			},
		})

		-- Commands and Filesystem path completion
		cmp.setup.cmdline(":", {
			sources = cmp.config.sources({
				{ name = "path" },
				{ name = "cmdline" },
			}),
		})

		-- Search completion
		cmp.setup.cmdline("/", {
			sources = {
				{ name = "buffer" },
			},
		})
	end,
}
