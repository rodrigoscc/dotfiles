return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "nvim-treesitter/nvim-treesitter-textobjects" },
	{ "mbbill/undotree" },
	{ "tpope/vim-sleuth" },
	{
		"max397574/better-escape.nvim",
		opts = {},
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			default_file_explorer = true,
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
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		ft = "markdown",
		lazy = true,
		cmd = {
			"ObsidianQuickSwitch",
			"ObsidianTags",
			"ObsidianSearch",
			"ObsidianNew",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "work",
					path = "~/obsidian-vault/",
				},
			},
			templates = {
				folder = "templates",
			},
		},
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{
				"kristijanhusak/vim-dadbod-completion",
				ft = { "sql", "mysql", "plsql" },
				lazy = true,
			},
			{ "tpope/vim-dispatch" },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_use_nvim_notify = 1
		end,
	},
	{
		"rstcruzo/http.nvim",
		config = function()
			local http = require("http-nvim")
			http.setup()

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "http",
				callback = function()
					vim.keymap.set(
						"n",
						"R",
						"<cmd>Http run_closest<cr>",
						{ buffer = true }
					)
					vim.keymap.set(
						"n",
						"K",
						"<cmd>Http inspect<cr>",
						{ buffer = true }
					)
				end,
			})

			vim.keymap.set("n", "gh", "<cmd>Http jump<cr>")
			vim.keymap.set("n", "gH", "<cmd>Http run<cr>")
			vim.keymap.set("n", "gL", "<cmd>Http run_last<cr>")

			vim.keymap.set("n", "<leader>ee", "<cmd>Http select_env<cr>")
			vim.keymap.set("n", "<leader>ne", "<cmd>Http create_env<cr>")
			vim.keymap.set("n", "<leader>oe", "<cmd>Http open_env<cr>")

			vim.keymap.set("n", "<leader>oh", "<cmd>Http open_hooks<cr>")

			local cmp = require("cmp")
			cmp.setup.filetype("http", {
				sources = cmp.config.sources({
					{ name = "http" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
					{ name = "luasnip", keyword_length = 2 },
				}),
			})
		end,
	},
}
