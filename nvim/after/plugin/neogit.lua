vim.keymap.set(
	"n",
	"<leader>gs",
	"<cmd>Neogit kind=replace<cr>",
	{ desc = "[g]it [s]tatus" }
)

vim.keymap.set(
	"n",
	"<leader>gc",
	"<cmd>Neogit commit<cr>",
	{ desc = "[g]it [c]ommit" }
)

vim.keymap.set(
	"n",
	"<leader>gp",
	"<cmd>Neogit push<cr>",
	{ desc = "[g]it [p]ush" }
)

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
