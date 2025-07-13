return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "v3.11.0", -- recommended, use latest release instead of latest commit
		ft = "markdown",
		lazy = true,
		cmd = {
			"Obsidian",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
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
				checkboxes = {},
				bullets = {},
			},
			mappings = {
				-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
			},
		},
	},
}
