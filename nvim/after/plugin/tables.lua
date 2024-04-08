local log = require("plenary.log").new({ plugin = "tables" })
log.level = "debug"

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

local Enum = {}

function Enum:new(values, value_order, current_value, order_priority)
	current_value = string.lower(vim.trim(current_value))

	local index = -1

	for i, value in ipairs(values) do
		if string.lower(value) == current_value then
			index = i
			break
		end
	end

	if index == -1 then
		error(
			string.format(
				"Current value %s not found in available values %s.",
				current_value,
				vim.inspect(values)
			)
		)
	end

	local enum = {
		current_value = current_value,
		available_values = values,
		value_order = value_order,
		index = index,
		order_priority = order_priority or 0,
	}

	setmetatable(enum, self)
	self.__index = self

	return enum
end

function Enum:next()
	self.index = self.index + 1

	if self.index > #self.available_values then
		self.index = 1
	end

	self.current_value = self.available_values[self.index]
end

function Enum:previous()
	self.index = self.index - 1

	if self.index < 1 then
		self.index = #self.available_values
	end

	self.current_value = self.available_values[self.index]
end

function Enum:order()
	local order_priority_scaler = 10 ^ self.order_priority
	return self.value_order[self.current_value] * order_priority_scaler
end

local Cell = {}

function Cell:new(my_table, pos_x, pos_y, text)
	local cell = {
		x = pos_x,
		y = pos_y,
		text = vim.trim(text),
		next = nil,
		previous = nil,

		table = my_table,
	}

	setmetatable(cell, self)
	self.__index = self

	log.fmt_debug("Created cell: (%i, %i) -> %s", cell.x, cell.y, cell.text)

	return cell
end

function Cell:fill(row, column)
	if row.type == "divider" then
		self.text = string.rep("-", column.min_width)
	else
		local righ_padding = column.min_width - #self.text
		self.text = self.text .. string.rep(" ", righ_padding)
	end
end

function Cell:column()
	return self.table.columns[self.y]
end

function Cell:row()
	return self.table.rows[self.x]
end

function Cell:next_regular_cell()
	local next_cell = self.next

	while next_cell ~= nil do
		local row = next_cell:row()
		if row.type == "regular" or row.type == "header" then
			log.fmt_debug(
				"Next regular cell: (%i, %i) -> %s",
				next_cell.x,
				next_cell.y,
				next_cell.text
			)
			return next_cell
		end

		next_cell = next_cell.next
	end

	log.fmt_debug("No next regular cell")
	return nil
end

function Cell:range()
	return self:row():find_cell_range(self.y)
end

function Cell:select()
	local column_start, column_end = self:range()

	local text_start = column_start + 2
	local text_end = column_end - 2

	local line_number = self.table.line_start + self.x

	if vim.fn.mode() == "i" then
		text_start = text_start + 1
		text_end = text_end + 1
	end

	vim.api.nvim_win_set_cursor(0, { line_number, text_start })

	local keys = vim.api.nvim_replace_termcodes(
		"<Esc>v" .. text_end - text_start .. "l<C-g>",
		true,
		false,
		true
	)
	vim.api.nvim_feedkeys(keys, "n", true)
end

function Cell:get_enum()
	local column = self:column()

	if string.lower(column.header) == "status" then
		return Enum:new(
			{ "todo", "in progress", "done" },
			{ todo = 2, ["in progress"] = 3, done = 1 },
			self.text,
			2
		)
	elseif string.lower(column.header) == "priority" then
		return Enum:new(
			{ "low", "medium", "high" },
			{ low = 1, medium = 2, high = 3 },
			self.text,
			1
		)
	end

	return nil
end

function Cell:next_enum_value()
	local enum = self:get_enum()

	if enum == nil then
		return nil
	end

	enum:next()

	self.text = string.upper(enum.current_value)
	self:write()
end

function Cell:previous_enum_value()
	local enum = self:get_enum()

	if enum == nil then
		return nil
	end

	enum:previous()

	self.text = string.upper(enum.current_value)
	self:write()
end

function Cell:write()
	local cell_start, cell_end = self:range()

	local line_number = self.table.line_start + self.x - 1

	vim.api.nvim_buf_set_text(
		0,
		line_number,
		cell_start + 2,
		line_number,
		cell_end,
		{ self.text }
	)
end

local function infer_row_type(index, row_cells)
	if index == 1 then
		-- Assume first row is header for now.
		return "header"
	elseif #row_cells > 0 then
		local first_cell = row_cells[1]
		if vim.startswith(first_cell.text, "-") then
			return "divider"
		end
	end

	return "regular"
end

local Row = {}

function Row:new(index, raw_line, row_cells)
	local type = infer_row_type(index, row_cells)

	local row = {
		type = type,
		cells = row_cells,
		index = index,

		raw = raw_line,
	}

	setmetatable(row, self)
	self.__index = self

	log.fmt_debug(
		"Created row: type=%s index=%i -> %s",
		row.type,
		row.index,
		row.raw
	)

	return row
end

function Row:get_pipe_indexes()
	local pipes_indexes = {}

	local pipe_index = string.find(self.raw, "|", 0)
	while pipe_index ~= nil do
		table.insert(pipes_indexes, pipe_index)
		pipe_index = string.find(self.raw, "|", pipe_index + 1)
	end

	return pipes_indexes
end

function Row:find_cell_containing(pos_y)
	local pipes_indexes = self:get_pipe_indexes()

	for i = 1, #pipes_indexes - 1 do
		local start = pipes_indexes[i]
		local stop = pipes_indexes[i + 1]

		if start - 1 <= pos_y and pos_y < stop - 1 then
			return self.cells[i]
		end
	end

	return nil
end

function Row:find_cell_range(cell_index)
	local pipes_indexes = self:get_pipe_indexes()
	return pipes_indexes[cell_index] - 1, pipes_indexes[cell_index + 1] - 1
end

function Row:order()
	local order_priority = 0

	for _, cell in ipairs(self.cells) do
		local enum = cell:get_enum()
		if enum ~= nil then
			local enum_order = enum:order()
			log.fmt_debug("Enum order: %i %s", enum_order, enum.current_value)
			order_priority = order_priority + enum:order()
		end
	end

	return order_priority
end

local Column = {}

local function get_column_min_width(column_index, rows)
	local min_width = 3

	local row_number = #rows
	for i = 1, row_number do
		local cell = rows[i].cells[column_index]

		local row = cell:row()
		if row.type ~= "divider" then
			local cell_content = vim.trim(cell.text)

			if #cell_content > min_width then
				min_width = #cell_content
			end
		end
	end

	return min_width
end

function Column:new(index, rows)
	local header_cell = rows[1].cells[index]

	local column = {
		header = header_cell.text,
		index = index,
		min_width = get_column_min_width(index, rows),
	}

	setmetatable(column, self)
	self.__index = self

	log.fmt_debug(
		"Created column: header=%s index=%i min_width=%i",
		column.header,
		column.index,
		column.min_width
	)

	return column
end

local function close_cell_values(cell_values)
	table.insert(cell_values, "")
end

local function parse_line(my_table, row_index, line)
	local cell_values = vim.split(line, "|")

	local at_least_contains_two_pipes = #cell_values > 2

	local is_table_closed = at_least_contains_two_pipes
		and vim.trim(cell_values[#cell_values]) == ""

	if #cell_values == 1 then
		error("Invalid table line.")
	elseif not is_table_closed then
		close_cell_values(cell_values)
	end

	cell_values = vim.list_slice(cell_values, 2, #cell_values - 1)

	local cells = {}

	for column_index, cell_text in ipairs(cell_values) do
		table.insert(
			cells,
			Cell:new(my_table, row_index, column_index, cell_text)
		)
	end

	for index, cell in ipairs(cells) do
		local previous_cell = cells[index - 1]
		local next_cell = cells[index + 1]

		cell.next = next_cell
		cell.previous = previous_cell
	end

	return cells
end

local function parse_cells(my_table, table_lines)
	local cells = {}

	for line_index, line in ipairs(table_lines) do
		log.fmt_debug("Parsing line: %s", line)
		local row_cells = parse_line(my_table, line_index, line)

		if #cells > 0 then
			local first_row_cell = row_cells[1]

			local last_row = cells[#cells]
			local last_cell = last_row[#last_row]

			last_cell.next = first_row_cell
			first_row_cell.previous = last_cell
		end

		table.insert(cells, row_cells)
	end

	return cells
end

local function normalize_cells(my_table, cells)
	local max_columns = 0

	for _, row_cells in ipairs(cells) do
		if #row_cells > max_columns then
			max_columns = #row_cells
		end
	end

	for row_index, row_cells in ipairs(cells) do
		while #row_cells < max_columns do
			local last_cell = row_cells[#row_cells]

			local new_cell = Cell:new(my_table, row_index, #row_cells + 1, "")
			table.insert(row_cells, new_cell)

			new_cell.next = last_cell.next
			last_cell.next = new_cell
			new_cell.previous = last_cell
		end
	end

	return cells
end

local function parse_rows(cells, table_lines)
	local rows = {}

	for row_index, row in ipairs(cells) do
		table.insert(rows, Row:new(row_index, table_lines[row_index], row))
	end

	return rows
end

local function parse_columns(rows)
	local columns = {}

	local first_row = rows[1]

	for column_index in ipairs(first_row.cells) do
		table.insert(columns, Column:new(column_index, rows))
	end

	return columns
end

local Table = {}

function Table:new(table_lines, table_start, table_end)
	log.fmt_debug(
		"Creating table: %i %i %s",
		table_start,
		table_end,
		vim.inspect(table_lines)
	)

	if #table_lines == 0 then
		return nil
	end

	local my_table = {
		line_start = table_start,
		line_end = table_end,

		rows = nil,
		columns = nil,
	}

	local cells = parse_cells(my_table, table_lines)
	cells = normalize_cells(my_table, cells)

	my_table.rows = parse_rows(cells, table_lines)
	my_table.columns = parse_columns(my_table.rows)

	setmetatable(my_table, self)
	self.__index = self

	return my_table
end

function Table:iterator()
	if #self.rows == 0 or #self.rows.cells == 0 then
		return nil
	end

	return self.rows[1].cells[1]
end

function Table:update_column_widths()
	for _, column in ipairs(self.columns) do
		column.min_width = get_column_min_width(column.index, self.rows)
	end
end

function Table:align()
	for row_index, row in ipairs(self.rows) do
		for column_index, cell in ipairs(row.cells) do
			cell:fill(self.rows[row_index], self.columns[column_index])
		end
	end
end

function Table:to_lines()
	local lines = {}

	for _, row in ipairs(self.rows) do
		local texts = {}
		for _, cell in ipairs(row.cells) do
			table.insert(texts, cell.text)
		end

		local line = vim.fn.join(texts, " | ")
		line = "| " .. line .. " |"

		table.insert(lines, line)
	end

	return lines
end

function Table:get_cell_under_cursor()
	local cursor_x, cursor_y = unpack(vim.api.nvim_win_get_cursor(0))

	local row_index = cursor_x - self.line_start

	return self.rows[row_index]:find_cell_containing(cursor_y)
end

function Table:last_cell()
	local last_row = self.rows[#self.rows]
	return last_row.cells[#last_row.cells]
end

function Table:append_row()
	local last_cell = self:last_cell()

	local new_cells = {}

	for column_index, column in ipairs(self.columns) do
		table.insert(
			new_cells,
			Cell:new(
				self,
				#self.rows + 1,
				column_index,
				string.rep(" ", column.min_width)
			)
		)
	end

	local new_row = Row:new(#self.rows + 1, "", new_cells)

	table.insert(self.rows, new_row)

	last_cell.next = new_cells[1]
	new_cells[1].previous = last_cell
end

function Table:sort()
	local content_rows = vim.list_slice(self.rows, 3, #self.rows)

	table.sort(content_rows, function(a, b)
		return a:order() > b:order()
	end)

	self.rows = vim.list_slice(self.rows, 1, 2)
	for _, row in ipairs(content_rows) do
		table.insert(self.rows, row)
	end
end

function Table:write()
	local lines = self:to_lines()

	for i, row in ipairs(self.rows) do
		row.raw = lines[i]
	end

	vim.api.nvim_buf_set_lines(0, self.line_start, self.line_end, true, lines)
end

local function default_action(raw_keys)
	local keys = vim.api.nvim_replace_termcodes(raw_keys, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", true)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.keymap.set({ "n", "s", "i" }, "<tab>", function()
			local table_start, table_end = find_table_range()
			local table_lines =
				vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

			if #table_lines == 0 then
				default_action("<tab>")
				return
			end

			local my_table = Table:new(table_lines, table_start, table_end)

			assert(my_table ~= nil, "Table must exist")

			my_table:align()
			my_table:write()

			local cell = my_table:get_cell_under_cursor()

			if cell ~= nil then
				log.fmt_debug(
					"Cursor cell: (%i, %i) -> %s",
					cell.x,
					cell.y,
					cell.text
				)
				local next_cell = cell:next_regular_cell()

				if next_cell == nil then
					my_table:append_row()
					my_table:align()
					my_table:write()

					next_cell = cell:next_regular_cell()
				end

				next_cell:select()
			else
				log.fmt_debug("No cell under cursor")
			end
		end, { buffer = true })

		vim.keymap.set({ "n" }, "L", function()
			local table_start, table_end = find_table_range()
			local table_lines =
				vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

			if #table_lines == 0 then
				default_action("L")
				return
			end

			local my_table = Table:new(table_lines, table_start, table_end)

			assert(my_table ~= nil, "Table must exist")

			local cell = my_table:get_cell_under_cursor()

			if cell ~= nil then
				cell:next_enum_value()
				my_table:update_column_widths()

				my_table:align()
				my_table:write()
			end
		end)

		vim.keymap.set({ "n" }, "H", function()
			local table_start, table_end = find_table_range()
			local table_lines =
				vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

			if #table_lines == 0 then
				default_action("H")
				return
			end

			local my_table = Table:new(table_lines, table_start, table_end)

			assert(my_table ~= nil, "Table must exist")

			local cell = my_table:get_cell_under_cursor()

			if cell ~= nil then
				cell:previous_enum_value()
				my_table:update_column_widths()

				my_table:align()
				my_table:write()
			end
		end)

		vim.keymap.set({ "n" }, "<leader>st", function()
			local table_start, table_end = find_table_range()
			local table_lines =
				vim.api.nvim_buf_get_lines(0, table_start, table_end, true)

			if #table_lines == 0 then
				return
			end

			local my_table = Table:new(table_lines, table_start, table_end)

			assert(my_table ~= nil, "Table must exist")

			my_table:sort()
			my_table:align()
			my_table:write()
		end)
	end,
})
