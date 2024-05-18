local api = require("dropbar.api")

vim.keymap.set(
	{ "n" },
	"<leader>tt",
	api.pick,
	{ noremap = true, silent = true }
)
