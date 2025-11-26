return {
	{
		"rodrigoscc/nurl.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {},
		keys = {
			{ "<leader>ee", "<cmd>Nurl env<cr>" },
			{ "<leader>oe", "<cmd>Nurl env_file<cr>" },
			{ "gh", "<cmd>Nurl jump<cr>" },
			{ "gH", "<cmd>Nurl send<cr>" },
			{ "gL", "<cmd>Nurl resend<cr>" },
			{ "g;", "<cmd>Nurl resend -2<cr>" },
			{ "gG", "<cmd>Nurl history<cr>" },
		},
		config = function()
			local nurl = require("nurl")
			nurl.setup()

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "lua",
				callback = function()
					vim.keymap.set(
						"n",
						"R",
						"<cmd>Nurl send_at_cursor<cr>",
						{ buffer = true }
					)
				end,
			})
		end,
	},
}
