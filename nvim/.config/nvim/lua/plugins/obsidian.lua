return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
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
				enable = false,
			},
			footer = { enabled = false },
		},
	},
}
