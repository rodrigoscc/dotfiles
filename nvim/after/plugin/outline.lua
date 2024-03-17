vim.keymap.set("n", "<leader>ty", vim.cmd.Outline, { desc = "Toggle Outline" })
vim.keymap.set(
	"n",
	"<leader>fy",
	vim.cmd.OutlineFocus,
	{ desc = "Focus Outline" }
)
