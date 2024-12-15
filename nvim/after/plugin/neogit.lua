local git_group = vim.api.nvim_create_augroup("git", { clear = true })

-- Quickly save and quit gitcommit windows.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "NeogitCommitMessage", "gitcommit", "gitrebase" },
	group = git_group,
	callback = function()
		vim.cmd.startinsert()
		vim.keymap.set("n", "<C-s>", function()
			vim.cmd.write()
			vim.cmd.quit()
		end, { buffer = true })
	end,
})
