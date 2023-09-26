local gitsigns = require("gitsigns")

vim.keymap.set(
	"n",
	"<leader>ph",
	gitsigns.preview_hunk_inline,
	{ desc = "[p]review [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>pH",
	gitsigns.preview_hunk,
	{ desc = "[p]review [h]unk popup" }
)
vim.keymap.set(
	{ "n", "v" },
	"<leader>sh",
	"<cmd>Gitsigns stage_hunk<cr>",
	{ desc = "[s]tage [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>rh",
	gitsigns.reset_hunk,
	{ desc = "[r]eset [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>bl",
	gitsigns.blame_line,
	{ desc = "[b]lame [l]ine" }
)

vim.keymap.set("n", "]h", function()
	vim.g.set_jump(gitsigns.next_hunk, gitsigns.prev_hunk)
	gitsigns.next_hunk()
end, { desc = "next hunk" })

vim.keymap.set("n", "[h", function()
	vim.g.set_jump(gitsigns.next_hunk, gitsigns.prev_hunk)
	gitsigns.prev_hunk()
end, { desc = "previous hunk" })

vim.keymap.set("n", "<leader>H", function()
	gitsigns.setqflist("all")
end, { desc = "show all [H]unks" })
