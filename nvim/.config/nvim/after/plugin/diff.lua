local diff_q_group = vim.api.nvim_create_augroup("DiffQClose", { clear = true })

local function close_all_diff_windows_in_current_tab()
	local tab = vim.api.nvim_get_current_tabpage()

	local wins = vim.api.nvim_tabpage_list_wins(tab)

	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) and vim.wo[win].diff then
			vim.schedule(function()
				vim.api.nvim_win_close(win, false)
			end)
		end
	end
end

local function setup_diff_q_maps()
	local bufname = vim.api.nvim_buf_get_name(0)

	if bufname:match("diffview://") then
		return
	end

	vim.keymap.set("n", "q", function()
		if not vim.wo.diff then
			return "q"
		end

		close_all_diff_windows_in_current_tab()
		return ""
	end, {
		buffer = 0,
		expr = true,
		silent = true,
		desc = "Close all diff windows in current tab",
	})
end

vim.api.nvim_create_autocmd("OptionSet", {
	group = diff_q_group,
	pattern = "diff",
	callback = setup_diff_q_maps,
})
