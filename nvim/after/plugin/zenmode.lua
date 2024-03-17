vim.keymap.set("n", "<leader>z", function()
	vim.cmd.Twilight()
	vim.cmd.ZenMode()
end, { desc = "[z]en mode" })
