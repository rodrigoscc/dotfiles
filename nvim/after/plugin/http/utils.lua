local open = require("plenary.context_manager").open
local with = require("plenary.context_manager").with

local M = {}

local function create_file(filename, mode)
	local dir = vim.fs.dirname(filename)
	vim.fn.mkdir(dir, "p", "0o755")

	with(open(filename, "w+"), function(file)
		file:write("{}")
	end)
end

M.make_sure_file_exists = function(filename)
	local exists = vim.fn.findfile(filename) ~= ""
	if not exists then
		create_file(filename)
	end
end

M.format_if_jq_installed = function(json)
	if vim.fn.executable("jq") == 1 then
		return vim.fn.system(
			"jq --sort-keys --indent 4 '.' <<< '" .. json .. "'"
		)
	else
		return json
	end
end

return M
