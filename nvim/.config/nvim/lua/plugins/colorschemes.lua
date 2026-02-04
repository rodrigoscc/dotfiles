return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
			},
			highlight_groups = {
				Normal = {
					bg = "none",
				},
				NormalNC = {
					bg = "none",
				},
				StatusLine = {
					bg = "none",
				},
				StatusLineNC = {
					bg = "none",
				},
				TabLine = {
					bg = "none",
				},
				TabLineFill = {
					bg = "none",
				},
				TabLineSel = {
					bg = "none",
				},
				WinBar = {
					bg = "none",
				},
				WinBarNC = {
					fg = "muted",
					inherit = false,
				},
				MiniTrailspace = {
					underline = true,
					bg = "none",
				},
				Pmenu = {
					bg = "base", -- Less vibrant
				},
				PmenuSel = {
					fg = "none", -- Otherwise tailwind colors are gone
					bg = "overlay", -- Make the bg more noticeable
				},
				PmenuExtra = {
					bg = "base", -- Less vibrant
				},
				FloatBorder = {
					bg = "base", -- Less vibrant
				},
				FloatTitle = {
					bg = "base", -- Less vibrant
				},
				NormalFloat = {
					bg = "base", -- Less vibrant
				},
				DiagnosticVirtualTextError = {
					bg = "none",
					fg = "love",
					inherit = false,
				},
				DiagnosticVirtualTextHint = {
					bg = "none",
					fg = "iris",
					inherit = false,
				},
				DiagnosticVirtualTextInfo = {
					bg = "none",
					fg = "foam",
					inherit = false,
				},
				DiagnosticVirtualTextOk = {
					bg = "none",
					fg = "leaf",
					inherit = false,
				},
				DiagnosticVirtualTextWarn = {
					bg = "none",
					fg = "gold",
					inherit = false,
				},
				QuickFixLine = {
					bg = "overlay",
				},
				Folded = {
					bg = "surface",
					fg = "subtle",
				},
				Comment = {
					italic = true,
				},
				["@keyword"] = {
					italic = true,
				},
				["@keyword.repeat"] = {
					italic = true,
				},
				["@keyword.conditional"] = {
					italic = true,
				},
				["@keyword.exception"] = {
					italic = true,
				},
				["@keyword.return"] = {
					italic = true,
				},
				["@keyword.import"] = {
					italic = true,
				},
				Keyword = {
					italic = true,
				},
				["@markup.italic"] = {
					italic = true,
				},
				["@markdown.high"] = {
					bg = "love",
					fg = "love",
					blend = 15,
				},
				["@markdown.medium"] = {
					bg = "gold",
					fg = "gold",
					blend = 15,
				},
				["@markdown.low"] = {
					bg = "text",
					fg = "text",
					blend = 15,
				},
				["@markdown.todo"] = {
					bg = "rose",
					fg = "rose",
					blend = 15,
				},
				["@markdown.in_progress"] = {
					bg = "iris",
					fg = "iris",
					blend = 15,
				},
				["@markdown.done"] = {
					bg = "muted",
					fg = "muted",
					blend = 15,
				},
				["@markdown.canceled"] = {
					bg = "muted",
					fg = "muted",
					blend = 15,
				},
				CodeBlock = {
					bg = "surface",
				},
				Headline1 = {
					bg = "iris",
					blend = 15,
				},
				Headline2 = {
					bg = "foam",
					blend = 15,
				},
				Headline3 = {
					bg = "rose",
					blend = 15,
				},
				BlinkCmpSignatureHelpBorder = {
					link = "FloatBorder",
				},
				SnacksDiffContext = {
					bg = "none",
					link = "none",
				},
				SnacksDiffContextNr = {
					bg = "none",
					link = "none",
				},
				SnacksDiffContextLineNr = {
					bg = "none",
					fg = "muted",
				},
			},
		},
	},
}
