return {
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "nvim-treesitter/nvim-treesitter-textobjects", event = "VeryLazy" },
	{
		"mbbill/undotree",
		lazy = true,
		keys = {
			{
				"<leader>tu",
				"<cmd>UndotreeToggle<cr>",
				desc = "[t]oggle [u]ndo tree",
			},
		},
	},
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
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		ft = "markdown",
		lazy = true,
		cmd = {
			"ObsidianQuickSwitch",
			"ObsidianTags",
			"ObsidianSearch",
			"ObsidianNew",
			"ObsidianToday",
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
		"rodrigoscc/http.nvim",
		build = { ":TSUpdate http2", ":Http update_grammar_queries" },
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"folke/snacks.nvim",
		},
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
			http.setup({ win_config = { split = "right" } })

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
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			indent = { scope = { enabled = false } },
			input = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			picker = {
				enabled = true,
				layout = { preset = "ivy" },
				actions = {
					diff_branch = function(picker)
						picker:close()

						local current = picker:current()

						if current and current.commit then
							vim.cmd.DiffviewOpen(current.commit .. "...HEAD")
						end
					end,
				},
			},
			quickfile = { enabled = true },
			scope = { enabled = true },
			statuscolumn = { left = { "sign" } },
			words = { enabled = true },
			styles = {
				notification = {
					-- wo = { wrap = true } -- Wrap notifications
				},
			},
		},
	},
}
