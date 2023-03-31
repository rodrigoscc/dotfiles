vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>gl", function()
	vim.cmd.Git("log")
end, { desc = "[g]it [l]og" })
vim.keymap.set("n", "<leader>gp", function()
	vim.cmd.Git("push")
end, { desc = "[g]it [p]ush" })

vim.cmd("autocmd User FugitiveEditor startinsert")
