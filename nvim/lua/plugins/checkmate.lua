return {
	{
		"bngarren/checkmate.nvim",
		ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
		opts = {
			files = { "*.md" },
			keys = {
				["<CR>"] = {
					rhs = "<cmd>Checkmate toggle<CR>",
					desc = "Toggle todo item",
					modes = { "n", "v" },
				},
				[",a"] = {
					rhs = "<cmd>Checkmate archive<CR>",
					desc = "Archive checked/completed todo items (move to bottom section)",
					modes = { "n" },
				},
				[",c"] = {
					rhs = "<cmd>Checkmate create<CR>",
					desc = "Create todo item",
					modes = { "n", "v" },
				},
				[",r"] = {
					rhs = "<cmd>Checkmate remove_all_metadata<CR>",
					desc = "Remove all metadata from a todo item",
					modes = { "n", "v" },
				},
				[",p"] = {
					rhs = "<cmd>Checkmate metadata add priority<CR>",
					desc = "Remove all metadata from a todo item",
					modes = { "n", "v" },
				},
				[",s"] = {
					rhs = "<cmd>Checkmate metadata add started<CR>",
					desc = "Remove all metadata from a todo item",
					modes = { "n", "v" },
				},
				[",d"] = {
					rhs = "<cmd>Checkmate metadata add done<CR>",
					desc = "Remove all metadata from a todo item",
					modes = { "n", "v" },
				},
			},
		},
	},
}
