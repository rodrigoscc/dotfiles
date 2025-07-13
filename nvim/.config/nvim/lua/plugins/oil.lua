return {
	{
		"stevearc/oil.nvim",
		lazy = true,
		keys = {
			{ "-", "<cmd>Oil<cr>" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			default_file_explorer = false,
			delete_to_trash = true,
			use_default_keymaps = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-x>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-l>"] = "actions.preview",
				["q"] = "actions.close",
				["<C-R>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			float = {
				max_width = 100,
			},
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
				end,
			},
			win_options = {
				winbar = "%{v:lua.require('oil').get_current_dir()}",
			},
		},
	},
}
