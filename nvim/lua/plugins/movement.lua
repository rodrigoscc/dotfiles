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
				"<M-y>",
				function()
					require("harpoon"):list():select(1)
				end,
			},
			{
				"<M-u>",
				function()
					require("harpoon"):list():select(2)
				end,
			},
			{
				"<M-i>",
				function()
					require("harpoon"):list():select(3)
				end,
			},
			{
				"<M-o>",
				function()
					require("harpoon"):list():select(4)
				end,
			},
			{
				"<M-p>",
				function()
					require("harpoon"):list():select(5)
				end,
			},
		},
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
		end,
	},
}
