local function move_cursor(count)
	local current_win = vim.api.nvim_get_current_win()
	local original_cursor_line, original_cursor_column =
		unpack(vim.api.nvim_win_get_cursor(current_win))

	vim.api.nvim_win_set_cursor(
		current_win,
		{ original_cursor_line, original_cursor_column + count }
	)
end

return {
	move_cursor = move_cursor,
}
