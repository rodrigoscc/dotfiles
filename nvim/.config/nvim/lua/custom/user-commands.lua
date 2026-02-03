local function npm_on_exit(out)
	local success = out.code == 0

	if success then
		vim.schedule(function()
			vim.cmd(
				[[!echo '{"extends": ["@commitlint/config-conventional"]}' > .commitlintrc.json]]
			)
		end)
	else
		vim.print("Please install @commitlint/config-conventional globally.")
	end
end

vim.api.nvim_create_user_command("InitCommitlint", function()
	vim.system({
		"npm",
		"list",
		"--depth",
		"1",
		"--global",
		"@commitlint/config-conventional",
	}, { text = true }, npm_on_exit)
end, {})

local function buf_errors_to_qflist(opts)
	local is_visual_selection = opts.range == 2

	local diagnostics = {}

	if is_visual_selection then
		for lnum = opts.line1, opts.line2 do
			local line_diagnostics = vim.diagnostic.get(
				0,
				{ severity = vim.diagnostic.severity.ERROR, lnum = lnum - 1 }
			)
			diagnostics = vim.list_extend(diagnostics, line_diagnostics)
		end
	else
		diagnostics =
			vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	end

	local items = vim.diagnostic.toqflist(diagnostics)
	vim.fn.setqflist(items)
	vim.cmd.copen()
end

vim.api.nvim_create_user_command(
	"BufErrors",
	buf_errors_to_qflist,
	{ range = true }
)

vim.api.nvim_create_user_command("ToggleInlayHints", function()
	vim.g.inlay_hints = not vim.g.inlay_hints
	vim.lsp.inlay_hint.enable(vim.g.inlay_hints)
end, { desc = "Toggle inlay hints", nargs = 0 })

vim.keymap.set(
	"n",
	"<leader>ti",
	"<cmd>ToggleInlayHints<cr>",
	{ desc = "toggle inlay hints" }
)
