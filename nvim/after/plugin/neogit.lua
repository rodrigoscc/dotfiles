local neogit = require("neogit")
vim.keymap.set("n", "<leader>gs", function()
	neogit.open({ kind = "replace" })
end, { desc = "[g]it [s]tatus" })

vim.keymap.set("n", "<leader>gm", function()
	neogit.open({ "commit" })
end, { desc = "[g]it co[m]mit" })

local neogitGroup = vim.api.nvim_create_augroup("Neogit", { clear = true })

-- Quickly save and quit gitcommit windows.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "NeogitCommitMessage" },
	group = neogitGroup,
	callback = function()
		vim.keymap.set("n", "<C-s>", function()
			vim.cmd.write()
			vim.cmd.close()
		end, { buffer = true })
	end,
})
