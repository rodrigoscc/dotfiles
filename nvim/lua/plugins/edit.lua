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
				surrounds = {
					-- Do not add enclosing whitespace on either character
					["("] = {
						add = { "(", ")" },
					},
					["{"] = {
						add = { "{", "}" },
					},
					["["] = {
						add = { "[", "]" },
					},
					["<"] = {
						add = { "<", ">" },
					},
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
				rust = { "rustfmt" },
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
						"F401,F541,I001,I002,EM101,RUF010",
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
				"COM812,COM819,ANN201,D101,D102,D103,D107,D100,RET505,RET506,RET507,RET508,ERA001,UP006,FA100,TRY003,EM101,EM102,SIM108",
				"--no-fix",
				"--output-format",
				"json",
				"-",
			}
		end,
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
	{
		"saghen/blink.pairs",
		version = "*", -- (recommended) only required with prebuilt binaries

		-- download prebuilt binaries from github releases
		dependencies = "saghen/blink.download",
		-- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		--- @module 'blink.pairs'
		--- @type blink.pairs.Config
		opts = {
			mappings = {
				-- you can call require("blink.pairs.mappings").enable() and require("blink.pairs.mappings").disable() to enable/disable mappings at runtime
				enabled = true,
				-- you may also disable with `vim.g.pairs = false` (global) or `vim.b.pairs = false` (per-buffer)
				disabled_filetypes = {},
				-- see the defaults: https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L12
				pairs = {},
			},
			highlights = {
				enabled = true,
				groups = {
					"BlinkPairsRed",
					"BlinkPairsPurple",
					"BlinkPairsOrange",
					"BlinkPairsBlue",
				},
				matchparen = {
					enabled = true,
					group = "MatchParen",
				},
			},
			debug = false,
		},
	},
}
