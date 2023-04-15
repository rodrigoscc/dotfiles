vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>gl", function()
	vim.cmd.Git("log")
end, { desc = "[g]it [l]og" })
vim.keymap.set("n", "<leader>gp", function()
	vim.cmd.Git("push")
end, { desc = "[g]it [p]ush" })

vim.cmd("autocmd User FugitiveEditor startinsert")

local fugitiveGroup = vim.api.nvim_create_augroup("Fugitive", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "fugitive" },
	group = fugitiveGroup,
	callback = function()
		vim.keymap.set("n", "cc", function()
			vim.cmd.Git("commit --quiet")
		end, { buffer = true })
		vim.keymap.set("n", "ca", function()
			vim.cmd.Git("commit --quiet --amend")
		end, { buffer = true })
		vim.keymap.set("n", "ce", function()
			vim.cmd.Git("commit --quiet --amend --no-edit")
		end, { buffer = true })

		vim.keymap.set("n", "<C-s>", function()
			vim.cmd.write()
			vim.cmd.quit()
		end, { buffer = true })
	end,
})
