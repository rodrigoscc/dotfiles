vim.api.nvim_create_user_command("InitCommitlint", function()
	vim.system({
		"npm",
		"list",
		"--depth",
		"1",
		"--global",
		"@commitlint/config-conventional",
	}, { text = true }, function(out)
		local success = out.code == 0

		if success then
			vim.schedule(function()
				vim.cmd(
					[[!echo '{"extends": ["@commitlint/config-conventional"]}' > .commitlintrc.json]]
				)
			end)
		else
			vim.print(
				"Please install @commitlint/config-conventional globally."
			)
		end
	end)
end, {})
