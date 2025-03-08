return {
	{ "numToStr/Navigator.nvim", opts = {} },
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
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
			},
			{
				"<leader>A",
				function()
					require("harpoon").ui:toggle_quick_menu(
						require("harpoon"):list()
					)
				end,
			},
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
			},
		},
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
		end,
	},
}
