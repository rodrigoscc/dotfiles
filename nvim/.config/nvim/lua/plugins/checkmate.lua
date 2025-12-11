return {
	{
		"bngarren/checkmate.nvim",
		ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
		cmd = { "Checkmate" },
		opts = {
			files = { "*.md" },
			use_metadata_keymaps = false,
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
					modes = { "n", "v" },
				},
				[",h"] = {
					rhs = "<cmd>Checkmate metadata toggle priority high<CR>",
					modes = { "n", "v" },
				},
				[",m"] = {
					rhs = "<cmd>Checkmate metadata toggle priority medium<CR>",
					modes = { "n", "v" },
				},
				[",l"] = {
					rhs = "<cmd>Checkmate metadata toggle priority low<CR>",
					modes = { "n", "v" },
				},
				[",s"] = {
					rhs = "<cmd>Checkmate metadata add started<CR>",
					modes = { "n", "v" },
				},
				[",d"] = {
					rhs = "<cmd>Checkmate metadata add done<CR>",
					modes = { "n", "v" },
				},
			},
		},
	},
}
