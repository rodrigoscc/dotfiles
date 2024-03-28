return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
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
			highlight_groups = {
				MiniTrailspace = {
					underline = true,
				},
			},
		},
	},
}
