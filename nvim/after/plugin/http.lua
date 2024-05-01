local Job = require("plenary.job")
local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with
local Path = require("plenary.path")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

local log = require("plenary.log").new({ plugin = "http", use_console = false })

local ts_utils = require("nvim-treesitter.ts_utils")

local DEFAULT_BODY_TYPE = "text"

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
local requests_only_query = vim.treesitter.query.parse(
	"http2",
	[[
 (method_url) @request
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
 (url_encoded_body) @url_encoded_body
 (method_url) @next_request
]
]]
)

local function url_encode(str, opts)
	opts = opts or { keep_allowed_chars_in_path = false }

	str = str:gsub("\r?\n", "\r\n")

	-- We may need to keep forward slashes when encoding the url path.
	if opts.keep_allowed_chars_in_path then
		str = str:gsub("([^%w%-%.%_%~%/%?%& ])", function(c)
			return string.format("%%%02X", c:byte())
		end)
	else
		str = str:gsub("([^%w%-%.%_%~ ])", function(c)
			return string.format("%%%02X", c:byte())
		end)
	end

	str = str:gsub(" ", "+")
	return str
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
	end
end

vim.g.http_dir = ".http"
vim.g.http_hooks_file = "hooks.lua"
vim.g.http_environments_file = "environments.json"

local current_project_envs_file_path = vim.g.http_dir
	.. "/"
	.. vim.g.http_environments_file
local project_current_envs_file_path = vim.fn.stdpath("data")
	.. "/http/envs.json"

local function create_file(filename, mode)
	local dir = vim.fs.dirname(filename)
	vim.fn.mkdir(dir, "p", "0o755")

	with(open(filename, "w+"), function(file)
		file:write("{}")
	end)
end

local function make_sure_file_exists(filename)
	local exists = vim.fn.findfile(filename) ~= ""
	if not exists then
		create_file(filename)
	end
end

local function get_projects_current_env()
	if vim.fn.findfile(project_current_envs_file_path) == "" then
		return {}
	end

	local contents = with(
		open(project_current_envs_file_path, "r"),
		function(reader)
			return reader:read("*a")
		end
	)

	local project_current_envs = vim.json.decode(contents)
	if project_current_envs == nil then
		return {}
	end
	return project_current_envs
end

function GetProjectEnv()
	local envs = get_projects_current_env()
	return envs[vim.fn.getcwd()]
end

local function get_current_project_envs()
	if vim.fn.findfile(current_project_envs_file_path) == "" then
		return {}
	end

	local envs_file_contents = with(
		open(current_project_envs_file_path, "r"),
		function(reader)
			return reader:read("*a")
		end
	)

	local envs = vim.json.decode(envs_file_contents)
	if envs == nil then
		return {}
	end

	return envs
end

local function get_context_from_env()
	local project_env = GetProjectEnv()
	if project_env == nil then
		return {}
	end

	local envs = get_current_project_envs()

	local context = envs[project_env]
	if context == nil then
		return {}
	end

	return context
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

local function split_host_and_path(url)
	local scheme_position = url:find("://")

	local scheme_end_index = 0
	if scheme_position ~= nil then
		scheme_end_index = scheme_position + 3
	end

	local first_slash_index = url:find("/", scheme_end_index)

	local is_path_empty = first_slash_index == nil
	if is_path_empty then
		return url, ""
	end

	local host = url:sub(1, first_slash_index - 1)
	local path = url:sub(first_slash_index)

	return host, path
end

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
				local method, url = extract_method_and_url(capture_value)

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
			elseif capture_name == "url_encoded_body" then
				content.url_encoded_body = capture_value
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

local function get_request_detail(
	request,
	source,
	source_type,
	override_context
)
	local request_context = get_context(request, source, source_type)

	if override_context ~= nil then
		request_context =
			vim.tbl_extend("force", request_context, override_context)
	end

	request.context = request_context

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
		encoded_context[key] = url_encode(tostring(value))
	end

	local interp_url = interp(request.url, request.context)

	-- Encode path after interpolating context in url path because,
	-- variables need to be replaced before.
	local domain, path = split_host_and_path(interp_url)
	path = url_encode(path, { keep_allowed_chars_in_path = true })
	interp_url = domain .. path

	local raw_content = {
		method = request.method,
		url = interp_url,
		query = request.query and interp(request.query, encoded_context),
	}

	if request.content.json_body ~= nil then
		raw_content.json_body =
			interp(request.content.json_body, request.context)
	elseif request.content.url_encoded_body ~= nil then
		raw_content.url_encoded_body =
			interp(request.content.url_encoded_body, request.context)
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
		"--location",
		"--no-progress-meter",
		"--write-out",
		"\n%{size_header}", -- Used to split header from body when parsing
	}

	if request.json_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, minify_json(request.json_body))
	elseif request.url_encoded_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, request.url_encoded_body)
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

	local content_type = headers["Content-Type"] or headers["content-type"]
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
		local is_a_header_line = not vim.startswith(header_line, "HTTP/")

		if is_a_header_line then
			local name, value = unpack(vim.split(header_line, ":"))

			name = vim.trim(name)
			value = vim.trim(value)

			-- NOTE: Header lines lacking ": " will have a value of nil, therefore
			-- will be ignored (header[name) = nil).
			parsed_headers[name] = value
		end
	end

	return parsed_headers
end

local function parse_status_code(status_code_line)
	local splits = vim.split(status_code_line, " ")

	return tonumber(splits[2])
end

local function split_header_and_body(result)
	local last_line = result[#result]
	local header_size = tonumber(last_line)

	for index, line in ipairs(result) do
		header_size = header_size - #line - 2 -- new line characters \r\n

		if header_size <= 0 then
			local separation_line = index

			local headers_lines = vim.list_slice(result, 0, separation_line - 1) -- Exclude empty line
			local body_lines =
				vim.list_slice(result, separation_line + 1, #result - 1) -- Exclude header size line and empty line

			return headers_lines, body_lines
		end
	end

	-- All the output is headers
	return result, {}
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

	local headers_lines, body_lines = split_header_and_body(result)

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

local function format_if_jq_installed(json)
	if vim.fn.executable("jq") == 1 then
		return vim.fn.system("jq --sort-keys '.' <<< '" .. json .. "'")
	else
		return json
	end
end

local function update_project_env(env)
	make_sure_file_exists(current_project_envs_file_path)

	local projects_current_env = get_projects_current_env()

	projects_current_env[vim.fn.getcwd()] = env

	with(open(project_current_envs_file_path, "w+"), function(file)
		local envs_file_updated = vim.json.encode(projects_current_env)

		envs_file_updated = format_if_jq_installed(envs_file_updated)

		file:write(envs_file_updated)
	end)
end

local function update_env(env_name)
	return function(tbl)
		vim.schedule(function()
			local envs = get_current_project_envs()

			local current_env = envs[env_name]

			current_env = vim.tbl_extend("force", current_env, tbl)

			envs[env_name] = current_env

			local new_envs_file_contents = vim.json.encode(envs)

			make_sure_file_exists(current_project_envs_file_path)

			new_envs_file_contents =
				format_if_jq_installed(new_envs_file_contents)

			with(open(current_project_envs_file_path, "w+"), function(file)
				file:write(new_envs_file_contents)
			end)
		end)
	end
end

function ChangeEnv()
	local envs = get_current_project_envs()
	local available_envs = vim.tbl_keys(envs)

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

local function jump_to_env(env)
	vim.fn.search('"' .. env .. '"')
end

local function open_env(env)
	vim.cmd("split " .. vim.g.http_dir .. "/" .. vim.g.http_environments_file)
	jump_to_env(env)
end

function NewProjectEnv()
	vim.fn.mkdir(vim.g.http_dir, "p")
	vim.ui.input({ prompt = "New environment" }, function(input)
		if input == nil then
			return
		end

		make_sure_file_exists(current_project_envs_file_path)

		local envs = get_current_project_envs()

		envs[input] = vim.empty_dict()

		local new_envs_file_contents = vim.json.encode(envs)

		new_envs_file_contents = format_if_jq_installed(new_envs_file_contents)

		with(open(current_project_envs_file_path, "w+"), function(file)
			file:write(new_envs_file_contents)
		end)

		open_env(input)
		update_project_env(input)
	end)
end

function OpenProjectEnv()
	local envs = get_current_project_envs()
	local available_envs = vim.tbl_keys(envs)

	vim.ui.select(available_envs, { prompt = "Open env" }, function(env)
		if env ~= nil then
			open_env(env)
		end
	end)
end

local function get_hooks(before_hook, after_hook)
	local hooks_path = Path:new(vim.g.http_dir, vim.g.http_hooks_file)

	if not hooks_path:exists() then
		return nil, nil
	end

	local hooks_file_exists = with(
		open(hooks_path:absolute(), "r"),
		function(file)
			return file ~= nil
		end
	)

	if hooks_file_exists then
		local hooks = dofile(hooks_path:absolute())
		if hooks == nil then
			return nil, nil
		end

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

local function run_request(request, source, source_type, override_context)
	LastRun = {
		request = request,
		source = source,
		source_type = source_type,
		override_context = override_context,
	}

	request = get_request_detail(request, source, source_type, override_context)

	local before_hook, after_hook = get_hooks(
		request.local_context["request.before_hook"],
		request.local_context["request.after_hook"]
	)

	local start_request = function()
		local project_env = GetProjectEnv()

		local job = request_to_job(request, function(j, return_value)
			local result =
				parse_job_results(return_value, j:result(), j:stderr_result())

			if after_hook == nil then
				on_curl_exit(request, result)
			elseif after_hook ~= nil then
				after_hook(
					request,
					result,
					on_curl_exit,
					update_env(project_env),
					function(title, override_context)
						vim.schedule(function()
							RunRequestWithTitle(title, override_context)
						end)
					end
				)
			end
		end)

		local title = request_title(request)
		log.fmt_info("Running HTTP request %s: %s", title, job_to_string(job))
		vim.print("Running HTTP request " .. title .. "...")

		job:start()
	end

	if before_hook ~= nil then
		before_hook(request, start_request)
	else
		start_request()
	end
end

function RunClosestRequest()
	local request = get_closest_request()
	run_request(request, vim.fn.bufnr(), "buffer")
end

function OpenHooksFile()
	local hooks_path = Path:new(vim.g.http_dir, vim.g.http_hooks_file)
	vim.cmd([[split ]] .. hooks_path:absolute())
end

function ShowCursorVariableValue()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here.")

	if node:type() ~= "variable_ref" then
		vim.api.nvim_err_writeln("Cursor is not at a variable reference node.")
		return
	end

	local node_text =
		vim.trim(vim.treesitter.get_node_text(node, vim.fn.bufnr()))
	local variable_name = string.sub(node_text, 3, #node_text - 2)

	local request = get_closest_request()
	local context = get_context(request, vim.fn.bufnr(), "buffer")

	local value = context[variable_name]
	if value == nil then
		value = ""
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, { value })
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		width = math.max(#value, 8),
		height = 1,
		col = 0,
		row = 1,
		anchor = "NW",
		style = "minimal",
		border = "single",
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "CursorMoved" }, {
		callback = function()
			if vim.api.nvim_win_is_valid(win) then -- Needed in case window is already closed.
				vim.api.nvim_win_close(win, false)
			end
		end,
		once = true,
		buffer = 0,
	})
end

local function get_all_http_files()
	return vim.fs.find(function(name)
		return vim.endswith(name, ".http")
	end, { type = "file", limit = math.huge, path = vim.g.http_dir })
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

	pickers
		.new({}, {
			prompt_title = "Go to HTTP request",
			finder = finders.new_table({
				results = requests,
				entry_maker = function(item)
					local file, request = unpack(item)

					local line, _, _ = request.node:start()

					return {
						value = request_title(request),
						ordinal = request_title(request),
						display = request_title(request),
						filename = file,
						lnum = line + 1,
					}
				end,
			}),
			previewer = conf.grep_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
		})
		:find()
end

function RunRequest()
	local requests = get_project_requests()

	pickers
		.new({}, {
			prompt_title = "Run HTTP request",
			finder = finders.new_table({
				results = requests,
				entry_maker = function(item)
					local file, request = unpack(item)

					local line, _, _ = request.node:start()

					return {
						value = request_title(request),
						ordinal = request_title(request),
						display = request_title(request),
						filename = file,
						lnum = line + 1,
						request = request,
					}
				end,
			}),
			previewer = conf.grep_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				local run_selected_request = function()
					actions.close(prompt_bufnr)

					local selection =
						require("telescope.actions.state").get_selected_entry()
					run_request(selection.request, selection.filename, "file")
				end

				map("i", "<CR>", run_selected_request)
				map("n", "<CR>", run_selected_request)

				return true
			end,
		})
		:find()
end

function RunLastRequest()
	if LastRun ~= nil then
		run_request(
			LastRun.request,
			LastRun.source,
			LastRun.source_type,
			LastRun.override_context
		)
	else
		vim.print("No last http request.")
	end
end

function RunRequestWithTitle(title, override_context)
	local requests = get_project_requests()

	local request_item = nil

	for _, item in ipairs(requests) do
		local _, r = unpack(item)
		local r_title = r.local_context["request.title"]
		if r_title == title then
			request_item = item
			break
		end
	end

	if request_item == nil then
		error("request not found")
	end

	local file, request = unpack(request_item)
	run_request(request, file, "file", override_context)
end

function JumpNextRequest()
	local parser = get_source_parser(0, "buffer")

	local tree = parser:parse()[1]

	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local _, _, stop, _ = tree:root():range()

	local _, match =
		requests_only_query:iter_matches(tree:root(), 0, cursor_row, stop)()

	local ids = vim.tbl_keys(match)
	local node = match[ids[1]]
	ts_utils.goto_node(node, false, true)
end

function JumpPreviousRequest()
	local parser = get_source_parser(0, "buffer")

	local tree = parser:parse()[1]

	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local last_match = nil

	for _, match in
		requests_only_query:iter_matches(tree:root(), 0, 0, cursor_row - 1)
	do
		last_match = match
	end

	local ids = vim.tbl_keys(last_match)
	local node = last_match[ids[1]]
	ts_utils.goto_node(node, false, true)
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

vim.keymap.set("n", "]r", function()
	vim.g.set_jump(JumpNextRequest, JumpPreviousRequest)
	JumpNextRequest()
end, { desc = "jump to next request" })
vim.keymap.set("n", "[r", function()
	vim.g.set_jump(JumpNextRequest, JumpPreviousRequest)
	JumpPreviousRequest()
end, { desc = "jump to previous request" })
