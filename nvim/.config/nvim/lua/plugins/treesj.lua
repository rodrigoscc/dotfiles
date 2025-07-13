return {
	{
		"Wansmer/treesj",
		lazy = true,
		keys = { "<space>J" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local treesj = require("treesj")
			treesj.setup({
				use_default_keymaps = false,
			})

			vim.keymap.set(
				"n",
				"<leader>J",
				treesj.toggle,
				{ desc = "trees[J] toggle" }
			)
		end,
	},
}
