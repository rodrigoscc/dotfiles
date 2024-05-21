local Source = require("after.plugin.http.source").Source
local SourceType = require("after.plugin.http.source").type
local settings = require("after.plugin.http.settings")
local env = require("after.plugin.http.env")
local utils = require("after.plugin.http.utils")

local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with

local M = {}

M.get_requests = function()
	local files = vim.fs.find(function(name)
		return vim.endswith(name, ".http")
	end, { type = "file", limit = math.huge, path = settings.http_dir })

	---@type http.Request[]
	local requests = {}

	for _, file in ipairs(files) do
		local source = Source.new(SourceType.FILE, file)
		local file_requests = source:get_requests()
		vim.list_extend(requests, file_requests)
	end

	return requests
end

M.get_existing_envs = function()
	if vim.fn.findfile(settings.project_envs_file_path) == "" then
		return {}
	end

	local envs_file_contents = with(
		open(settings.project_envs_file_path, "r"),
		function(reader)
			return reader:read("*a")
		end
	)

	return vim.json.decode(envs_file_contents) or {}
end

M.get_active_env = function()
	local all_active_envs = env.get_all_active_envs()
	local active_env = all_active_envs[vim.fn.getcwd()]
	if active_env == nil then
		return nil
	end

	return active_env
end

M.get_env_variables = function()
	local active_env = M.get_active_env()
	if active_env == nil then
		return {}
	end

	local envs = M.get_existing_envs()

	return envs[active_env] or {}
end

M.update_env = function(env_name)
	return function(override_variables)
		vim.schedule(function()
			local envs = M.get_existing_envs()
			local variables = envs[env_name]
			variables = vim.tbl_extend("force", variables, override_variables)
			envs[env_name] = variables

			local updated_envs = vim.json.encode(envs)
			updated_envs = utils.format_if_jq_installed(updated_envs)

			utils.make_sure_file_exists(settings.project_envs_file_path)

			with(open(settings.project_envs_file_path, "w+"), function(file)
				file:write(updated_envs)
			end)
		end)
	end
end

M.new_env = function(new_env)
	utils.make_sure_file_exists(settings.project_envs_file_path)

	local envs = M.get_existing_envs()

	envs[new_env] = vim.empty_dict()

	local new_envs_file_contents = vim.json.encode(envs)

	new_envs_file_contents =
		utils.format_if_jq_installed(new_envs_file_contents)

	with(open(settings.project_envs_file_path, "w+"), function(file)
		file:write(new_envs_file_contents)
	end)

	M.open_env(new_env)
	M.activate_env(new_env)
end

M.open_env = function(e)
	settings.open_project_envs_file()
	vim.fn.search('"' .. e .. '"')
end

M.activate_env = function(e)
	utils.make_sure_file_exists(settings.active_envs_file_path)

	local active_envs = env.get_all_active_envs()

	active_envs[vim.fn.getcwd()] = e

	with(open(settings.active_envs_file_path, "w+"), function(file)
		local envs_file_updated = vim.json.encode(active_envs)

		envs_file_updated = utils.format_if_jq_installed(envs_file_updated)

		file:write(envs_file_updated)
	end)
end

return M
