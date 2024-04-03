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
					"isort",
					"autoflake",
					"black",
				},
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
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
				isort = {
					prepend_args = { "--profile", "black" },
				},
				black = {
					prepend_args = { "--line-length", "79" },
				},
				autoflake = {
					prepend_args = { "--remove-all-unused-imports" },
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
				python = { "flake8" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{ "github/copilot.vim" },
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
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
}
