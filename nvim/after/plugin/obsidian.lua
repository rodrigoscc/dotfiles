vim.keymap.set(
	"n",
	"<leader>oo",
	vim.cmd.ObsidianQuickSwitch,
	{ desc = "[O]pen [o]bsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>no",
	vim.cmd.ObsidianNew,
	{ desc = "[N]ew [o]bsidian" }
)
vim.keymap.set(
	"n",
	"<leader>so",
	vim.cmd.ObsidianTags,
	{ desc = "[S]earch [O]bsidian tags" }
)
vim.keymap.set(
	"n",
	"<leader>sO",
	vim.cmd.ObsidianSearch,
	{ desc = "[S]earch [O]bsidian" }
)
