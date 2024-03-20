local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "nvim-treesitter/playground" },
	{ "nvim-treesitter/nvim-treesitter-textobjects" },
	{ "mbbill/undotree" },
	{ "tpope/vim-fugitive" },
	{ "folke/neodev.nvim", opts = {} },
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		dependencies = {
			-- LSP Support
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",

			-- Snippets
			"L3MON4D3/LuaSnip", -- Required
		},
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					visual = "gs", -- Remapping visual mode mapping to avoid conflicts with flash.nvim mappings.
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
	},
	{ "nvim-tree/nvim-web-devicons" },
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		opts = {},
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			sidebars = { "qf", "help", "NeogitCommitMessage" },
			on_colors = function(colors)
				-- Border between splits is too dim by default.
				colors.border = "#565f89"
			end,
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			attach_to_untracked = true,
		},
	},
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
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {

			indent = { char = "│" },
			scope = { enabled = false },
		},
	},
	{ "tpope/vim-sleuth" },
	{ "mfussenegger/nvim-dap" },
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dap.defaults.fallback.external_terminal = {
				command = "tmux",
				args = { "split-window", "-p", "20" },
			}

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.8 },
							{ id = "watches", size = 0.2 },
						},
						position = "left",
						size = 40,
					},
					{
						elements = {
							{ id = "console", size = 0.5 },
							{ id = "repl", size = 0.5 },
						},
						position = "bottom",
						size = 10,
					},
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			require("dap.ext.vscode").load_launchjs()
		end,
	},
	{ "theHamsta/nvim-dap-virtual-text", opts = {} },
	{
		"nvim-telescope/telescope-dap.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("telescope").load_extension("dap")
		end,
	},
	{ "leoluz/nvim-dap-go", opts = {} },
	{
		"mfussenegger/nvim-dap-python",
		config = function()
			require("dap-python").setup("~/.venvs/debugpy/bin/python", {
				console = "externalTerminal",
			})
		end,
	},
	{
		"Wansmer/treesj",
		keys = { "<space>J" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			use_default_keymaps = false,
		},
	},
	{
		"lukas-reineke/virt-column.nvim",
		opts = {
			virtcolumn = "80",
			char = "│",
		},
	},
	{ "numToStr/Navigator.nvim", opts = {} },
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			highlight = {
				keyword = "wide_fg",
				after = "",
			},
			gui_style = {
				fg = "BOLD",
			},
		},
	},
	{
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				filetypes_denylist = {
					"NvimTree",
					"fugitive",
					"DressingInput",
					"TelescopePrompt",
					"DiffviewFiles",
					"NeogitStatus",
				},
			})
		end,
	},
	{ "max397574/better-escape.nvim", opts = { mapping = { "jk" } } },
	{ "benfowler/telescope-luasnip.nvim" },
	{
		"danymat/neogen",
		opts = {
			snippet_engine = "luasnip",
			languages = {
				python = {
					template = {
						annotation_convention = "reST",
					},
				},
			},
		},
	},
	{ "onsails/lspkind.nvim" },
	{ "williamboman/mason.nvim" },
	{
		"stevearc/dressing.nvim",
		opts = { input = { relative = "editor" } },
	},
	{ "ThePrimeagen/harpoon" },
	{ "NvChad/nvim-colorizer.lua", opts = {} },
	{ "windwp/nvim-ts-autotag" },
	{
		"sindrets/diffview.nvim",
		config = function()
			vim.opt.fillchars:append({ diff = " " })
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",

			"nvim-telescope/telescope.nvim",
		},
		opts = {
			disable_insert_on_commit = false,
			integrations = {
				diffview = false,
			},
		},
	},
	{ "Glench/Vim-Jinja2-Syntax" },
	{ "chaoren/vim-wordmotion" },
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			vim.g.rainbow_delimiters = {
				query = {
					javascript = "rainbow-parens",
					tsx = "rainbow-parens",
				},
			}
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {
			hint_enable = false,
			toggle_key = "<C-s>",
			toogle_key_flip_floatwin_setting = true,
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false, -- It's annoying to save and having to press Enter.
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat then
					return
				end

				return { timeout_ms = 500, lsp_fallback = true }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = {
					"isort",
					"autoflake",
					"black",
				},
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				go = { "goimports", "gofmt" },
				json = { "fixjson" },
				sql = { "sql_formatter" },
				sh = { "beautysh" },
				bash = { "beautysh" },
				zsh = { "beautysh" },
			},
			formatters = {
				stylua = {
					prepend_args = { "--column-width=80" },
				},
				isort = {
					prepend_args = { "--profile", "black" },
				},
				black = {
					prepend_args = { "--line-length", "79" },
				},
				autoflake = {
					prepend_args = { "--remove-all-unused-imports" },
				},
				prettier = {
					prepend_args = { "--tab-width", "4" },
				},
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				python = { "flake8" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			fastwarp = {
				map = "<C-d>",
				rmap = "<C-r>",
				cmap = "<C-d>",
				rcmap = "<C-r>",
			},
		},
	},
	{ "github/copilot.vim" },
	{
		"stevearc/oil.nvim",
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
		},
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			highlight_groups = {
				MiniTrailspace = {
					underline = true,
				},
			},
		},
	},
	{
		"folke/zen-mode.nvim",
		opts = {},
	},
	{
		"folke/twilight.nvim",
		opts = {},
	},
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	{
		"hedyhli/outline.nvim",
		opts = {},
	},
})
