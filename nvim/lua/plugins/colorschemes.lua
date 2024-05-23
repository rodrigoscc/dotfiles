return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1500,
		opts = {
			sidebars = { "qf", "help", "NeogitCommitMessage" },
			on_colors = function(colors)
				-- Border between splits is too dim by default.
				colors.border = "#565f89"
			end,
		},
	},
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
				},
				MiniCursorWord = {
					underline = false,
					bg = "rose",
					blend = 23,
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
			},
		},
	},
}
