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
				file_panel = {
					win_config = {
						position = "bottom",
						height = 10,
					},
				},
				file_history_panel = {
					win_config = {
						type = "split",
						position = "bottom",
						height = 10,
					},
				},
				keymaps = {
					disable_defaults = false,
					view = {
						{
							"n",
							"q",
							vim.cmd.DiffviewClose,
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
							"<C-h>",
							"do",
							{ desc = "Diff get" },
						},
						{
							"n",
							"<C-l>",
							"dp",
							{ desc = "Diff put" },
						},
					},
					file_panel = {
						{
							"n",
							"q",
							vim.cmd.DiffviewClose,
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
