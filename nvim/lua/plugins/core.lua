return {
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "nvim-treesitter/nvim-treesitter-textobjects", event = "VeryLazy" },
	{ "mbbill/undotree" },
	{ "tpope/vim-sleuth" },
	{
		"max397574/better-escape.nvim",
		opts = {},
	},
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
		lazy = true,
		keys = {
			{ "<leader>ee", "<cmd>Http select_env<cr>" },
			{ "<leader>ne", "<cmd>Http create_env<cr>" },
			{ "<leader>oe", "<cmd>Http open_env<cr>" },
			{ "<leader>oh", "<cmd>Http open_hooks<cr>" },
			{ "gh", "<cmd>Http jump<cr>" },
			{ "gH", "<cmd>Http run<cr>" },
			{ "gL", "<cmd>Http run_last<cr>" },
		},
		ft = "http",
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
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({
				defaults = {
					keymap = {
						fzf = {
							["ctrl-q"] = "select-all+accept",
						},
					},
				},
				winopts = {
					backdrop = 100,
				},
				previewers = {
					builtin = {
						extensions = {
							["png"] = { "chafa" },
							["svg"] = { "chafa" },
							["jpg"] = { "chafa" },
							["gif"] = { "chafa" },
						},
					},
				},
			})
		end,
	},
}
