return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		ft = "markdown",
		lazy = true,
		cmd = {
			"Obsidian",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "work",
					path = "~/obsidian-vault/",
				},
			},
			templates = {
				folder = "templates",
			},
			ui = {
				bullets = {},
			},
			footer = { enabled = false },
		},
	},
}
