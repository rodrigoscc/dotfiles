return {
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
				"COM812,COM819,ANN201,D101,D102,D103,D107,D100,RET505,RET506,RET507,RET508,ERA001,UP006,FA100,TRY003,EM101,EM102,SIM108,RET504,S101",
				"--no-fix",
				"--output-format",
				"json",
				"-",
			}
		end,
	},
}
