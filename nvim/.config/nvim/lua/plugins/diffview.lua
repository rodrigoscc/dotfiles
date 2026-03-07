return {
	{
		"sindrets/diffview.nvim",
		lazy = true,
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
