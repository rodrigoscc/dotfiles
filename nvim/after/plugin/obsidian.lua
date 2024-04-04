vim.keymap.set(
	"n",
	"<leader>fo",
	":ObsidianQuickSwitch ", -- Purposely not pressing <CR> to allow entering an argument.
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
	"<leader>sO",
	vim.cmd.ObsidianTags,
	{ desc = "[s]earch [o]bsidian tags" }
)
vim.keymap.set(
	"n",
	"<leader>so",
	vim.cmd.ObsidianSearch,
	{ desc = "[s]earch [o]bsidian" }
)
