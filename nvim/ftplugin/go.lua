local move_cursor = require("custom.cursor").move_cursor

local function find_result_node(node)
	local parent = node:parent()

	while parent ~= nil do
		local parent_result_nodes = parent:field("result")
		if
			next(parent_result_nodes) ~= nil
			and parent_result_nodes[1]:equal(node)
		then
			return parent_result_nodes[1]
		end

		node = parent
		parent = node:parent()
	end

	return nil
end

local function get_left_node()
	local current_win = vim.api.nvim_get_current_win()
	local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))

	local bufnr = vim.api.nvim_get_current_buf()
	return vim.treesitter.get_node({
		bufnr = bufnr,
		pos = { math.max(row - 1, 0), math.max(col - 1, 0) },
	})
end

local function regular_comma()
	vim.api.nvim_put({ "," }, "c", false, true)
end

function my_comma()
	local cursor_node = vim.treesitter.get_node()
	if cursor_node == nil then
		regular_comma()
		return
	end

	local result_node = find_result_node(cursor_node)
	if result_node == nil then
		-- Try node to the left since cursor might be right after the result
		-- node to insert a comma.
		local previous_node = get_left_node()
		result_node = find_result_node(previous_node)
	end

	if result_node ~= nil then
		local bufnr = vim.api.nvim_get_current_buf()
		local result_node_text =
			vim.treesitter.get_node_text(result_node, bufnr)

		local need_parentheses = result_node_text:sub(1, 1) ~= "("

		if need_parentheses then
			local _, start_column, _ = result_node:start()
			local _, end_column, _ = result_node:end_()

			local line = vim.api.nvim_get_current_line()

			local before = line:sub(1, start_column)
			local after = line:sub(end_column + 1)
			local between = line:sub(start_column + 1, end_column)

			local current_win = vim.api.nvim_get_current_win()
			local _, original_cursor_column =
				unpack(vim.api.nvim_win_get_cursor(current_win))

			local comma_position = original_cursor_column

			if comma_position > start_column - 1 then
				comma_position = comma_position + 1
			elseif comma_position >= end_column + 1 then
				comma_position = comma_position + 2
			end

			line = before .. "(" .. between .. ")" .. after
			line = line:sub(1, comma_position)
				.. ","
				.. line:sub(comma_position + 1)

			vim.api.nvim_set_current_line(line)

			move_cursor(2)
		end
	else
		regular_comma()
	end
end

vim.keymap.set("i", ",", my_comma, { buffer = true })
