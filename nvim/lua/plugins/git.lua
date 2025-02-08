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
					vim.cmd("Git! push")
				end,
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			attach_to_untracked = true,
			signs_staged_enable = false,
		},
	},
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
