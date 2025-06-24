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
			},
			metadata = {
				-- Example: A @priority tag that has dynamic color based on the priority value
				priority = {
					key = ",p",
				},
				-- Example: A @started tag that uses a default date/time string when added
				started = {
					key = ",s",
				},
				-- Example: A @done tag that also sets the todo item state when it is added and removed
				done = {
					key = ",d",
				},
			},
		},
	},
}
