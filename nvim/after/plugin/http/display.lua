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

return M
