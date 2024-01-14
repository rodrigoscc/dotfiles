vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })

	use("nvim-treesitter/playground")

	use({
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter",
		requires = "nvim-treesitter/nvim-treesitter",
	})

	use("mbbill/undotree")

	use("tpope/vim-fugitive")

	use({ "folke/neodev.nvim" })

	use({
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" }, -- Required
		},
	})

	use({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	})

	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	use("nvim-tree/nvim-web-devicons")

	use({
		"utilyre/barbecue.nvim",
		tag = "*",
		requires = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		after = "nvim-web-devicons", -- keep this if you're using NvChad
		config = function()
			require("barbecue").setup({})
		end,
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	use({
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				sidebars = { "qf", "help", "NeogitCommitMessage" },
				on_colors = function(colors)
					-- Border between splits is too dim by default.
					colors.border = "#565f89"
				end,
			})
		end,
	})

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({})
		end,
	})

	use({
		"folke/flash.nvim",
		config = function()
			require("flash").setup({
				modes = {
					search = {
						enabled = false,
					},
					char = {
						config = nil,
						highlight = { backdrop = false },
					},
				},
			})
		end,
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				indent = { char = "│" },
				scope = { enabled = false },
			})
		end,
	})

	use("tpope/vim-sleuth")

	use({ "mfussenegger/nvim-dap" })
	use({
		"rcarriga/nvim-dap-ui",
		requires = { "mfussenegger/nvim-dap" },
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
	})
	use({
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup({})
		end,
	})
	use({
		"nvim-telescope/telescope-dap.nvim",
		requires = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("telescope").load_extension("dap")
		end,
	})
	use({
		"leoluz/nvim-dap-go",
		config = function()
			require("dap-go").setup()
		end,
	})

	use({
		"mfussenegger/nvim-dap-python",
		config = function()
			require("dap-python").setup("~/.venvs/debugpy/bin/python", {
				console = "externalTerminal",
			})
		end,
	})

	use({
		"Wansmer/treesj",
		requires = { "nvim-treesitter" },
		config = function()
			local treesj = require("treesj")

			treesj.setup({
				use_default_keymaps = false,
			})

			vim.keymap.set(
				"n",
				"<leader>J",
				treesj.toggle,
				{ desc = "trees[J] toggle" }
			)
		end,
	})

	use({
		"lukas-reineke/virt-column.nvim",
		config = function()
			require("virt-column").setup({
				virtcolumn = "80",
				char = "│",
			})
		end,
	})

	use({
		"ntpeters/vim-better-whitespace",
		config = function()
			vim.cmd("let g:better_whitespace_enabled=0")
			vim.cmd("let g:strip_whitespace_on_save=1")
			vim.cmd("let g:strip_whitespace_confirm=0")
			vim.cmd("let g:better_whitespace_operator='_s'")
		end,
	})

	use({
		"numToStr/Navigator.nvim",
		config = function()
			require("Navigator").setup({})
		end,
	})

	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({
				signs = false,
				highlight = {
					keyword = "fg",
					after = "",
				},
			})
			vim.keymap.set(
				"n",
				"<leader>tq",
				vim.cmd.TodoQuickFix,
				{ desc = "[t]odo [q]uickfix" }
			)
		end,
	})

	use({
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
	})

	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup({
				mapping = { "jk" },
			})
		end,
	})

	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons", -- optional
		},
		config = function()
			local function on_attach(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return {
						desc = "nvim-tree: " .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true,
					}
				end

				api.config.mappings.default_on_attach(bufnr)

				vim.keymap.set("n", "ga", function()
					local node = api.tree.get_node_under_cursor()
					vim.cmd("Git add " .. node.absolute_path)
				end, opts("Git Add"))
			end

			require("nvim-tree").setup({
				actions = {
					open_file = {
						resize_window = false,
					},
				},
				update_focused_file = {
					enable = true,
				},
				hijack_directories = {
					enable = false, -- no auto open
				},
				hijack_cursor = true,
				on_attach = on_attach,
			})
		end,
	})

	use({ "benfowler/telescope-luasnip.nvim" })

	use({
		"danymat/neogen",
		config = function()
			require("neogen").setup({
				snippet_engine = "luasnip",
				languages = {
					python = {
						template = {
							annotation_convention = "reST",
						},
					},
				},
			})
		end,
		requires = "nvim-treesitter/nvim-treesitter",
	})

	use("Vimjas/vim-python-pep8-indent")

	use("onsails/lspkind.nvim")

	use({ "williamboman/mason.nvim" })

	use({
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup({
				input = {
					relative = "editor",
				},
			})
		end,
	})

	use({ "ThePrimeagen/harpoon" })

	use({
		"simrat39/symbols-outline.nvim",
		config = function()
			require("symbols-outline").setup({
				autofold_depth = 1,
			})
		end,
	})

	use({
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({})
		end,
	})

	use({ "windwp/nvim-ts-autotag" })

	use({
		"sindrets/diffview.nvim",
		config = function()
			-- Diagonal lines in place of deleted lines in diff-mode
			vim.opt.fillchars:append({ diff = " " })
		end,
	})

	use({
		"NeogitOrg/neogit",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			local neogit = require("neogit")
			neogit.setup({
				disable_insert_on_commit = false,
				integrations = {
					diffview = false,
				},
			})
		end,
	})

	use({ "Glench/Vim-Jinja2-Syntax" })

	use({ "chaoren/vim-wordmotion" })

	use({
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			vim.g.rainbow_delimiters = {
				query = {
					javascript = "rainbow-parens",
					tsx = "rainbow-parens",
				},
			}
		end,
	})

	use({
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").setup({
				hint_enable = false,
				toggle_key = "<C-s>",
				-- Need the below config for the toggle_key to work.
				-- https://github.com/ray-x/lsp_signature.nvim/issues/267
				toggle_key_flip_floatwin_setting = true,
			})
		end,
	})

	use({ "Mofiqul/vscode.nvim" })

	use({
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
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
				},
				formatters = {
					stylua = {
						prepend_args = { "--column-width=80" },
					},
					isort = {
						prepend_args = { "--profile", "black" },
					},
					black = {
						prepend_args = { "--line-length=79" },
					},
					autoflake = {
						prepend_args = { "--remove-all-unused-imports" },
					},
					prettier = {
						prepend_args = { "--tab-width", "4" },
					},
				},
			})
		end,
	})

	use({
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
	})

	use({
		"altermo/ultimate-autopair.nvim",
		branch = "v0.6",
		config = function()
			require("ultimate-autopair").setup({
				fastwarp = {
					map = "<C-f>",
					rmap = "<C-r>",
					cmap = "<C-f>",
					rcmap = "<C-r>",
				},
			})
		end,
	})

	use({ "catppuccin/nvim", as = "catppuccin" })

	use({
		"github/copilot.vim",
		config = function()
			vim.keymap.set("i", "<C-d>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
		end,
	})
end)
