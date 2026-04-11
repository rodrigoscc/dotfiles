return {
	{
		"tpope/vim-fugitive",
		lazy = false,
		cmd = { "Git", "Gedit", "Gdiffsplit", "G" },
		keys = {
			{
				"<leader>ga",
				"<cmd>Git add %<cr>",
			},
			{
				"<leader>gc",
				"<cmd>Git commit<cr>",
			},
			{
				"<leader>gp",
				"<cmd>Git! -c push.autoSetupRemote=true push<cr>",
			},
		},
	},
}
