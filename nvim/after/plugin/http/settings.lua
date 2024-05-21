local M = {}

M.http_dir = ".http"
M.http_hooks_file = "hooks.lua"
M.http_environments_file = "environments.json"

M.project_envs_file_path = M.http_dir .. "/" .. M.http_environments_file
M.hooks_file_path = M.http_dir .. "/" .. M.http_hooks_file

M.active_envs_file_path = vim.fn.stdpath("data") .. "/http/envs.json"

M.open_project_envs_file = function()
	vim.cmd("split " .. M.project_envs_file_path)
end

M.open_hooks_file = function()
	vim.cmd([[split ]] .. M.hooks_file_path)
end

return M
