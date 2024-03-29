return {
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
		"gaoDean/autolist.nvim",
		ft = {
			"markdown",
			"text",
			"tex",
			"plaintex",
			"norg",
		},
		config = function()
			require("autolist").setup()

			vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
			vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
			-- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
			vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
			vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
			vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
			vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
			vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

			-- cycle list types with dot-repeat
			vim.keymap.set(
				"n",
				"<leader>cn",
				require("autolist").cycle_next_dr,
				{ expr = true }
			)
			vim.keymap.set(
				"n",
				"<leader>cp",
				require("autolist").cycle_prev_dr,
				{ expr = true }
			)

			-- if you don't want dot-repeat
			-- vim.keymap.set("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
			-- vim.keymap.set("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")

			-- functions to recalculate list on edit
			vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
			vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
			vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
			vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
		end,
	},
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			fastwarp = {
				map = "<C-;>",
				rmap = "<C-r>",
				cmap = "<C-;>",
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
