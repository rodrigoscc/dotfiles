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
			{ "rafamadriz/friendly-snippets" }, -- Optional
		},
	})

	use("HiPhish/nvim-ts-rainbow2")

	use({
		"windwp/nvim-autopairs",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({})
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
			require("barbecue").setup()
		end,
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = "|",
					section_separators = "",
				},
			})
		end,
	})

	use({
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				sidebars = { "qf", "help", "neotest-summary" },
			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	})

	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup()
		end,
	})

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})

	use({
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	})

	use("lukas-reineke/indent-blankline.nvim")

	use("tpope/vim-sleuth")

	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
		config = function()
			require("toggleterm").setup()
		end,
	})

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
			require("treesj").setup({
				use_default_keymaps = false,
			})
		end,
	})

	use({
		"tpope/vim-dispatch",
		config = function() end,
	})

	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})

	use({
		"lukas-reineke/virt-column.nvim",
		config = function()
			require("virt-column").setup({
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
		end,
	})

	use({
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				filetypes_denylist = { "NvimTree" },
			})
		end,
	})

	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup()
		end,
	})

	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons", -- optional
		},
		config = function()
			require("nvim-tree").setup({
				update_focused_file = {
					enable = true,
				},
				hijack_directories = {
					enable = false, -- no auto open
				},
				sort_by = "modification_time",
				hijack_cursor = true,
				view = {
					mappings = {
						list = {
							{
								key = "ga",
								action = "Git add",
								action_cb = function(node)
									vim.cmd("Git add " .. node.absolute_path)
								end,
							},
						},
					},
				},
			})
		end,
	})

	use({
		"benfowler/telescope-luasnip.nvim",
	})

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

	use({ "stevearc/dressing.nvim" })

	use({ "ThePrimeagen/harpoon" })
end)
