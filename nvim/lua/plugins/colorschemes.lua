return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
			},
			highlight_groups = {
				MiniTrailspace = {
					underline = true,
					bg = "none",
				},
				QuickFixLine = {
					bg = "iris",
					blend = 25,
				},
				Folded = {
					bg = "overlay",
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
			},
		},
	},
}
