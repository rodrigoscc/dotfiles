vim.keymap.set("n", "<leader>ga", function()
	vim.cmd("Git add %")
end, { desc = "[G]it add" })
