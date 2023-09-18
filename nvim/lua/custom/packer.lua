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

	use("tpope/vim-rhubarb")

	use({ "folke/neodev.nvim" })

	use({
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "hrsh7th/cmp-buffer" }, -- Optional
			{ "hrsh7th/cmp-path" }, -- Optional
			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
			{ "hrsh7th/cmp-nvim-lua" }, -- Optional

			-- Snippets
			{ "L3MON4D3/LuaSnip" }, -- Required
			-- { "rafamadriz/friendly-snippets" }, -- Optional
		},
	})

	use({
		"windwp/nvim-autopairs",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				fast_wrap = {
					map = "<C-f>",
				},
			})
		end,
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

	use({ "rose-pine/neovim", as = "rose-pine" })
	use({
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
				integrations = {
					barbecue = {
						dim_context = true,
					},
					neogit = true,
					illuminate = true,
					gitgutter = true,
					ts_rainbow2 = true,
					neotree = true,
				},
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
			vim.cmd(
				"let g:indent_blankline_buftype_exclude = ['terminal', 'quickfix', 'prompt']"
			)
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

	use({ "tpope/vim-dispatch" })

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
			})
		end,
		requires = "nvim-treesitter/nvim-treesitter",
	})

	use("Vimjas/vim-python-pep8-indent")

	use("onsails/lspkind.nvim")

	use({
		"nvim-neotest/neotest",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
			"rstcruzo/neotest-go", -- for testify workarounds
			"haydenmeade/neotest-jest",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						is_test_file = function(file_path)
							local Path = require("plenary.path")

							if not vim.endswith(file_path, ".py") then
								return false
							end
							local elems =
								vim.split(file_path, Path.path.sep, {})
							local file_name = elems[#elems]
							return (
								vim.startswith(file_name, "test_")
								or vim.endswith(file_name, "_test.py")
								or file_name == "tests.py"
							)
						end,
					}),
					require("neotest-go"),
					require("neotest-jest"),
				},
			})
		end,
	})

	use({
		"williamboman/mason.nvim",
		"jose-elias-alvarez/null-ls.nvim",
		"jay-babu/mason-null-ls.nvim",
	})

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

	use({ "anuvyklack/hydra.nvim" })

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

	use({ "HiPhish/rainbow-delimiters.nvim" })

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

	use({
		"sainnhe/gruvbox-material",
		config = function()
			vim.cmd([[let g:gruvbox_material_background = "hard"]])
		end,
	})
end)
