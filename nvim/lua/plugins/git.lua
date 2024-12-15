return {
	{
		"tpope/vim-fugitive",
		lazy = true,
		cmd = { "Git" },
		keys = {
			{
				"<leader>ga",
				function()
					vim.cmd("Git add %")
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
		config = function()
			local diffview = require("diffview")

			diffview.setup({
				keymaps = {
					disable_defaults = false,
					view = {
						{
							"n",
							"q",
							vim.cmd.tabclose,
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
							vim.cmd.tabclose,
							{ desc = "Close Diffview" },
						},
					},
				},
			})
		end,
	},
}
