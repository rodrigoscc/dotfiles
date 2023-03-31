local ts_utils = require("nvim-treesitter.ts_utils")
local npairs = require("nvim-autopairs")

local function trigger_autopairs()
	local bufnr = vim.api.nvim_get_current_buf()

	local autopairs_keys = npairs.autopairs_map(bufnr, "{")
	vim.api.nvim_feedkeys(autopairs_keys, "n", false)
end

local function prepend_f_if_needed()
	local bufnr = vim.api.nvim_get_current_buf()

	local cursor_node = ts_utils.get_node_at_cursor()
	local node_type = cursor_node:type()

	if node_type == "string_content" then
		cursor_node = cursor_node:parent()
		node_type = cursor_node:type()
	end

	local node_text = vim.treesitter.query.get_node_text(cursor_node, bufnr)

	local last_three_chars = string.sub(node_text, -3)
	local first_char = string.sub(node_text, 0, 1)
	local is_multi_line_str = last_three_chars == "'''" or last_three_chars == '"""'

	if not is_multi_line_str and (first_char == "'" or first_char == '"') then
		local _, column, _ = cursor_node:start()
		local current_line = vim.api.nvim_get_current_line()
		local new_line = current_line:sub(0, column) .. "f" .. current_line:sub(column + 1)
		vim.api.nvim_set_current_line(new_line)

		local current_win = vim.api.nvim_get_current_win()
		local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))
		vim.api.nvim_win_set_cursor(current_win, { row, col + 1 })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("i", "{", function()
			trigger_autopairs()
			prepend_f_if_needed()
		end, { buffer = true, remap = true })
	end,
})
