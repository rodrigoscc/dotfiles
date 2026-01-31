return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fb",
				function()
					require("conform").format({ bufnr = 0 })
				end,
				desc = "[f]ormat [b]uffer",
			},
		},
		opts = {
			notify_on_error = false, -- It's annoying to save and having to press Enter.
			format_on_save = function(bufnr)
				if vim.b[0].disable_autoformat then
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
				markdown = { "injected", "trim_whitespace" },
				["_"] = { "trim_whitespace" }, -- for filetypes that don't have other formatters configured.
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
				-- Require a Prettier configuration file to format.
				prettier = { require_cwd = true },
			},
		},
	},
}
