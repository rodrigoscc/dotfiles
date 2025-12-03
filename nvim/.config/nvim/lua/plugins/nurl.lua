return {
	{
		"rodrigoscc/nurl.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {},
		keys = {
			{ "<leader>ee", "<cmd>Nurl env<cr>" },
			{ "<leader>oe", "<cmd>Nurl env_file<cr>" },
			{ "gh", "<cmd>Nurl jump<cr>" },
			{ "gH", "<cmd>Nurl<cr>" },
			{ "gL", "<cmd>Nurl resend -1<cr>" },
			{ "g;", "<cmd>Nurl resend -2<cr>" },
			{ "gG", "<cmd>Nurl history<cr>" },
		},
		config = function()
			local nurl = require("nurl")
			nurl.setup({
				formatters = {
					lua = {
						cmd = { "stylua", "--column-width=80", "-" },
					},
				},
			})

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "lua",
				callback = function()
					vim.keymap.set(
						"n",
						"R",
						"<cmd>Nurl .<cr>",
						{ buffer = true }
					)
				end,
			})
		end,
	},
}
