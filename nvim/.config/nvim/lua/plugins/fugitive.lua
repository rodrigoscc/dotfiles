return {
	{
		"tpope/vim-fugitive",
		lazy = true,
		cmd = { "Git", "Gedit" },
		keys = {
			{
				"<leader>ga",
				function()
					vim.cmd("Git add %")
				end,
			},
			{
				"<leader>gc",
				function()
					vim.cmd("Git commit")
				end,
			},
			{
				"<leader>gp",
				function()
					vim.cmd("Git! -c push.autoSetupRemote=true push")
				end,
			},
		},
	},
}
