return {
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
}
