return {
	{
		"MunsMan/kitty-navigator.nvim",
		lazy = false,
		config = function()
			local navigator = require("kitty-navigator")

			vim.keymap.set({ "n", "t" }, "<M-h>", function()
				navigator.navigate("h")
			end, { silent = true })
			vim.keymap.set({ "n", "t" }, "<M-l>", function()
				navigator.navigate("l")
			end, { silent = true })
			vim.keymap.set({ "n", "t" }, "<M-k>", function()
				navigator.navigate("k")
			end, { silent = true })
			vim.keymap.set({ "n", "t" }, "<M-j>", function()
				navigator.navigate("j")
			end, { silent = true })
		end,
	},
	{
		"mikesmithgh/kitty-scrollback.nvim",
		enabled = true,
		lazy = true,
		cmd = {
			"KittyScrollbackGenerateKittens",
			"KittyScrollbackCheckHealth",
			"KittyScrollbackGenerateCommandLineEditing",
		},
		event = { "User KittyScrollbackLaunch" },
		-- version = '*', -- latest stable version, may have breaking changes if major version changed
		-- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
		config = function()
			require("kitty-scrollback").setup({
				{
					callbacks = {
						after_setup = function()
							vim.o.laststatus = 3 -- reset laststatus option
						end,
					},
				},
			})
		end,
	},
}
