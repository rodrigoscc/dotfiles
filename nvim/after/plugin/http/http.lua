local env = require("after.plugin.http.env")
local hooks = require("after.plugin.http.hooks")
local job = require("after.plugin.http.job")
local project = require("after.plugin.http.project")

---@class Http
---@field last_request http.Request
---@field last_override_context table?
local Http = {}
Http.__index = Http

function Http.new()
	return setmetatable({
		last_request = nil,
		last_override_context = nil,
	}, Http)
end

local function interp(s, tab)
	return (
		s:gsub("({%b{}})", function(w)
			return tab[w:sub(3, -3)] or w
		end)
	)
end

---Use context to complete the request content
---@param content http.RequestContent
---@param context table
function Http:complete_content(content, context)
	---@type http.RequestContent
	local completed_content = { headers = {} }

	if content.json_body ~= nil then
		completed_content.json_body = interp(content.json_body, context)
	elseif content.url_encoded_body ~= nil then
		completed_content.url_encoded_body =
			interp(content.url_encoded_body, context)
	end

	if content.headers ~= nil then
		local replaced_headers = {}
		for _, header in ipairs(content.headers) do
			table.insert(replaced_headers, interp(header, context))
		end

		completed_content.headers = replaced_headers
	end

	return completed_content
end

---Use context to complete request data
---@param request http.Request
---@param context table
function Http:complete_request(request, context)
	local completed_request = {
		method = request.method,
		url = interp(request.url, context),
		query = request.query and interp(request.query, context),
		node = request.node,
		local_context = request.local_context,
		source = request.source,
	}

	return completed_request
end

---Runs a request
---@param request http.Request
---@param override_context table?
function Http:run(request, override_context)
	self.last_request = request
	self.last_override_context = override_context

	local source = request.source

	local env_context = project.get_env_variables()
	local source_context = source:get_request_context(request)

	local context = vim.tbl_extend(
		"force",
		env_context,
		source_context,
		request.local_context
	)

	if override_context ~= nil then
		context = vim.tbl_extend("force", context, override_context)
	end

	local content = source:get_request_content(request)

	request = self:complete_request(request, context)
	content = self:complete_content(content, context)

	local before_hook, after_hook = hooks.load_hook_functions(
		request.local_context["request.before_hook"],
		request.local_context["request.after_hook"]
	)

	local start_request = function()
		local project_env = project.get_active_env()

		local request_job = job.request_to_job(
			request,
			content,
			job.on_exit_func(
				request,
				after_hook,
				project_env,
				function(title, override_context)
					self:run_with_title(title, override_context)
				end
			)
		)

		request_job:start()
	end

	if before_hook ~= nil then
		before_hook(request, start_request)
	else
		start_request()
	end
end

function Http:run_last()
	if self.last_request == nil then
		return
	end

	self:run(self.last_request, self.last_override_context)
end

function Http:run_with_title(title, override_context)
	local requests = project.get_requests()

	local request_item = nil

	for _, request in ipairs(requests) do
		local r_title = request.local_context["request.title"]
		if r_title == title then
			request_item = request
			break
		end
	end

	if request_item == nil then
		error("request not found")
	end

	local _, request = unpack(request_item)
	self:run(request, override_context)
end

return Http
