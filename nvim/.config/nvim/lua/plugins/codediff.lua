return {
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		keys = {
			{
				"<leader>gd",
				"<cmd>CodeDiff<cr>",
				{ desc = "git diff" },
			},
			{
				"<leader>gf",
				"<cmd>CodeDiff history %<cr>",
				mode = { "n" },
				{ desc = "git file history" },
			},
			{
				"<leader>gf",
				"<cmd>CodeDiff history<cr>",
				mode = { "x" },
				{ desc = "git lines history" },
			},
		},
	},
}
