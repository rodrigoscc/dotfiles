return {
	{
		"bngarren/checkmate.nvim",
		ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
		cmd = { "Checkmate" },
		opts = {
			files = { "*.md" },
			use_metadata_keymaps = false,
			metadata = {
				priority = {
					style = function(context)
						local value = context.value:lower()
						if value == "high" then
							return { fg = "#ff5555", bold = true }
						elseif value == "medium" then
							return { fg = "#ffb86c" }
						elseif value == "low" then
							return { fg = "#8be9fd" }
						else -- fallback
							return { fg = "#8be9fd" }
						end
					end,
					get_value = function()
						return "medium" -- Default priority
					end,
					choices = function()
						return { "low", "medium", "high" }
					end,
					key = nil,
					sort_order = 10,
					jump_to_on_insert = false,
					select_on_insert = false,
				},
			},
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
					rhs = "<cmd>Checkmate metadata remove priority<CR>",
					modes = { "n", "v" },
				},
				[",h"] = {
					rhs = "<cmd>Checkmate metadata add priority high<CR>",
					modes = { "n", "v" },
				},
				[",m"] = {
					rhs = "<cmd>Checkmate metadata add priority medium<CR>",
					modes = { "n", "v" },
				},
				[",l"] = {
					rhs = "<cmd>Checkmate metadata add priority low<CR>",
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
