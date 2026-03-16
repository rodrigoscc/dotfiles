local function branch()
	local obj = vim.system(
		{ "git", "branch", "--show-current" },
		{ text = true }
	)

	local out = obj:wait()

	if out.code ~= 0 then
		return nil
	end

	return vim.trim(out.stdout)
end

return { branch = branch }
