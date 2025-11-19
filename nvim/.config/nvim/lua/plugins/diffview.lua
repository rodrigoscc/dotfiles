return {
	{
		"sindrets/diffview.nvim",
		lazy = true,
		keys = {
			{
				"<leader>gd",
				function()
					vim.cmd("DiffviewOpen -- ./") -- Making sure to show only the changes in the current working directory.
				end,
				{ desc = "[g]it [d]iff" },
			},
			{
				"<leader>gD",
				function()
					vim.cmd("DiffviewOpen origin/HEAD...HEAD") -- Diff current branch to master/main branch in origin
				end,
				{ desc = "[g]it [D]iff with origin HEAD" },
			},
			{
				"<leader>gf",
				function()
					vim.cmd("DiffviewFileHistory %")
				end,
				{ desc = "[g]it [f]ile history" },
			},
		},
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewLog" },
		config = function()
			local diffview = require("diffview")

			diffview.setup({
				keymaps = {
					disable_defaults = false,
					view = {
						{
							"n",
							"q",
							"<cmd>DiffviewClose<cr>",
							{ desc = "Close Diffview" },
						},
						{
							"n",
							"<C-j>",
							"]c",
							{ desc = "Next change" },
						},
						{
							"n",
							"<C-k>",
							"[c",
							{ desc = "Previous change" },
						},
						{
							"n",
							"<localleader>o",
							"do]c",
							{ desc = "Diff get" },
						},
						{
							"n",
							"<localleader>p",
							"dp]c",
							{ desc = "Diff put" },
						},
					},
					file_panel = {
						{
							"n",
							"q",
							"<cmd>DiffviewClose<cr>",
							{ desc = "Close Diffview" },
						},
					},
					file_history_panel = {
						{
							"n",
							"q",
							vim.cmd.DiffviewClose,
							{ desc = "Close Diffview" },
						},
					},
				},
			})
		end,
	},
}
