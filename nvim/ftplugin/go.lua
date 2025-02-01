local move_cursor = require("custom.cursor").move_cursor

local function find_result_node(node)
	while node ~= nil and node:type() ~= "function_declaration" do
		node = node:parent()
	end

	if node ~= nil then
		local result_nodes = node:field("result")
		if next(result_nodes) ~= nil then
			return result_nodes[1]
		end
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

function my_comma()
	local cursor_node = vim.treesitter.get_node()
	if cursor_node == nil then
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

			line = before .. "(" .. between .. ")" .. after

			vim.api.nvim_set_current_line(line)

			move_cursor(1)
		end
	end
end

vim.on_key(function(key, typed)
	if vim.fn.mode() == "i" and vim.bo.filetype == "go" and key == "," then
		my_comma()
	end
end)
