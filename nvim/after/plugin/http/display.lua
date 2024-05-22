local utils = require("after.plugin.http.utils")

local M = {}

M.show_in_floating = function(contents)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, { contents })
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		width = math.max(#contents, 8),
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

local function headers_to_lines(status_line, headers)
	local lines = { status_line }
	for key, value in pairs(headers) do
		table.insert(lines, key .. ": " .. value)
	end

	return lines
end

local function body_to_lines(response, file_type)
	if file_type == "json" then
		return vim.split(vim.fn.json_encode(response.body), "\n")
	end

	return vim.split(response.body, "\n")
end

---Display http response in buffers
---@param response http.Response
local function show_response(response)
	local header_lines =
		headers_to_lines(response.status_line, response.headers)

	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_set_option_value("filetype", "http", { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, header_lines)

	vim.cmd([[15split]])

	vim.api.nvim_set_current_buf(buf)

	vim.cmd([[silent exe "normal gq%"]])

	vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })

	local body_file_type = utils.get_body_file_type(response.headers)
	local body_lines = body_to_lines(response, body_file_type)

	buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_set_option_value("filetype", body_file_type, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, body_lines)

	vim.cmd([[vsplit]])

	vim.api.nvim_set_current_buf(buf)

	vim.cmd([[silent exe "normal gq%"]])

	vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })
end

local function show_stderr(stderr)
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_set_option_value("filetype", "text", { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, stderr)

	vim.cmd([[15split]])

	vim.api.nvim_set_current_buf(buf)

	vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })
end

M.show = function(response, output)
	if response then
		show_response(response)
	else
		show_stderr(output)
	end
end

return M
