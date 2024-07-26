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

local function buf_errors_to_qflist()
	local diagnostics =
		vim.diagnostic.get(0, { severity = { vim.diagnostic.severity.ERROR } })
	local items = vim.diagnostic.toqflist(diagnostics)
	vim.fn.setqflist(items)
	vim.cmd.copen()
end

vim.api.nvim_create_user_command("BufErrors", buf_errors_to_qflist, {})
