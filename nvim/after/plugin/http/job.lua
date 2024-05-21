local Job = require("plenary.job")
local project = require("after.plugin.http.project")
local url = require("after.plugin.http.requests").url
local id = require("after.plugin.http.requests").id

local M = {}

local DEFAULT_BODY_TYPE = "text"

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

---@class http.ResultBuffer
---@field file_type string
---@field content string[]
---@field vertical_split boolean

---Parse job result and get response and buffers
---@param job Job
---@param return_value number
---@return http.Response?
---@return http.ResultBuffer[]
local function parse_job_results(job, return_value)
	local result = job:result()
	local stderr_result = job:stderr_result()

	---@type http.ResultBuffer[]
	local buffers = {}

	if return_value ~= 0 then
		vim.list_extend(result, stderr_result)

		buffers = {
			{
				file_type = "text",
				content = result,
				vertical_split = false,
			},
		}

		return nil, buffers
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
	}

	---@type http.Response
	local response = {
		status_code = parsed_status_code,
		body = parsed_body,
		headers = parsed_headers,
		ok = true,
	}

	return response, buffers
end

---Show results of curl request
---@param request http.Request
---@param response http.Response?
---@param buffers http.ResultBuffer[]
local function on_curl_exit(request, response, buffers)
	vim.schedule(function()
		local request_id = id(request)
		if response and response.ok then
			vim.print("Running HTTP request " .. request_id .. "...Done")
		else
			vim.print("Running HTTP request " .. request_id .. "...ERROR")
		end

		for _, buffer in ipairs(buffers) do
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

local function minify_json(json_body)
	return vim.json.encode(vim.json.decode(json_body))
end

---Create a plenary job to run request
---@param request http.Request
---@param content http.RequestContent
---@param on_exit any
---@return Job
M.request_to_job = function(request, content, on_exit)
	local args = {
		"--include",
		"--location",
		"--no-progress-meter",
		"--write-out",
		"\n%{size_header}", -- Used to split header from body when parsing
	}

	if content.json_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, minify_json(content.json_body))
	elseif content.url_encoded_body ~= nil then
		table.insert(args, "--data")
		table.insert(args, content.url_encoded_body)
	end

	if content.headers ~= nil then
		for _, header in ipairs(content.headers) do
			table.insert(args, "--header")
			table.insert(args, header)
		end
	end

	table.insert(args, "--request")
	table.insert(args, request.method)

	table.insert(args, url(request))

	return Job:new({
		command = "curl",
		args = args,
		on_exit = on_exit,
	})
end

M.on_exit_func = function(
	request,
	after_hook,
	project_env,
	run_request_with_title
)
	return function(j, return_value)
		local response, buffers = parse_job_results(j, return_value)

		if after_hook == nil then
			on_curl_exit(request, response, buffers)
		else
			after_hook(
				request,
				response,
				buffers,
				on_curl_exit,
				project.update_env(project_env),
				run_request_with_title
			)
		end
	end
end

return M
