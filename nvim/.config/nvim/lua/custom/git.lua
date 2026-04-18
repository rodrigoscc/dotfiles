local uv = vim.uv or vim.loop

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

local git_cache = {} ---@type table<string, boolean>
local function is_git_root(dir)
	if git_cache[dir] == nil then
		git_cache[dir] = uv.fs_stat(dir .. "/.git") ~= nil
	end
	return git_cache[dir]
end

--- Gets the git root for a buffer or path.
---@param path? number|string buffer or path
---@return string?
local function get_root(path)
	path = path or 0
	path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path --[[@as string]]
	path = path == "" and uv.cwd() or path
	path = vim.fs.normalize(path)

	if is_git_root(path) then
		return path
	end

	for dir in vim.fs.parents(path) do
		if is_git_root(dir) then
			return vim.fs.normalize(dir)
		end
	end

	return os.getenv("GIT_WORK_TREE")
end

return { branch = branch, get_root = get_root }
