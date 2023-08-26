vim.g.set_jump = function(forward, backward)
	vim.keymap.set("n", "]]", forward, { desc = "jump forward" })
	vim.keymap.set("n", "[[", backward, { desc = "jump backward" })
end

vim.keymap.set("n", "]]", function()
	vim.print("no previous jump command used")
end, { desc = "jump forward" })
vim.keymap.set("n", "[[", function()
	vim.print("no previous jump command used")
end, { desc = "jump backward" })
