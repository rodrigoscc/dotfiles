local diffview = require("diffview")

vim.keymap.set("n", "<leader>gd", function()
	vim.cmd("DiffviewOpen -- ./") -- Making sure to show only the changes in the current working directory.
end, { desc = "[g]it [d]iff" })

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
