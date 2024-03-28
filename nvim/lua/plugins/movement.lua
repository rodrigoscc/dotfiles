return {
	{ "numToStr/Navigator.nvim", opts = {} },
	{ "chaoren/vim-wordmotion" },
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
					config = nil,
					highlight = { backdrop = false },
				},
			},
			label = {
				uppercase = false,
			},
		},
	},
	{ "ThePrimeagen/harpoon" },
}
