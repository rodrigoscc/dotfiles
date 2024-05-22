local queries = require("after.plugin.http.queries")

local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with

local function extract_method_and_url(method_url)
	local valid_methods = {
		"GET",
		"POST",
		"PUT",
		"PATCH",
		"DELETE",
		"OPTIONS",
		"HEAD",
		"CONNECT",
		"TRACE",
	}

	local space_separated = vim.split(method_url, " ")

	local method = space_separated[1]
	local url = method_url:sub(#method + 2) -- Url is after method string and a space.

	local starts_with_method = vim.tbl_contains(valid_methods, method)

	if not starts_with_method then
		method = "GET"
		url = method_url
	end

	return method, url
end

---@enum http.SourceType
local source_type = {
	BUFFER = "buffer",
	FILE = "file",
}

---@class http.Source
---@field type http.SourceType
---@field repr string|integer
---@field route string|integer
local Source = {}
Source.__index = Source

function Source.new(type, repr)
	local route = repr

	if type == source_type.FILE then
		route = repr
		repr = with(open(repr, "r"), function(reader)
			return reader:read("*a")
		end)
	end

	local obj = setmetatable({
		type = type,
		repr = repr,
		route = route,
	}, Source)

	return obj
end

function Source:get_parser()
	if self.type == source_type.BUFFER then
		return vim.treesitter.get_parser(self.repr, "http2")
	elseif self.type == source_type.FILE then
		return vim.treesitter.get_string_parser(self.repr, "http2")
	end
end

function Source:get_tree()
	local parser = self:get_parser()
	return parser:parse()[1]
end

function Source:get_buffer_requests()
	local tree = self:get_tree()

	if tree == nil then
		return {}
	end

	---@type http.Request[]
	local requests = {}

	local above_local_context = {}

	for _, match in queries.requests_query:iter_matches(tree:root(), self.repr) do
		local variable = nil

		for id, node in pairs(match) do
			local capture_name = queries.requests_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, self.repr))

			if capture_name == "request" then
				local method, url = extract_method_and_url(capture_value)

				local domain_path, query = unpack(vim.split(url, "?"))

				---@type http.Request
				local request = {
					url = domain_path,
					method = method,
					query = query,
					node = node,
					local_context = above_local_context,
					source = self,
				}

				table.insert(requests, request)
				above_local_context = {}
			elseif capture_name == "variable_name" then
				variable = { name = capture_value, value = "" }
			elseif capture_name == "variable_value" then
				if variable then
					variable.value = capture_value
				end
			end
		end

		if variable then
			above_local_context[variable.name] = variable.value
			variable = nil
		end
	end

	return requests
end

function Source:get_file_requests()
	local tree = self:get_tree()

	---@type http.Request[]
	local requests = {}

	local above_local_context = {}

	for _, match in queries.requests_query:iter_matches(tree:root(), self.repr) do
		local variable = nil

		for id, node in pairs(match) do
			local capture_name = queries.requests_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, self.repr))

			if capture_name == "request" then
				local method, url = extract_method_and_url(capture_value)

				local domain_path, query = unpack(vim.split(url, "?"))

				local request = {
					url = domain_path,
					method = method,
					query = query,
					node = node,
					local_context = above_local_context,
					source = self,
				}

				above_local_context = {}

				table.insert(requests, request)
			elseif capture_name == "variable_name" then
				variable = { name = capture_value, value = "" }
			elseif capture_name == "variable_value" then
				if variable then
					variable.value = capture_value
				end
			end
		end

		if variable then
			above_local_context[variable.name] = variable.value
			variable = nil
		end
	end

	return requests
end

function Source:get_requests()
	if Source.type == source_type.BUFFER then
		return self:get_buffer_requests()
	else
		return self:get_file_requests()
	end
end

function Source:get_closest_request(row)
	local requests = self:get_requests()

	local closest_distance = nil
	local closest_request = nil

	for _, request in ipairs(requests) do
		local node_row, _, _, _ = request.node:range()

		local distance = row - node_row
		local is_above_cursor = distance > 0

		-- Get closest request above the cursor.
		if
			closest_distance == nil
			or (is_above_cursor and distance < closest_distance)
		then
			closest_distance = distance
			closest_request = request
		end
	end

	return closest_request
end

---@class http.Variable
---@field name string
---@field value string

function Source:get_variable_name(node) end

---Gets request context from this source.
---@param request http.Request
function Source:get_request_context(request)
	local tree = self:get_tree()

	local stop, _, _, _ = request.node:range()

	local context = {}

	for _, match in
		queries.variables_query:iter_matches(tree:root(), self.repr, 0, stop)
	do
		---@type http.Variable
		local variable = { name = "", value = "" }

		for id, node in pairs(match) do
			local capture_name = queries.variables_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, self.repr))

			-- capture_name is either "name" or "value"
			variable[capture_name] = capture_value
		end

		context[variable.name] = variable.value
	end

	return context
end

function Source:get_request_content(request)
	local tree = self:get_tree()

	local start, _, _, _ = request.node:range()
	local _, _, stop, _ = tree:root():range()

	---@type http.RequestContent
	local content = { headers = {} }

	for _, match in
		queries.request_content_query:iter_matches(
			tree:root(),
			self.repr,
			start + 1,
			stop + 1
		)
	do
		for id, node in pairs(match) do
			local capture_name = queries.request_content_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, self.repr))

			if capture_name == "next_request" then
				-- Got to next request, no need to keep going.
				return content
			elseif capture_name == "header" then
				content.headers[#content.headers + 1] = capture_value
			elseif capture_name == "body" then
				content.body = capture_value
			end
		end
	end

	return content
end

return { Source = Source, type = source_type }
