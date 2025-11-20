local function trigger_cr()
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<CR>", true, false, true),
		"n",
		false
	)
end

local function break_string()
	local bufnr = vim.api.nvim_get_current_buf()

	local cursor_node = vim.treesitter.get_node()
	if cursor_node == nil then
		return
	end

	local node_type = cursor_node:type()

	if not string.find(node_type, "string") then
		trigger_cr()
		return
	end

	if node_type ~= "string" then
		cursor_node = cursor_node:parent()
		if cursor_node == nil then
			return
		end

		node_type = cursor_node:type()
	end

	local node_text = vim.treesitter.get_node_text(cursor_node, bufnr)
	local quote = string.sub(node_text, -1)
	local last_three_chars = string.sub(node_text, -3)

	-- Ignore triple quote strings since they already support new lines.
	if
		node_type == "string"
		and last_three_chars ~= '"""'
		and last_three_chars ~= "'''"
	then
		local input = quote .. "<CR>" .. quote
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(input, true, false, true),
			"n",
			false
		)
	else
		trigger_cr()
	end
end

local function prepend_f_to_f_string()
	local bufnr = vim.api.nvim_get_current_buf()

	local cursor_node = vim.treesitter.get_node()
	if cursor_node == nil then
		return
	end

	local node_type = cursor_node:type()

	if not string.find(node_type, "string") then
		return
	end

	if node_type ~= "string" then
		cursor_node = cursor_node:parent()
		node_type = cursor_node:type()
	end

	local current_win = vim.api.nvim_get_current_win()
	local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))
	local node_row, node_col, _ = cursor_node:start()
	local cursor_is_right_before_the_string = row == node_row + 1
		and col == node_col
	if cursor_is_right_before_the_string then
		return
	end

	local node_text = vim.treesitter.get_node_text(cursor_node, bufnr)

	local last_three_chars = string.sub(node_text, -3)
	local first_char = string.sub(node_text, 0, 1)
	local is_multi_line_str = last_three_chars == "'''"
		or last_three_chars == '"""'

	if not is_multi_line_str and (first_char == "'" or first_char == '"') then
		local _, column, _ = cursor_node:start()
		local current_line = vim.api.nvim_get_current_line()
		local new_line = current_line:sub(0, column)
			.. "f"
			.. current_line:sub(column + 1)
		vim.api.nvim_set_current_line(new_line)

		local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))
		vim.api.nvim_win_set_cursor(current_win, { row, col + 1 })
	end
end

vim.keymap.set("i", "<c-m>", break_string, { buffer = true })

vim.on_key(function(key, typed)
	if vim.fn.mode() == "i" and vim.bo.filetype == "python" then
		if key == "{" then
			prepend_f_to_f_string()
		end
	end
end)
