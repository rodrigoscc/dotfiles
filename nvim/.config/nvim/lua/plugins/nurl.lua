return {
	{
		"rodrigoscc/nurl.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			formatters = {
				lua = {
					cmd = { "stylua", "--column-width=80", "-" },
				},
			},
		},
		keys = {
			{ "<leader>ee", "<cmd>Nurl env<cr>" },
			{ "<leader>oe", "<cmd>Nurl env_file<cr>" },
			{ "gh", "<cmd>Nurl jump<cr>" },
			{ "gH", "<cmd>Nurl<cr>" },
			{ "gk", "<cmd>Nurl resend<cr>" },
			{ "gl", "<cmd>Nurl resend -1<cr>" },
			{ "g;", "<cmd>Nurl resend -2<cr>" },
			{ "gG", "<cmd>Nurl history<cr>" },
		},
	},
}
