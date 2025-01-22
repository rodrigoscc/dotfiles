local api = require("dropbar.api")

vim.keymap.set(
	{ "n" },
	"<leader>dp",
	api.pick,
	{ noremap = true, silent = true }
)
