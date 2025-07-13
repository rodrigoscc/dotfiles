return {
	{
		"rodrigoscc/http.nvim",
		build = { ":TSUpdate http2", ":Http update_grammar_queries" },
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"folke/snacks.nvim",
		},
		keys = {
			{ "<leader>ee", "<cmd>Http select_env<cr>" },
			{ "<leader>ne", "<cmd>Http create_env<cr>" },
			{ "<leader>oe", "<cmd>Http open_env<cr>" },
			{ "<leader>oh", "<cmd>Http open_hooks<cr>" },
			{ "gh", "<cmd>Http jump<cr>" },
			{ "gH", "<cmd>Http run<cr>" },
			{ "gL", "<cmd>Http run_last<cr>" },
		},
		ft = "http",
		config = function()
			local http = require("http-nvim")
			http.setup({ win_config = { split = "right" } })

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "http",
				callback = function()
					vim.keymap.set(
						"n",
						"R",
						"<cmd>Http run_closest<cr>",
						{ buffer = true }
					)
					vim.keymap.set(
						"n",
						"K",
						"<cmd>Http inspect<cr>",
						{ buffer = true }
					)
				end,
			})
		end,
	},
}
