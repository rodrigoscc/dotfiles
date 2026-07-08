return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
			},
			{
				"<leader>hh",
				function()
					require("harpoon").ui:toggle_quick_menu(
						require("harpoon"):list()
					)
				end,
			},
			{
				"<C-1>",
				function()
					require("harpoon"):list():select(1)
				end,
			},
			{
				"<C-2>",
				function()
					require("harpoon"):list():select(2)
				end,
			},
			{
				"<C-3>",
				function()
					require("harpoon"):list():select(3)
				end,
			},
			{
				"<C-4>",
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
