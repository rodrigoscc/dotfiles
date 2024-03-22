vim.keymap.set(
	"n",
	"<leader>of",
	vim.cmd.ObsidianQuickSwitch,
	{ desc = "[O]bsidian [f]ile" }
)
vim.keymap.set(
	"n",
	"<leader>ot",
	vim.cmd.ObsidianTags,
	{ desc = "[O]bsidian [t]ags" }
)
vim.keymap.set(
	"n",
	"<leader>os",
	vim.cmd.ObsidianSearch,
	{ desc = "[O]bsidian [s]earch" }
)
vim.keymap.set(
	"n",
	"<leader>on",
	vim.cmd.ObsidianNew,
	{ desc = "[O]bsidian [n]ew" }
)
