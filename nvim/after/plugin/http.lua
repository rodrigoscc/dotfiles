local Job = require("plenary.job")
local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with
local Path = require("plenary.path")

local log = require("plenary.log").new({ plugin = "http", use_console = false })

local ts_utils = require("nvim-treesitter.ts_utils")

local DEFAULT_BODY_TYPE = "text"

local diagnostics_namespace = vim.api.nvim_create_namespace("http")

-- TODO: Change parser name from http2 to something else.
local requests_query = vim.treesitter.query.parse(
	"http2",
	[[
[
 (variable_declaration
	variable_name: (identifier) @variable_name (#lua-match? @variable_name "request.*")
	variable_value: (rest_of_line) @variable_value)
 (method_url) @request
]
]]
)

local variables_query = vim.treesitter.query.parse(
	"http2",
	[[
 (variable_declaration
	variable_name: (identifier) @name (#not-lua-match? @name "request.*")
	variable_value: (rest_of_line) @value)
]]
)

local request_content_query = vim.treesitter.query.parse(
	"http2",
	[[
[
 (header) @header
 (json_body) @json_body
 (method_url) @next_request
]
]]
)

local function url_encode(str)
	if type(str) ~= "number" then
		str = str:gsub("\r?\n", "\r\n")
		str = str:gsub("([^%w%-%.%_%~ ])", function(c)
			return string.format("%%%02X", c:byte())
		end)
		str = str:gsub(" ", "+")
		return str
	else
		return str
	end
end

local function interp(s, tab)
	return (
		s:gsub("({%b{}})", function(w)
			return tab[w:sub(3, -3)] or w
		end)
	)
end

local function get_request_url(request)
	local url = request.url
	if request.query ~= nil then
		url = url .. "?" .. request.query
	end

	return url
end

local function request_title(request)
	local title = request.local_context["request.title"]

	if title == nil then
		return request.method .. " " .. get_request_url(request)
	else
		return title
			.. " ("
			.. request.method
			.. " "
			.. get_request_url(request)
			.. ")"
	end
end

vim.g.http_envs_dir = ".envs"
vim.g.http_hooks_file = "hooks.lua"

local function create_file(filename, mode)
	local dir = vim.fs.dirname(filename)
	vim.fn.mkdir(dir, "p", "0o755")

	with(open(filename, "w+"), function(file)
		file:write("{}")
	end)

	-- Reopening it with a different mode.
	return open(filename, mode)
end

local function get_envs_file(mode)
	local data_path = vim.fn.stdpath("data")
	local envs_file_path = data_path .. "/http/envs.json"

	local envs_file, err = open(envs_file_path, mode)
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
	local contents = with(get_envs_file("r"), function(reader)
		return reader:read("*a")
	end)
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

	local env_file, err = open(project_env_file, mode)
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

	local env_file_contents = with(
		get_env_file(project_env, "r"),
		function(reader)
			return reader:read("*a")
		end
	)

	return vim.json.decode(env_file_contents)
end

local function get_source_parser(source, source_type)
	local parser = nil

	if source_type == "buffer" then
		parser = vim.treesitter.get_parser(source, "http2")
	elseif source_type == "file" then
		parser = vim.treesitter.get_string_parser(source, "http2")
	end

	return parser
end

local function get_source(source, source_type)
	if source_type == "buffer" then
		return source
	elseif source_type == "file" then
		local contents = with(open(source, "r"), function(reader)
			return reader:read("*a")
		end)

		return contents
	end
end

local function get_request_list(source, source_type)
	source = get_source(source, source_type)
	local parser = get_source_parser(source, source_type)

	local tree = parser:parse()[1]

	local requests = { { local_context = {} } }

	for _, match in requests_query:iter_matches(tree:root(), source) do
		local variable = {}

		for id, node in pairs(match) do
			local capture_name = requests_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, source))

			if capture_name == "request" then
				local method, url = unpack(vim.split(capture_value, " "))
				local domain_path, query = unpack(vim.split(url, "?"))

				requests[#requests].method = method
				requests[#requests].url = domain_path
				requests[#requests].query = query
				requests[#requests].node = node

				table.insert(requests, { local_context = {} })
			elseif capture_name == "variable_name" then
				variable.name = capture_value
			elseif capture_name == "variable_value" then
				variable.value = capture_value
			end
		end

		if variable.name then
			requests[#requests].local_context[variable.name] = variable.value
		end
	end

	-- TODO: Review this
	requests = vim.list_slice(requests, 0, #requests - 1)

	return requests
end

local function get_request_context_in(source, source_type, request)
	source = get_source(source, source_type)
	local parser = get_source_parser(source, source_type)

	local tree = parser:parse()[1]

	local stop, _, _, _ = request.node:range()

	local context = {}

	for _, match in variables_query:iter_matches(tree:root(), source, 0, stop) do
		local variable = {}

		for id, node in pairs(match) do
			local capture_name = variables_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, source))

			variable[capture_name] = capture_value
		end

		context[variable.name] = variable.value
	end

	return context
end

local function get_request_content(request, source, source_type)
	source = get_source(source, source_type)
	local parser = get_source_parser(source, source_type)

	local tree = parser:parse()[1]

	local start, _, _, _ = request.node:range()
	local _, _, stop, _ = tree:root():range()

	local content = {}

	for _, match in
		request_content_query:iter_matches(
			tree:root(),
			source,
			start + 1,
			stop + 1
		)
	do
		for id, node in pairs(match) do
			local capture_name = request_content_query.captures[id]
			local capture_value =
				vim.trim(vim.treesitter.get_node_text(node, source))

			if capture_name == "next_request" then
				-- Got to next request, no need to keep going.
				return content
			elseif capture_name == "header" then
				if content.headers == nil then
					content.headers = {}
				end

				content.headers[#content.headers + 1] = capture_value
			elseif capture_name == "json_body" and content.json_body == nil then
				-- Checking if json_body is null to make sure we're not replacing
				-- the body with a nested json.
				content.json_body = capture_value
			end
		end
	end

	return content
end

local function get_context(request, source, source_type)
	local env_context = get_context_from_env()
	local source_context = get_request_context_in(source, source_type, request)

	return vim.tbl_extend(
		"force",
		env_context,
		source_context,
		request.local_context
	)
end

local function get_request_detail(request, source, source_type)
	request.context = get_context(request, source, source_type)

	local content = get_request_content(request, source, source_type)

	request.content = content

	return request
end

local function get_closest_request()
	local requests = get_request_list(vim.fn.bufnr(), "buffer")

	local closest_distance = nil
	local closest_request = nil

	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	for _, request in ipairs(requests) do
		local row, _, _, _ = request.node:range()

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

local function get_raw_request_content(request)
	local encoded_context = vim.deepcopy(request.context)

	for key, value in pairs(encoded_context) do
		encoded_context[key] = url_encode(value)
	end

	local raw_content = {
		method = request.method,
		url = interp(request.url, request.context),
		query = request.query and interp(request.query, encoded_context),
	}

	if request.content.json_body ~= nil then
		raw_content.json_body =
			interp(request.content.json_body, request.context)
	end

	if request.content.headers ~= nil then
		local replaced_headers = {}
		for _, header in ipairs(request.content.headers) do
			table.insert(replaced_headers, interp(header, request.context))
		end

		raw_content.headers = replaced_headers
	end

	return raw_content
end

local function minify_json(json_body)
	return vim.json.encode(vim.json.decode(json_body))
end

local function request_to_job(request, on_exit)
	request = get_raw_request_content(request)

	local args = {
		"--include",
		"--no-progress-meter",
	}

	if request.json_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, minify_json(request.json_body))
	end

	if request.headers ~= nil then
		for _, header in ipairs(request.headers) do
			table.insert(args, "--header")
			table.insert(args, header)
		end
	end

	table.insert(args, "--request")
	table.insert(args, request.method)

	table.insert(args, get_request_url(request))

	return Job:new({
		command = "curl",
		args = args,
		on_exit = on_exit,
	})
end

local function get_body_file_type(headers)
	local body_file_type = DEFAULT_BODY_TYPE

	local content_type = headers["Content-Type"]
	if content_type == nil then
		return body_file_type
	end

	if string.find(content_type, "application/json") then
		body_file_type = "json"
	elseif
		string.find(content_type, "application/xml")
		or string.find(content_type, "text/xml")
	then
		body_file_type = "xml"
	elseif string.find(content_type, "text/html") then
		body_file_type = "html"
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

local function on_curl_exit(request, result)
	vim.schedule(function()
		local title = request_title(request)
		if result.is_error then
			vim.print("Running HTTP request " .. title .. "...ERROR")
		else
			vim.print("Running HTTP request " .. title .. "...Done")
		end

		for _, buffer in ipairs(result.buffers) do
			local buf = vim.api.nvim_create_buf(true, true)
			vim.api.nvim_buf_set_option(buf, "filetype", buffer.file_type)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer.content)

			if buffer.vertical_split then
				vim.cmd([[vsplit]])
			else
				vim.cmd([[15split]])
			end

			vim.api.nvim_set_current_buf(buf)

			-- Avoid formatting curl error messages which are meant to be shown
			-- on text buffers.
			if buffer.file_type ~= "text" then
				vim.cmd([[silent exe "normal gq%"]])
			end

			vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })
		end
	end)
end

local function update_project_env(env)
	local contents = with(get_envs_file("r"), function(reader)
		return reader:read("*a")
	end)

	local envs = vim.json.decode(contents)

	envs[vim.fn.getcwd()] = env

	with(get_envs_file("w+"), function(file)
		local envs_file_updated = vim.json.encode(envs)
		file:write(envs_file_updated)
	end)
end

local function update_env(env_name)
	return function(tbl)
		local env_file_contents = with(
			get_env_file(env_name, "r"),
			function(reader)
				return reader:read("*a")
			end
		)

		local env = vim.json.decode(env_file_contents)
		env = vim.tbl_extend("force", env, tbl)

		local new_env_file_contents = vim.json.encode(env)

		with(get_env_file(env_name, "w+"), function(file)
			file:write(new_env_file_contents)
		end)
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
	local hooks_path = Path:new(vim.g.http_envs_dir, vim.g.http_hooks_file)

	local hooks_file_exists = with(
		open(hooks_path:absolute(), "r"),
		function(file)
			return file ~= nil
		end
	)

	if hooks_file_exists then
		local hooks = dofile(hooks_path:absolute())
		return hooks[before_hook], hooks[after_hook]
	end

	return nil, nil
end

LastRun = nil

local function job_to_string(job)
	local str = job.command

	for _, arg in ipairs(job.args) do
		str = str .. " " .. arg
	end

	return str
end

local function run_request(request, source, source_type)
	LastRun = { request = request, source = source, source_type = source_type }

	request = get_request_detail(request, source, source_type)

	local before_hook, after_hook = get_hooks(
		request.local_context["request.before_hook"],
		request.local_context["request.after_hook"]
	)

	if before_hook ~= nil then
		before_hook(request)
	end

	local project_env = GetProjectEnv()

	local job = request_to_job(request, function(j, return_value)
		local result =
			parse_job_results(return_value, j:result(), j:stderr_result())

		if after_hook ~= nil then
			after_hook(request, {
				status_code = result.status_code,
				body = result.body,
				headers = result.headers,
				is_error = result.is_error,
			}, update_env(project_env))
		end

		on_curl_exit(request, result)
	end)

	local title = request_title(request)
	log.fmt_info("Running HTTP request %s: %s", title, job_to_string(job))
	vim.print("Running HTTP request " .. title .. "...")

	job:start()
end

function RunClosestRequest()
	local request = get_closest_request()
	run_request(request, vim.fn.bufnr(), "buffer")
end

function OpenHooksFile()
	local hooks_path = Path:new(vim.g.http_envs_dir, vim.g.http_hooks_file)
	vim.cmd([[split ]] .. hooks_path:absolute())
end

function ShowCursorVariableValue()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here.")

	if node:type() ~= "variable_ref" then
		vim.api.nvim_err_writeln("Cursor is not at a variable reference node.")
		return
	end

	local node_text = vim.treesitter.get_node_text(node, vim.fn.bufnr())
	local variable_name = string.sub(node_text, 3, #node_text - 2)

	local request = get_closest_request()
	local context = get_context(request, vim.fn.bufnr(), "buffer")

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
			prefix = "󰀫",
			format = function(diagnostic)
				return diagnostic.message
			end,
		},
	})
end

local function get_all_http_files()
	return vim.fs.find(function(name)
		return vim.endswith(name, ".http")
	end, { type = "file", limit = math.huge })
end

local function get_project_requests()
	local files = get_all_http_files()

	local requests = {}

	for _, file in ipairs(files) do
		local file_requests = get_request_list(file, "file")

		for _, request in ipairs(file_requests) do
			table.insert(requests, { file, request })
		end
	end

	return requests
end

function GoToRequest()
	local requests = get_project_requests()

	vim.ui.select(requests, {
		prompt = "Go to HTTP request",
		format_item = function(item)
			local _, request = unpack(item)
			return request_title(request)
		end,
	}, function(item)
		if item == nil then
			return
		end

		local file, request = unpack(item)

		vim.cmd([[edit ]] .. file)
		ts_utils.goto_node(request.node, false, true)
	end)
end

function RunRequest()
	local requests = get_project_requests()

	vim.ui.select(requests, {
		prompt = "Run HTTP request",
		format_item = function(item)
			local _, request = unpack(item)
			return request_title(request)
		end,
	}, function(item)
		if item == nil then
			return
		end

		local file, request = unpack(item)

		run_request(request, file, "file")
	end)
end

function RunLastRequest()
	if LastRun ~= nil then
		run_request(LastRun.request, LastRun.source, LastRun.source_type)
	else
		vim.print("No last http request.")
	end
end

local http_source = {}

function http_source:is_available()
	local node = vim.treesitter.get_node()

	if node == nil then
		return false
	end

	local cursor_node_is_variable_ref = node:type() == "variable_ref"

	local child = node:child(0)
	local child_is_variable_ref = false

	if child ~= nil then
		child_is_variable_ref = child:type() == "variable_ref"
	end

	return cursor_node_is_variable_ref or child_is_variable_ref
end

function http_source:complete(params, callback)
	local options = {}

	local request = get_closest_request()
	local context = get_context(request, 0, "buffer")

	for variable, value in pairs(context) do
		table.insert(options, {
			label = variable,
			detail = value,
			kind = 6, -- variable
		})
	end

	callback(options)
end

function http_source:get_debug_name()
	return "http source"
end

local cmp = require("cmp")

cmp.register_source("http", http_source)
cmp.setup.filetype("http", {
	sources = cmp.config.sources({
		{ name = "http" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
		{ name = "luasnip", keyword_length = 2 },
	}),
})

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
vim.keymap.set("n", "gh", GoToRequest, { desc = "go to http request" })
vim.keymap.set("n", "gH", RunRequest, { desc = "run http request" })
vim.keymap.set("n", "gL", RunLastRequest, { desc = "run last http request" })
