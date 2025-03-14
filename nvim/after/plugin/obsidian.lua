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

vim.keymap.set("n", "<leader>#", function()
	vim.cmd("ObsidianTags")
end, { desc = "[s]earch obsidian [t]ags" })

vim.keymap.set("n", "<leader>.", function()
	vim.cmd.ObsidianTags("projects")
end, { desc = "[s]earch obsidian projects" })
vim.keymap.set(
	"n",
	"<leader>,",
	vim.cmd.ObsidianSearch,
	{ desc = "[s]earch [o]bsidian" }
)

vim.keymap.set(
	"n",
	"<leader>tt",
	vim.cmd.ObsidianToday,
	{ desc = "obsidian today" }
)
vim.keymap.set(
	"n",
	"<leader>tT",
	vim.cmd.ObsidianYesterday,
	{ desc = "obsidian yesterday" }
)
