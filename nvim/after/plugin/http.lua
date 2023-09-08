local Job = require("plenary.job")

local DEFAULT_BODY_TYPE = "text"

local diagnostics_namespace = vim.api.nvim_create_namespace("http")

-- TODO: Change parser name from http2 to something else.
local request_query = vim.treesitter.query.parse(
	"http2",
	[[
[
 (method_url) @method_url
 (header) @header
 (json_body) @json_body
]
]]
)

local variables_query = vim.treesitter.query.parse(
	"http2",
	[[
(
 (variable_declaration
	variable_name: (identifier) @name
	variable_value: (rest_of_line) @value)
 .
 (variable_declaration)*
 .
 (method_url)? @request_below
)
]]
)

local function interp(s, tab)
	return (
		s:gsub("({%b{}})", function(w)
			return tab[w:sub(3, -3)] or w
		end)
	)
end

vim.g.http_envs_dir = ".envs"
vim.g.http_hooks_file = "hooks.lua"

local function create_file(filename, mode)
	local dir = vim.fs.dirname(filename)
	vim.fn.mkdir(dir, "p", "0o755")

	local file, err = io.open(filename, "w+")
	if file == nil then
		error("Unable to create file " .. filename .. ": " .. err)
	end

	local success, err = file:write("{}")
	if not success then
		error("Unable to create file " .. filename .. ": " .. err)
	end

	file:close()

	-- Reopening it with a different mode.
	return io.open(filename, mode)
end

local function get_envs_file(mode)
	local data_path = vim.fn.stdpath("data")
	local envs_file_path = data_path .. "/http/envs.json"

	local envs_file, err = io.open(envs_file_path, mode)
	if envs_file == nil then
		vim.print(
			"Unable to open envs file "
				.. envs_file_path
				.. ": "
				.. err
				.. ", attempting to create it..."
		)
		envs_file = create_file(envs_file_path, mode)
	end

	return envs_file
end

local function get_envs()
	local envs_file = get_envs_file("r")
	local contents = envs_file:read("*a")
	return vim.json.decode(contents)
end

function GetProjectEnv()
	local envs = get_envs()
	if envs == nil then
		error("Unable to get project environments")
	end

	return envs[vim.fn.getcwd()]
end

local function get_env_file(env, mode)
	local project_env_file = vim.g.http_envs_dir .. "/" .. env .. ".json"

	local env_file, err = io.open(project_env_file, mode)
	if err ~= nil then
		vim.api.nvim_err_writeln(
			"Unable to open env file " .. project_env_file .. ": " .. err
		)
	end

	return env_file
end

local function get_context_from_env()
	local project_env = GetProjectEnv()
	if project_env == nil then
		return {}
	end

	local env_file = get_env_file(project_env, "r")
	if env_file == nil then
		return {}
	end

	local env_file_contents = env_file:read("*a")
	return vim.json.decode(env_file_contents)
end

local builtin_variables = {
	["request.title"] = "title",
	["request.before_hook"] = "before_hook",
	["request.after_hook"] = "after_hook",
}

local function apply_current_buffer_context(context, request)
	local parser = vim.treesitter.get_parser(0, "http2")
	local tree = parser:parse()[1]

	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	for _, match in variables_query:iter_matches(tree:root(), 0, 0, cursor_row) do
		local variable = {}

		local request_below_node = nil

		for id, node in pairs(match) do
			local capture_name = variables_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, 0))

			if capture_name == "request_below" then
				request_below_node = node
			else
				variable[capture_name] = capture_value
			end
		end

		local is_local_variable = vim.startswith(variable.name, "request.")
		local below_request_matches =
			request.request_node:equal(request_below_node)

		local variable_applies = not is_local_variable
			or (is_local_variable and below_request_matches)

		local builtin_variable_name = builtin_variables[variable.name]
		local is_builtin_variable = builtin_variable_name ~= nil

		if variable_applies then
			if is_builtin_variable then
				request[builtin_variable_name] = variable.value
			else
				context[variable.name] = variable.value
			end
		end
	end
end

local function get_context(request)
	local context = get_context_from_env()
	apply_current_buffer_context(context, request)
	return context
end

local function get_all_requests()
	local requests = {}

	local parser = vim.treesitter.get_parser(0, "http2")
	local tree = parser:parse()[1]

	for _, match in request_query:iter_matches(tree:root(), 0) do
		for id, node in pairs(match) do
			local capture_name = request_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, 0))

			if capture_name == "method_url" then
				local new_request =
					{ method_url = capture_value, request_node = node }
				-- method_url defines the start of the next request.
				table.insert(requests, new_request)
			elseif capture_name == "header" then
				if requests[#requests]["headers"] == nil then
					requests[#requests]["headers"] = {}
				end

				table.insert(requests[#requests]["headers"], capture_value)
			else
				requests[#requests][capture_name] = capture_value
			end
		end
	end

	return requests
end

local function get_closest_request()
	local requests = get_all_requests()

	local closest_distance = nil
	local closest_request = nil

	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	for _, request in ipairs(requests) do
		local row, _, _, _ = request.request_node:range()

		local request_distance = cursor_row - row
		local request_is_above_cursor = request_distance > 0

		-- Get closest request above the cursor.
		if
			closest_distance == nil
			or (request_is_above_cursor and request_distance < closest_distance)
		then
			closest_distance = request_distance
			closest_request = request
		end
	end

	return closest_request
end

local function replace_context(request, context)
	request.context = context

	if request.json_body ~= nil then
		request.json_body = interp(request.json_body, context)
	end

	request.method_url = interp(request.method_url, context)

	if request.headers ~= nil then
		local replaced_headers = {}
		for _, header in ipairs(request.headers) do
			table.insert(replaced_headers, interp(header, context))
		end

		request.headers = replaced_headers
	end
end

local function request_to_job(request, on_exit)
	local args = {
		"--include",
		"--no-progress-meter",
	}

	if request.json_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, request.json_body)
	end

	if request.headers ~= nil then
		for _, header in ipairs(request.headers) do
			table.insert(args, "--header")
			table.insert(args, header)
		end
	end

	table.insert(args, "--request")
	for _, s in ipairs(vim.split(request.method_url, " ")) do
		table.insert(args, s)
	end

	return Job:new({
		command = "curl",
		args = args,
		on_exit = on_exit,
	})
end

local function get_body_file_type(headers)
	local body_file_type = DEFAULT_BODY_TYPE

	local content_type = headers["Content-Type"]
	if string.find(content_type, "application/json") then
		body_file_type = "json"
	elseif
		string.find(content_type, "application/xml")
		or string.find(content_type, "text/xml")
	then
		body_file_type = "xml"
	elseif string.find(content_type, "text/html") then
		body_file_type = "xml"
	end

	return body_file_type
end

local function parse_http_headers_lines(headers_lines)
	local parsed_headers = {}
	for _, header_line in ipairs(headers_lines) do
		local name, value = unpack(vim.split(header_line, ": "))
		-- NOTE: Header lines lacking ": " will have a value of nil, therefore
		-- will be ignored (header[name) = nil).
		parsed_headers[name] = value
	end

	return parsed_headers
end

local function parse_status_code(status_code_line)
	local splits = vim.split(status_code_line, " ")

	return tonumber(splits[2])
end

local function parse_job_results(return_value, result, stderr_result)
	if return_value ~= 0 then
		vim.list_extend(result, stderr_result)

		return {
			is_error = true,
			buffers = {
				{
					file_type = "text",
					content = result,
				},
			},
		}
	end

	local separation_line = nil

	for index, line in ipairs(result) do
		local is_empty_line = line == ""
		if is_empty_line then
			separation_line = index
		end
	end

	if separation_line == nil then
		error("Unable to parse curl response")
	end

	-- Starting at 1 to drop the http version line, like "HTTP/1.1 200 OK".
	local headers_lines = vim.list_slice(result, 1, separation_line - 1)
	local body_lines = vim.list_slice(result, separation_line + 1, #result)

	local parsed_headers = parse_http_headers_lines(headers_lines)

	local parsed_body = ""
	local body_joined = table.concat(body_lines, "\n")

	local body_file_type = get_body_file_type(parsed_headers)

	if body_file_type == "json" then
		parsed_body = vim.json.decode(body_joined)
	else
		parsed_body = body_joined
	end

	local parsed_status_code = parse_status_code(result[1])

	return {
		status_code = parsed_status_code,
		body = parsed_body,
		headers = parsed_headers,
		is_error = false,
		buffers = {
			{
				file_type = "http",
				content = headers_lines,
				vertical_split = false,
			},
			{
				file_type = body_file_type,
				content = body_lines,
				vertical_split = true,
			},
		},
	}
end

local function on_curl_exit(result)
	vim.schedule(function()
		if result.is_error then
			vim.api.nvim_err_writeln("Error running request")
		else
			vim.print("Done")
		end

		for _, buffer in ipairs(result.buffers) do
			local buf = vim.api.nvim_create_buf(true, true)
			vim.api.nvim_buf_set_option(buf, "filetype", buffer.file_type)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer.content)

			if buffer.vertical_split then
				vim.cmd.vsplit()
			else
				vim.cmd.split()
			end

			vim.api.nvim_set_current_buf(buf)

			-- Avoid formatting curl error messages which are meant to be shown
			-- on text buffers.
			if buffer.file_type ~= "text" then
				vim.cmd([[normal gq%]])
			end

			vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })
		end
	end)
end

local function update_project_env(env)
	local envs_file = get_envs_file("r")
	local contents = envs_file:read("*a")
	local envs = vim.json.decode(contents)

	envs[vim.fn.getcwd()] = env

	envs_file = get_envs_file("w+")

	local envs_file_updated = vim.json.encode(envs)

	envs_file:write(envs_file_updated)
	envs_file:close()
end

local function update_env(env_name)
	return function(tbl)
		local env_file = get_env_file(env_name, "r")
		if env_file == nil then
			return
		end

		local env_file_contents = env_file:read("*a")
		local env = vim.json.decode(env_file_contents)
		env = vim.tbl_extend("force", env, tbl)

		local new_env_file_contents = vim.json.encode(env)
		env_file = get_env_file(env_name, "w+")
		env_file:write(new_env_file_contents)
		env_file:close()

		-- TODO: format json
	end
end

local function get_available_envs()
	local available_envs = {}

	for file in vim.fs.dir(vim.g.http_envs_dir) do
		if vim.endswith(file, ".json") then
			local env_name = string.sub(file, 0, -6)
			table.insert(available_envs, env_name)
		end
	end

	return available_envs
end

function ChangeEnv()
	local available_envs = get_available_envs()

	vim.ui.select(
		available_envs,
		{ prompt = "Change environment" },
		function(env)
			if env ~= nil then
				update_project_env(env)
			end
		end
	)
end

function NewProjectEnv()
	vim.fn.mkdir(vim.g.http_envs_dir, "p")
	vim.ui.input({ prompt = "New environment" }, function(input)
		local env_file = input .. ".json"
		vim.cmd([[split ]] .. vim.g.http_envs_dir .. "/" .. env_file)
		-- TODO: Automatically populate an empty json and activate this env.
	end)
end

local function open_env(env)
	local env_file = vim.g.http_envs_dir .. "/" .. env .. ".json"
	vim.cmd("split " .. env_file)
end

function OpenProjectEnv()
	local available_envs = get_available_envs()

	vim.ui.select(available_envs, { prompt = "Open env" }, function(env)
		if env ~= nil then
			open_env(env)
		end
	end)
end

local function get_hooks(before_hook, after_hook)
	local hooks_path = vim.g.http_envs_dir .. "/" .. vim.g.http_hooks_file

	local f = io.open(hooks_path, "r")
	local hooks_file_exists = f ~= nil

	if hooks_file_exists then
		local hooks = dofile(hooks_path)
		return hooks[before_hook], hooks[after_hook]
	end

	return nil, nil
end

function RunClosestRequest()
	local request = get_closest_request()

	local context = get_context(request)

	local before_hook, after_hook =
		get_hooks(request.before_hook, request.after_hook)

	if before_hook ~= nil then
		before_hook(request, context)
	end

	replace_context(request, context)

	local project_env = GetProjectEnv()

	local job = request_to_job(request, function(j, return_value)
		local result =
			parse_job_results(return_value, j:result(), j:stderr_result())

		if after_hook ~= nil then
			after_hook(request, context, {
				status_code = result.status_code,
				body = result.body,
				headers = result.headers,
				is_error = result.is_error,
			}, update_env(project_env))
		end

		on_curl_exit(result)
	end)
	vim.print("Executing HTTP request...")
	job:start()
end

function OpenHooksFile()
	local hooks_path = vim.g.http_envs_dir .. "/" .. vim.g.http_hooks_file
	vim.cmd([[split ]] .. hooks_path)
end

function ShowCursorVariableValue()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here.")

	if node:type() ~= "variable_ref" then
		vim.api.nvim_err_writeln("Cursor is not at a variable reference node.")
		return
	end

	local node_text = vim.treesitter.get_node_text(node, 0)
	local variable_name = string.sub(node_text, 3, #node_text - 2)

	local request = get_closest_request()
	local context = get_context(request)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local value = context[variable_name]
	if value == nil then
		value = ""
	end

	vim.diagnostic.set(diagnostics_namespace, 0, {
		{
			lnum = row - 1,
			col = col,
			message = variable_name .. " = " .. value,
			severity = vim.diagnostic.severity.INFO,
		},
	}, {
		signs = false,
		virtual_text = {
			prefix = "",
			format = function(diagnostic)
				return diagnostic.message
			end,
		},
	})
end

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "http",
	callback = function()
		vim.keymap.set("n", "R", RunClosestRequest, { buffer = true })
		vim.keymap.set("n", "K", ShowCursorVariableValue, { buffer = true })
	end,
})

vim.keymap.set("n", "<leader>ne", NewProjectEnv, { desc = "[n]ew [e]nv" })
vim.keymap.set("n", "<leader>ee", ChangeEnv, { desc = "change [e]nv" })
vim.keymap.set("n", "<leader>oe", OpenProjectEnv, { desc = "[o]pen [e]nv" })
vim.keymap.set(
	"n",
	"<leader>oh",
	OpenHooksFile,
	{ desc = "[o]pen [h]ooks file" }
)
