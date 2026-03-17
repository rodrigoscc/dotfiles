return {
	{
		"rodrigoscc/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = "CodeDiff",
		keys = {
			{
				"<leader>gd",
				function()
					vim.cmd.CodeDiff() -- Making sure to show only the changes in the current working directory.
				end,
				{ desc = "git diff" },
			},
			{
				"<leader>gD",
				function()
					vim.cmd("CodeDiff main HEAD") -- Diff current branch to master/main branch in origin
				end,
				{ desc = "git diff with origin HEAD" },
			},
			{
				"<leader>gf",
				function()
					vim.cmd("CodeDiff history")
				end,
				{ desc = "git file history" },
			},
		},
		opts = {
			keymaps = {
				view = {
					next_hunk = "<C-j>", -- Jump to next change
					prev_hunk = "<C-k>", -- Jump to previous change
					next_file = "<C-l>", -- Next file in explorer/history mode
					prev_file = "<C-h>", -- Previous file in explorer/history mode
				},
			},
		},
	},
}
