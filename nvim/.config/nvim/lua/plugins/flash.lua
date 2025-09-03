return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			modes = {
				search = {
					enabled = false,
				},
				char = {
					highlight = { backdrop = false },
				},
			},
			label = {
				uppercase = false,
			},
		},
	},
}
