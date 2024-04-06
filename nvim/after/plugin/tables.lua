local ts_utils = require("nvim-treesitter.ts_utils")

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

local Row = {}

function Row:new(line)
	local cells = split_cells(line)
	cells = trim_cells(cells)

	local row = add_type(cells)

	setmetatable(row, self)
	self.__index = self

	return row
end

function Row:order(status_column_index, priority_column_index)
	local status = self.columns[status_column_index]
	local priority = self.columns[priority_column_index]

	return status_order[string.lower(status)]
		+ priority_order[string.lower(priority)]
end

local function parse_table_rows(table_lines)
	local rows = {}

	for _, row_string in pairs(table_lines) do
		table.insert(rows, Row:new(row_string))
	end

	return rows
end

local function align_cell(cell, width, row_type)
	if row_type == "divider" then
		return string.rep("-", width)
	else
		local padding = width - #cell
		return cell .. string.rep(" ", padding)
	end
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

function AreWritingTable()
	local current_line = vim.api.nvim_get_current_line()
	return vim.startswith(current_line, "|")
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

local function get_value_type(value)
	if vim.tbl_contains(status_values, value) then
		return STATUS_VALUE
	elseif vim.tbl_contains(priority_values, value) then
		return PRIORITY_VALUE
	else
		return nil
	end
end

local function index_of(tbl, value)
	for i, v in ipairs(tbl) do
		if v == value then
			return i
		end
	end

	return -1
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
		return false
	end

	local value_type = get_value_type(node_data.text)

	if value_type == nil then
		return false
	end

	return true
end

local function get_available_values(value_type)
	if value_type == STATUS_VALUE then
		return status_values
	elseif value_type == PRIORITY_VALUE then
		return priority_values
	end
end

local Table = {}

function Table:new(table_lines)
	local rows = parse_table_rows(table_lines)

	local table = {
		rows = rows,
	}

	setmetatable(table, self)
	self.__index = self

	return table
end

function Table:get_column_width(column_index)
	local max_width = 0
	for _, row in ipairs(self.rows) do
		if row.type ~= "divider" then
			local cell = row.columns[column_index]

			if #cell > max_width then
				max_width = #cell
			end
		end
	end
	return max_width
end

function Table:get_longest_columns_width()
	local column_widths = {}

	local columns_count = #self.rows[1].columns

	for i = 1, columns_count do
		table.insert(column_widths, self:get_column_width(i))
	end

	return column_widths
end

function Table:add_missing_columns(row, expected_columns)
	for _ = #row.columns + 1, expected_columns do
		table.insert(row.columns, "")
	end
end

function Table:get_highest_column_count()
	local highest_column_count = 0
	for _, row in pairs(self.rows) do
		if #row.columns > highest_column_count then
			highest_column_count = #row.columns
		end
	end
	return highest_column_count
end

function Table:normalize_column_count()
	local highest_column_count = self:get_highest_column_count()

	for _, row in pairs(self.rows) do
		self:add_missing_columns(row, highest_column_count)
	end
end

function Table:align_row(row, longest_column_widths)
	for i, cell in pairs(row.columns) do
		row.columns[i] = align_cell(cell, longest_column_widths[i], row.type)
	end
end

function Table:align_rows()
	local longest_column_widths = self:get_longest_columns_width()

	for _, row in pairs(self.rows) do
		self:align_row(row, longest_column_widths)
	end
end

function Table:find_value_column_index(value_type)
	-- Assuming header row is the first one.
	local header_row = self.rows[1]

	for i, cell in pairs(header_row.columns) do
		if string.lower(cell) == value_type then
			return i
		end
	end

	return nil
end

function Table:sort_rows_by_status_and_priority(
	status_column_index,
	priority_column_index
)
	local rows_to_sort = vim.list_slice(self.rows, 3, #self.rows)

	table.sort(rows_to_sort, function(row1, row2)
		return row1:order(status_column_index, priority_column_index)
			< row2:order(status_column_index, priority_column_index)
	end)

	local sorted_rows = vim.list_slice(self.rows, 1, 2)
	vim.list_extend(sorted_rows, rows_to_sort)

	self.rows = sorted_rows
end

function Table:sort()
	local status_column_index = self:find_value_column_index(STATUS_VALUE)
	if status_column_index == nil then
		return
	end

	local priority_column_index = self:find_value_column_index(PRIORITY_VALUE)
	if priority_column_index == nil then
		return
	end

	self:sort_rows_by_status_and_priority(
		status_column_index,
		priority_column_index
	)
end

function Table:to_lines()
	local lines = {}

	for _, row in pairs(self.rows) do
		local row_string = "| " .. table.concat(row.columns, " | ") .. " |"
		table.insert(lines, row_string)
	end

	return lines
end

function Table:write_in_line_range(start_line, end_line)
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, self:to_lines())
end

local Value = {}

function Value:new(text)
	local value_type = get_value_type(text)

	local available_values = get_available_values(value_type)

	local value = {
		type = value_type,
		value = text,

		available_values = available_values,
		index = index_of(available_values, text),
	}

	setmetatable(value, self)
	self.__index = self

	return value
end

function Value:next()
	self.index = get_next_index(self.available_values, self.index, 1)
	self.value = self.available_values[self.index]
end

function Value:previous()
	self.index = get_next_index(self.available_values, self.index, -1)
	self.value = self.available_values[self.index]
end

function Value:write_in_line_column_range(line_num, column_range)
	local line = vim.api.nvim_buf_get_lines(0, line_num, line_num + 1, false)[1]

	local new_line = line:sub(1, column_range[1] - 1)
		.. " "
		.. string.upper(self.value)
		.. " "
		.. line:sub(column_range[2] + 1)

	vim.api.nvim_buf_set_lines(0, line_num, line_num + 1, false, { new_line })
end

function AlignTable()
	local table_start, table_end = find_table_range()
	local table_lines =
		vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

	local my_table = Table:new(table_lines)
	my_table:normalize_column_count()
	my_table:align_rows()
	my_table:write_in_line_range(table_start, table_end)
end

function CycleValue()
	local ts_node_data = get_current_ts_node_data()

	if not validate_ts_node_for_cycling(ts_node_data) then
		return
	end

	local value = Value:new(ts_node_data.text)
	value:next()
	value:write_in_line_column_range(
		ts_node_data.line_num,
		ts_node_data.column_range
	)

	AlignTable()
end

function CycleValueReverse()
	local ts_node_data = get_current_ts_node_data()

	if not validate_ts_node_for_cycling(ts_node_data) then
		return
	end

	local value = Value:new(ts_node_data.text)
	value:previous()
	value:write_in_line_column_range(
		ts_node_data.line_num,
		ts_node_data.column_range
	)

	AlignTable()
end

function OrderByStatusAndPriority()
	local table_start, table_end = find_table_range()
	local table_lines =
		vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

	local my_table = Table:new(table_lines)
	my_table:sort()
	my_table:align_rows()
	my_table:write_in_line_range(table_start, table_end)
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
