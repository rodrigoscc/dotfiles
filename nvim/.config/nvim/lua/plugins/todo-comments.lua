return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			highlight = {
				keyword = "wide_fg",
				after = "",
			},
			gui_style = {
				fg = "BOLD",
			},
		},
	},
}
