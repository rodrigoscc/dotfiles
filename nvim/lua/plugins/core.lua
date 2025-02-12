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
		"epwalsh/obsidian.nvim",
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

			-- local cmp = require("cmp")
			-- cmp.setup.filetype("http", {
			-- 	sources = cmp.config.sources({
			-- 		{ name = "http" },
			-- 	}, {
			-- 		{ name = "buffer" },
			-- 		{ name = "path" },
			-- 		{ name = "luasnip", keyword_length = 2 },
			-- 	}),
			-- })
		end,
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({
				{ "ivy", "hide" },
				defaults = {
					keymap = {
						fzf = {
							["ctrl-q"] = "select-all+accept",
						},
						builtin = {
							["<C-c>"] = "hide",
						},
					},
				},
				files = {
					rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
					fd_opts = [[--color=never --type f --type l --hidden --follow --exclude .git]],
					actions = {
						["alt-f"] = false,
						["alt-h"] = false,
						["alt-i"] = false,
						["ctrl-i"] = {
							fn = require("fzf-lua").actions.toggle_ignore,
							reuse = true,
							header = "Disable .gitignore",
						},
						["ctrl-d"] = {
							fn = function(...)
								require("fzf-lua").actions.file_vsplit(...)
								vim.cmd("windo diffthis")
								local switch = vim.api.nvim_replace_termcodes(
									"<C-w>h",
									true,
									false,
									true
								)
								vim.api.nvim_feedkeys(switch, "t", false)
							end,
							desc = "diff-file",
						},
					},
				},
				git = {
					branches = {
						actions = {
							["ctrl-d"] = {
								fn = function(selected)
									-- TODO: if diffview is not loaded, this fails. Double check lazy loading
									vim.cmd.DiffviewOpen({
										args = { selected[1] },
									})
								end,
								desc = "diffview-git-branch",
							},
						},
					},
				},
				winopts = {
					backdrop = false,
					preview = {
						horizontal = "right:50%", -- right|left:size
					},
					title_flags = false,
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
				lsp = {
					symbols = {
						regex_filter = function(item)
							if
								vim.tbl_contains({
									"Variable",
									"String",
									"Number",
									"Text",
									"Boolean",
								}, item.kind)
							then
								return false
							else
								return true
							end
						end,
					},
				},
			})
		end,
	},
}
