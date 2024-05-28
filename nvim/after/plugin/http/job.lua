local Job = require("plenary.job")
local display = require("after.plugin.http.display")
local utils = require("after.plugin.http.utils")
local url = require("after.plugin.http.requests").url

local M = {}

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

local function parse_status_line(headers_lines)
	local status_line = headers_lines[1]
	return status_line
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

---Parse job result and get http response from it
---@param job Job
---@return http.Response
local function parse_response(job)
	local result = job:result()

	local headers_lines, body_lines = split_header_and_body(result)

	local status_line = parse_status_line(headers_lines)
	local parsed_headers = parse_http_headers_lines(headers_lines)

	local parsed_body = ""
	local body_joined = table.concat(body_lines, "\n")

	local body_file_type = utils.get_body_file_type(parsed_headers)

	if body_file_type == "json" then
		parsed_body = vim.json.decode(body_joined)
	else
		parsed_body = body_joined
	end

	local parsed_status_code = parse_status_code(result[1])

	---@type http.Response
	local response = {
		status_code = parsed_status_code,
		status_line = status_line,
		body = parsed_body,
		headers = parsed_headers,
		ok = true,
	}

	return response
end

local function minify_json(json_body)
	return vim.json.encode(vim.json.decode(json_body))
end

---Create a plenary job to run request
---@param request http.Request
---@param content http.RequestContent
---@param on_exit function(job: Job, code: number, signal: number)
---@return Job
M.request_to_job = function(request, content, on_exit)
	local args = {
		"--include",
		"--location",
		"--no-progress-meter",
		"--write-out",
		"\n%{size_header}", -- Used to split header from body when parsing
	}

	if content.body ~= nil then
		local body = content.body

		local file_type = utils.get_content_type(content)
		if file_type == "application/json" then
			-- minifying just to minimize network load
			body = minify_json(body)
		end

		table.insert(args, "--data")
		table.insert(args, body)
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

M.on_exit_func = function(request, after_hook)
	return function(job, code)
		local stdout = job:result()
		local stderr = job:stderr_result()

		vim.list_extend(stdout, stderr)

		local response = nil

		if code == 0 then
			response = parse_response(job)
		end

		if after_hook == nil then
			vim.schedule(function()
				display.show(response, stdout)
			end)
		else
			after_hook(request, response, stdout)
		end
	end
end

return M
