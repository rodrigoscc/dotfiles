vim.keymap.set(
	"n",
	"<leader>of",
	":ObsidianQuickSwitch ", -- Purposely not pressing <CR> to allow entering an argument.
	{ desc = "[f]ind [o]bsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>on",
	vim.cmd.ObsidianNew,
	{ desc = "[n]ew [o]bsidian" }
)

vim.keymap.set("n", "<leader>o#", function()
	vim.cmd("ObsidianTags")
end, { desc = "[o]bsidian [t]ags" })

vim.keymap.set("n", "<leader>.", function()
	vim.cmd.ObsidianTags("projects")
end, { desc = "[s]earch obsidian projects" })

vim.keymap.set(
	"n",
	"<leader>os",
	vim.cmd.ObsidianSearch,
	{ desc = "[o]bsidian [s]earch" }
)

vim.keymap.set(
	"n",
	"<leader>ot",
	vim.cmd.ObsidianToday,
	{ desc = "[o]bsidian [t]oday" }
)
vim.keymap.set(
	"n",
	"<leader>oy",
	vim.cmd.ObsidianYesterday,
	{ desc = "[o]bsidian [y]esterday" }
)
