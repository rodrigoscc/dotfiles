local gitsigns = require("gitsigns")

vim.keymap.set(
	"n",
	"<leader>ph",
	gitsigns.preview_hunk_inline,
	{ desc = "preview hunk" }
)
vim.keymap.set(
	"n",
	"<leader>pH",
	gitsigns.preview_hunk,
	{ desc = "preview hunk popup" }
)
vim.keymap.set(
	{ "n" },
	"<leader>sh",
	"<cmd>Gitsigns stage_hunk<cr>",
	{ desc = "stage hunk" }
)
vim.keymap.set({ "v" }, "<leader>sh", function()
	gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "stage hunk" })
vim.keymap.set("n", "<leader>rh", gitsigns.reset_hunk, { desc = "reset hunk" })
vim.keymap.set({ "v" }, "<leader>rh", function()
	gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "reset hunk" })
vim.keymap.set("n", "<leader>bl", gitsigns.blame_line, { desc = "blame line" })

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
end, { desc = "show all hunks" })
