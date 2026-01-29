vim.keymap.set("n", "<localleader>d", function()
	require("osv").launch({ port = 8086 })
end, { noremap = true, buffer = 0 })
