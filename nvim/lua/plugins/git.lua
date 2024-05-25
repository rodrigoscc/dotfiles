return {
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			attach_to_untracked = true,
		},
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",

			"nvim-telescope/telescope.nvim",
		},
		cmd = { "Neogit" },
		opts = {
			auto_show_console = false,
			disable_insert_on_commit = false,
			integrations = {
				diffview = false,
			},
		},
		config = true,
	},
	{
		"sindrets/diffview.nvim",
	},
}
