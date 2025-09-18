return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	---@module "ibl"
	---@type ibl.config
	opts = {
		indent = { char = "│" },
		scope = {
			enabled = true,
			show_start = true,
			highlight = "IblScope",
		},
	},
}
