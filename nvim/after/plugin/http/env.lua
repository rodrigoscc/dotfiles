local settings = require("after.plugin.http.settings")

local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with

local M = {}

M.get_all_active_envs = function()
	if vim.fn.findfile(settings.active_envs_file_path) == "" then
		return {}
	end

	local contents = with(
		open(settings.active_envs_file_path, "r"),
		function(reader)
			return reader:read("*a")
		end
	)

	local active_envs = vim.json.decode(contents)
	if active_envs == nil then
		return {}
	end

	return active_envs
end

return M
