return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					normal = "gs",
					normal_cur = "gss",
					normal_line = "gS",
					normal_cur_line = "ySS",
					insert = "<C-g>s",
					insert_line = "<C-g>S",
					visual = "gs", -- Remapping visual mode mapping to avoid conflicts with flash.nvim mappings.
					visual_line = "gS", -- Remapping visual mode mapping to avoid conflicts with flash.nvim mappings.
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
	},
	{
		"Wansmer/treesj",
		lazy = true,
		keys = { "<space>J" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
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
	},
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false, -- It's annoying to save and having to press Enter.
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat then
					return
				end

				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = {
					"ruff_fix",
					"ruff_format",
				},
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				go = { "golines", "injected" }, -- golines run goimports and gofmt if found.
				json = { "fixjson" },
				sql = { "sql_formatter" },
				sh = { "beautysh" },
				bash = { "beautysh" },
				zsh = { "beautysh" },
				proto = { "buf" },
			},
			formatters = {
				golines = {
					prepend_args = { "-m", "80", "--no-reformat-tags" },
				},
				stylua = {
					prepend_args = { "--column-width=80" },
				},
				ruff_fix = {
					args = {
						"check",
						"--fix",
						"--force-exclude",
						"--exit-zero",
						"--no-cache",
						"--select",
						"I001,I002",
						"--extend-unfixable",
						"RET505,RET506,RET507,RET508",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				},
				ruff_format = {
					args = {
						"format",
						"--force-exclude",
						"--line-length",
						"79",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				},
				sql_formatter = {
					prepend_args = { "--config", '{"keywordCase": "upper"}' },
				},
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				python = { "ruff" },
				go = { "golangcilint" },
				lua = { "selene" },
				gitcommit = { "commitlint" },
				NeogitCommitMessage = { "commitlint" },
				svelte = { "eslint" },
				typescript = { "eslint" },
				typescriptreact = { "eslint" },
				javascript = { "eslint" },
				javascriptreact = { "eslint" },
				proto = { "buf_lint" },
			}

			vim.api.nvim_create_autocmd(
				{ "BufWritePost", "BufReadPost", "TextChanged", "InsertLeave" },
				{
					callback = function()
						require("lint").try_lint()
					end,
				}
			)

			local ruff = require("lint").linters.ruff
			ruff.args = {
				"check",
				"--force-exclude",
				"--quiet",
				"--stdin-filename",
				function()
					return vim.api.nvim_buf_get_name(0)
				end,
				"--select",
				"ALL",
				"--extend-ignore",
				"COM812,COM819,ANN201,D101,D102,D103,D107,D100,RET505,RET506,RET507,RET508,ERA001,UP006,FA100",
				"--no-fix",
				"--output-format",
				"json",
				"-",
			}
		end,
	},
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			cmap = false, -- It's a pain to have this enabled in command-line mode.
		},
	},
	{
		"windwp/nvim-ts-autotag",
		opts = {},
		lazy = true,
		ft = {
			"html",
			"xml",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"vue",
			"svelte",
		},
	},
	{ "Glench/Vim-Jinja2-Syntax" },
	{
		"danymat/neogen",
		lazy = true,
		keys = {
			{
				"<leader>id",
				"<cmd>Neogen<cr>",
				desc = "[i]nsert [d]ocumentation",
			},
		},
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
	{ "b0o/schemastore.nvim", lazy = true, ft = { "json", "yaml" } },
}
