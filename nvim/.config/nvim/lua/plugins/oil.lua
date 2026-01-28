local file_detail = false

return {
	{
		"stevearc/oil.nvim",
		lazy = true,
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		cmd = { "Oil" },
		keys = {
			{ "-", "<cmd>Oil<cr>" },
		},
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
				["gd"] = {
					desc = "Toggle file detail view",
					callback = function()
						file_detail = not file_detail
						if file_detail then
							require("oil").set_columns({
								"icon",
								"permissions",
								"size",
								"mtime",
							})
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
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
		},
	},
}
