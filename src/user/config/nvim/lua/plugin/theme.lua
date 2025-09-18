return {
	"miikanissi/modus-themes.nvim",
	priority = 1000,
	config = function()
		require("modus-themes").setup({
			style = "light",
			variant = "default",
			transparent = true,
			dim_inactive = false,
			hide_inactive_statusline = false,
			line_nr_column_background = true,
			sign_column_background = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
			},
			on_highlights = function(hl, colors)
				hl["@method"]             = { fg = colors.magenta_intense, italic = true }
				hl["@variable"]           = { fg = colors.orange }
				hl["@variable.parameter"] = { fg = colors.orange, italic = true }
				hl["@constant"]           = { fg = colors.purple }
				hl["@boolean.false"]      = { fg = colors.red, bold = true }
				hl["@boolean.true"]       = { fg = colors.green, bold = true }
				hl["@tag"]                = { fg = colors.orange }
				hl["@tag.attribute"]      = { fg = colors.blue }


				hl["@keyword"] = { fg = colors.blue, bold = true }

				hl["@function.call"]      = { fg = colors.red }

				-- Locked ?
				hl.IblScope               = { fg = colors.yellow_faint, bold = true } -- indent-blankline
				hl["@type"]               = { fg = colors.yellow_faint }
				hl["@type.builtin"]       = { fg = colors.blue_intense }
				hl["@function"]           = { fg = colors.fg_main }
				hl["@string"]             = { fg = colors.green_intense, italic = true }
				hl["@comment"]            = { fg = colors.fg_dim, italic = true }

				-- =========================
				-- UI / Editor
				-- =========================
				hl.CursorLine             = { bg = colors.bg_dim }
				hl.LineNr                 = { fg = colors.fg_inactive }
				hl.CursorLineNr           = { fg = colors.orange, bold = true }
				hl.Whitespace             = { fg = colors.fg_alt }  -- tabs & trailing spaces
				hl.SpecialKey             = { fg = colors.purple }  -- listchars (tabs)
				hl.SignColumn             = { bg = colors.bg_alt }  -- gutter
				hl.IblIndent              = { fg = colors.fg_alt }  -- indent guides
			end,
		})
		vim.cmd.colorscheme("modus_vivendi")
	end,
}

