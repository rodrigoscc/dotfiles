vim.keymap.set("n", "<localleader>d", function()
	require("osv").launch({ port = 8086 })
end, { noremap = true, buffer = 0 })

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "lua",
	callback = function()
		vim.keymap.set("n", "R", function()
			if vim.v.count == 0 then
				vim.cmd("Nurl .")
			else
				vim.api.nvim_input(":Nurl . url[" .. vim.v.count .. "]=")
			end
		end, { buffer = true })
	end,
})
