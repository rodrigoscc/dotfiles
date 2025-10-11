vim.keymap.set(
	"n",
	"<leader>of",
	":Obsidian quick_switch ", -- Purposely not pressing <CR> to allow entering an argument.
	{ desc = "[f]ind [o]bsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>on",
	"<cmd>Obsidian new<cr>",
	{ desc = "[n]ew [o]bsidian" }
)

vim.keymap.set(
	"n",
	"<leader>o#",
	"<cmd>Obsidian tags<cr>",
	{ desc = "[o]bsidian [t]ags" }
)

vim.keymap.set(
	"n",
	"<leader>.",
	"<cmd>Obsidian tags projects<cr>",
	{ desc = "[s]earch obsidian projects" }
)

vim.keymap.set(
	"n",
	"<leader>os",
	"<cmd>Obsidian search<cr>",
	{ desc = "[o]bsidian [s]earch" }
)

vim.keymap.set(
	"n",
	"<leader>oo",
	"<cmd>Obsidian today<cr>",
	{ desc = "[o]bsidian today" }
)
vim.keymap.set(
	"n",
	"<leader>oy",
	"<cmd>Obsidian yesterday<cr>",
	{ desc = "[o]bsidian [y]esterday" }
)

vim.keymap.set("n", "<leader>ot", function()
	Snacks.picker.grep({
		cwd = "~/obsidian-vault/",
		live = false,
		search = "- \\[ \\]",
		title = "Obsidian TODOs",
	})
end, { desc = "[o]bsidian [t]odos" })
