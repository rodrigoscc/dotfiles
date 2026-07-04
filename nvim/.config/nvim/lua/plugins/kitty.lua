return {
	{
		"MunsMan/kitty-navigator.nvim",
		lazy = false,
		opts = {
			keybindings = {
				left = "<M-h>",
				down = "<M-j>",
				up = "<M-k>",
				right = "<M-l>",
			},
		},
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
			require("kitty-scrollback").setup()
		end,
	},
}
