local ts_utils = require("nvim-treesitter.ts_utils")
local function split_cells(line)
	local between_cells = vim.split(line, "|")

	if
		#between_cells == 2
		and between_cells[1] == ""
		and between_cells[2] == ""
	then
		return { "" }
	elseif between_cells[#between_cells] ~= "" then
		table.insert(between_cells, "")
	end

	return vim.list_slice(between_cells, 2, #between_cells - 1)
end

local function trim_cells(cells)
	local trimmed_cells = {}
	for _, cell in ipairs(cells) do
		table.insert(trimmed_cells, vim.trim(cell))
	end
	return trimmed_cells
end

local function add_type(row)
	local first_cell = row[1]

	if vim.startswith(first_cell, "-") then
		return { type = "divider", columns = row }
	else
		return { type = "regular", columns = row }
	end
end

local function parse_table_rows(table_lines)
	local rows = {}

	for _, row_string in pairs(table_lines) do
		local cells = split_cells(row_string)
		cells = trim_cells(cells)
		table.insert(rows, add_type(cells))
	end

	return rows
end

local function get_highest_column_count(rows)
	local highest_column_count = 0
	for _, row in pairs(rows) do
		if #row.columns > highest_column_count then
			highest_column_count = #row.columns
		end
	end
	return highest_column_count
end

local function add_missing_columns(row, expected_columns)
	for _ = #row.columns + 1, expected_columns do
		table.insert(row.columns, "")
	end
end

local function normalize_column_count(rows)
	local highest_column_count = get_highest_column_count(rows)

	for _, row in pairs(rows) do
		add_missing_columns(row, highest_column_count)
	end
end

local function get_column_width(md_table, column_index)
	local max_width = 0
	for _, row in ipairs(md_table) do
		if row.type ~= "divider" then
			local cell = row.columns[column_index]

			if #cell > max_width then
				max_width = #cell
			end
		end
	end
	return max_width
end

local function get_longest_columns_width(rows)
	local column_widths = {}

	local columns_count = #rows[1].columns

	for i = 1, columns_count do
		table.insert(column_widths, get_column_width(rows, i))
	end

	return column_widths
end

local function align_cell(cell, width, row_type)
	if row_type == "divider" then
		return string.rep("-", width)
	else
		local padding = width - #cell
		return cell .. string.rep(" ", padding)
	end
end

local function align_row(row, longest_column_widths)
	for i, cell in pairs(row.columns) do
		row.columns[i] = align_cell(cell, longest_column_widths[i], row.type)
	end
end

local function align_rows(rows)
	local longest_column_widths = get_longest_columns_width(rows)

	for _, row in pairs(rows) do
		align_row(row, longest_column_widths)
	end
end

local function table_to_lines(rows)
	local lines = {}

	for _, row in pairs(rows) do
		local row_string = "| " .. table.concat(row.columns, " | ") .. " |"
		table.insert(lines, row_string)
	end

	return lines
end

local function find_table_start(current_line_number)
	local table_start = current_line_number

	local current_line =
		vim.api.nvim_buf_get_lines(0, table_start - 1, table_start, false)

	while #current_line > 0 and vim.startswith(current_line[1], "|") do
		table_start = table_start - 1

		current_line =
			vim.api.nvim_buf_get_lines(0, table_start - 1, table_start, false)
	end

	return table_start
end

local function find_table_end(current_line_number)
	local table_end = current_line_number

	local current_line =
		vim.api.nvim_buf_get_lines(0, table_end, table_end + 1, false)

	while #current_line > 0 and vim.startswith(current_line[1], "|") do
		table_end = table_end + 1

		current_line =
			vim.api.nvim_buf_get_lines(0, table_end, table_end + 1, false)
	end

	return table_end
end

local function find_table_range()
	-- Should not use treesitter here since this plugin is mostly used when the
	-- table is not properly formatted yet.
	local current_line_number = vim.fn.line(".")

	local table_start = find_table_start(current_line_number)
	local table_end = find_table_end(current_line_number)

	return table_start, table_end
end

local function read_surrounding_table()
	local table_start, table_end = find_table_range()

	local table_lines =
		vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

	local table_rows = parse_table_rows(table_lines)

	return {
		rows = table_rows,
		line_range = { table_start, table_end },
	}
end

local status_values = { "in progress", "todo", "done" }

local status_order = {
	["in progress"] = 10,
	["todo"] = 20,
	["done"] = 30,
}

local STATUS_VALUE = "status"
local PRIORITY_VALUE = "priority"

local priority_values = { "high", "medium", "low" }

local priority_order = {
	high = 1,
	medium = 2,
	low = 3,
}

local function find_value_column_index(rows, value_type)
	-- Assuming header row is the first one.
	local header_row = rows[1]

	for i, cell in pairs(header_row.columns) do
		if string.lower(cell) == value_type then
			return i
		end
	end

	return nil
end

local function row_order(row, status_column_index, priority_column_index)
	local status = row.columns[status_column_index]
	local priority = row.columns[priority_column_index]

	return status_order[string.lower(status)]
		+ priority_order[string.lower(priority)]
end

local function sort_rows_by_status(
	table_obj,
	status_column_index,
	priority_column_index
)
	local rows_to_sort = vim.list_slice(table_obj.rows, 3, #table_obj.rows)

	table.sort(rows_to_sort, function(row1, row2)
		return row_order(row1, status_column_index, priority_column_index)
			< row_order(row2, status_column_index, priority_column_index)
	end)

	local sorted_rows = vim.list_slice(table_obj.rows, 1, 2)
	vim.list_extend(sorted_rows, rows_to_sort)

	table_obj.rows = sorted_rows
end

local function write_table(surrounding_table)
	vim.api.nvim_buf_set_lines(
		0,
		surrounding_table.line_range[1],
		surrounding_table.line_range[2],
		false,
		table_to_lines(surrounding_table.rows)
	)
end

function AlignTable()
	local table_obj = read_surrounding_table()
	normalize_column_count(table_obj.rows)
	align_rows(table_obj.rows)
	write_table(table_obj)
end

function AreWritingTable()
	local current_line = vim.api.nvim_get_current_line()
	return vim.startswith(current_line, "|")
end

function OrderByStatusAndPriority()
	local table_obj = read_surrounding_table()

	local status_column_index =
		find_value_column_index(table_obj.rows, STATUS_VALUE)
	if status_column_index == nil then
		return
	end

	local priority_column_index =
		find_value_column_index(table_obj.rows, PRIORITY_VALUE)
	if priority_column_index == nil then
		return
	end

	sort_rows_by_status(table_obj, status_column_index, priority_column_index)
	align_rows(table_obj.rows)
	write_table(table_obj)
end

local function next_index_forward(values, current_index, step)
	local reverse_index = (#values + step) - current_index
	local next_reverse_index = (reverse_index % #values) + step

	return (#values + step) - next_reverse_index
end

local function next_index_backward(values, current_index, step)
	local next_index = (current_index % #values) + step
	return next_index
end

local function get_next_index(values, current_index, direction)
	if direction > 0 then
		return next_index_forward(values, current_index, math.abs(direction))
	else
		return next_index_backward(values, current_index, math.abs(direction))
	end
end

local function find_next_value_in(values, current_value)
	for i, value in pairs(values) do
		if value == current_value then
			local next_index = get_next_index(values, i, 1)
			return values[next_index]
		end
	end

	return current_value
end

local function find_previous_value_in(values, current_value)
	for i, value in pairs(values) do
		if value == current_value then
			local previous_index = get_next_index(values, i, -1)
			return values[previous_index]
		end
	end

	return current_value
end

local function get_value_type(value)
	if vim.tbl_contains(status_values, value) then
		return STATUS_VALUE
	elseif vim.tbl_contains(priority_values, value) then
		return PRIORITY_VALUE
	else
		return nil
	end
end

local function get_current_ts_node_data()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here")

	local start_row, start_column, _, end_column = node:range()

	local line =
		vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]

	local text = vim.treesitter.get_node_text(node, 0)
	text = vim.trim(string.lower(text))

	return {
		text = text,
		node_type = node:type(),
		line_num = start_row,
		line = line,
		column_range = { start_column, end_column },
	}
end

local function validate_ts_node_for_cycling(node_data)
	if node_data.node_type ~= "pipe_table_cell" then
		return nil
	end

	local value_type = get_value_type(node_data.text)

	if value_type == nil then
		return nil
	end

	return {
		type = value_type,
		value = node_data.text,
		line_num = node_data.line_num,
		line = node_data.line,
		column_range = node_data.column_range,
	}
end

local function get_current_value_obj()
	local ts_node_data = get_current_ts_node_data()
	return validate_ts_node_for_cycling(ts_node_data)
end

local function update_line(value_obj, new_value)
	local new_line = value_obj.line:sub(1, value_obj.column_range[1] - 1)
		.. " "
		.. string.upper(new_value)
		.. " "
		.. value_obj.line:sub(value_obj.column_range[2] + 1)

	vim.api.nvim_buf_set_lines(
		0,
		value_obj.line_num,
		value_obj.line_num + 1,
		false,
		{ new_line }
	)
end

local function get_available_values(value_obj)
	if value_obj.type == STATUS_VALUE then
		return status_values
	elseif value_obj.type == PRIORITY_VALUE then
		return priority_values
	end
end

local function find_next_value(value_obj)
	local available_values = get_available_values(value_obj)
	return find_next_value_in(available_values, value_obj.value)
end

local function find_previous_value(value_obj)
	local available_values = get_available_values(value_obj)
	return find_previous_value_in(available_values, value_obj.value)
end

function CycleValue()
	local value_obj = get_current_value_obj()
	if value_obj == nil then
		return
	end

	local new_value = find_next_value(value_obj)

	update_line(value_obj, new_value)

	AlignTable()
end

function CycleValueReverse()
	local value_obj = get_current_value_obj()
	if value_obj == nil then
		return
	end

	local new_value = find_previous_value(value_obj)

	update_line(value_obj, new_value)

	AlignTable()
end

local function find_next_cell(node)
	while node ~= nil do
		if
			node:type() == "pipe_table_header"
			or node:type() == "pipe_table_row"
		then
			return node:named_child(0)
		elseif node:type() == "pipe_table_delimiter_row" then
			node = node:named_child(0)
		elseif node:type() == "pipe_table_cell" then
			return node
		elseif not vim.startswith(node:type(), "pipe_") then
			return nil
		else
			node = ts_utils.get_next_node(node, true, false)
		end
	end

	return nil
end

function AppendRow()
	vim.cmd("normal! o| |")
	AlignTable()
end

local function find_next_cell_after_current_node()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here")

	if node:type() == "pipe_table_cell" then
		node = ts_utils.get_next_node(node, true, false)
	end

	return find_next_cell(node)
end

function GotoNextCell()
	local next_cell_node = find_next_cell_after_current_node()

	if next_cell_node == nil then
		AppendRow()
	else
		ts_utils.goto_node(next_cell_node, false, true)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.keymap.set("i", "<tab>", function()
			if AreWritingTable() then
				AlignTable()

				vim.schedule(function()
					GotoNextCell()
				end)
			end
		end, { buffer = true })

		vim.keymap.set("n", "L", function()
			if AreWritingTable() then
				CycleValue()
			end
		end, { buffer = true })
		vim.keymap.set("n", "H", function()
			if AreWritingTable() then
				CycleValueReverse()
			end
		end, { buffer = true })

		vim.keymap.set("n", "<leader>st", function()
			if AreWritingTable() then
				OrderByStatusAndPriority()
			end
		end, { buffer = true, desc = "[s]ort [t]table" })
	end,
})
