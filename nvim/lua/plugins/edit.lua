return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<M-g>s",
					insert_line = "<M-g>S",
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
		keys = { "<space>J" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			use_default_keymaps = false,
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
				ruff_fix = {
					args = {
						"check",
						"--fix",
						"--force-exclude",
						"--exit-zero",
						"--no-cache",
						"--select",
						"ALL",
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
			}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})

			local ruff = require("lint").linters.ruff
			ruff.args = {
				"--force-exclude",
				"--quiet",
				"--stdin-filename",
				function()
					return vim.api.nvim_buf_get_name(0)
				end,
				"--select",
				"ALL",
				"--extend-ignore",
				"COM812,COM819,ANN201,D101,D102,D103,D107,D100",
				"--no-fix",
				"--output-format",
				"json",
				"-",
			}
		end,
	},
	{ "github/copilot.vim" },
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			cmap = false, -- It's a pain to have this enabled in command-line mode.

			fastwarp = {
				map = "<C-g>",
				rmap = "<C-r>",
				cmap = "<C-g>",
				rcmap = "<C-r>",
			},
		},
	},
	{ "windwp/nvim-ts-autotag" },
	{ "Glench/Vim-Jinja2-Syntax" },
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
	{ "benfowler/telescope-luasnip.nvim" },
	{ "xiyaowong/telescope-emoji.nvim" },
}
