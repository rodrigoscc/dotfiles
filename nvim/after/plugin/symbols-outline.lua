vim.keymap.set("n", "<leader>ty", function()
	vim.cmd.SymbolsOutline()
end, { desc = "[t]oggle s[y]mbols outline" })
