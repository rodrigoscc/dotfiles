local project = require("after.plugin.http.project")
local display = require("after.plugin.http.display")
local http = require("after.plugin.http.http")

local M = {}

M.update_env = function(override_variables)
	vim.schedule(function()
		project.update_active_env(override_variables)
	end)
end

M.run_request = function(title, override_variables)
	vim.schedule(function()
		http:run_with_title(title, override_variables)
	end)
end

M.show = function(request, response, output)
	vim.schedule(function()
		display.show(request, response, output)
	end)
end

return M
