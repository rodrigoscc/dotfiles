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
				"<M-1>",
				function()
					require("harpoon"):list():select(1)
				end,
			},
			{
				"<M-2>",
				function()
					require("harpoon"):list():select(2)
				end,
			},
			{
				"<M-3>",
				function()
					require("harpoon"):list():select(3)
				end,
			},
			{
				"<M-4>",
				function()
					require("harpoon"):list():select(4)
				end,
			},
			{
				"<M-p>",
				function()
					require("harpoon"):list():prev()
				end,
			},
			{
				"<M-n>",
				function()
					require("harpoon"):list():next()
				end,
			},
		},
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
		end,
	},
}
