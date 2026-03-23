return {
	"loctvl842/monokai-pro.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("monokai-pro").setup({
			transparent_background = true,
			terminal_colors = false,
			devicons = true,
			-- classic | octagon | pro | machine | ristretto | spectrum
			filter = "ristretto", 
			day_night = {
				enable = false,
				day_filter = pro,
				night_filter = ristretto,
			}
		})
		vim.cmd.colorscheme("monokai-pro")
	end
}
