local id = vim.api.nvim_create_augroup("CursorWordGroup", {
	clear = false,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
	group = id,
	pattern = "dropbar_menu",
	callback = function()
		vim.b.minicursorword_disable = true
	end,
})
