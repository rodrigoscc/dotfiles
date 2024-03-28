vim.keymap.set(
	"n",
	"<leader>fo",
	vim.cmd.ObsidianQuickSwitch,
	{ desc = "[f]ind [o]bsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>no",
	vim.cmd.ObsidianNew,
	{ desc = "[n]ew [o]bsidian" }
)
vim.keymap.set(
	"n",
	"<leader>so",
	vim.cmd.ObsidianTags,
	{ desc = "[s]earch [o]bsidian tags" }
)
vim.keymap.set(
	"n",
	"<leader>sO",
	vim.cmd.ObsidianSearch,
	{ desc = "[s]earch [o]bsidian" }
)
