local neogit = require("neogit")
vim.keymap.set("n", "<leader>gs", function()
	vim.cmd("Neogit kind=replace")
end, { desc = "[g]it [s]tatus" })

vim.keymap.set("n", "<leader>gc", function()
	vim.cmd("Neogit commit")
end, { desc = "[g]it [c]ommit" })

vim.keymap.set("n", "<leader>gp", function()
	vim.cmd("Neogit push")
end, { desc = "[g]it [p]ush" })

local neogitGroup = vim.api.nvim_create_augroup("Neogit", { clear = true })

-- Quickly save and quit gitcommit windows.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "NeogitCommitMessage", "gitcommit", "gitrebase" },
	group = neogitGroup,
	callback = function()
		vim.keymap.set("n", "<C-s>", function()
			vim.cmd.write()
			vim.cmd.quit()
		end, { buffer = true })
	end,
})
