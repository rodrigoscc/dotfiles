vim.keymap.set("i", "<C-f>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
	silent = true,
})
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
