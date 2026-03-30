vim.keymap.set(
	{ "o", "x" },
	"as",
	'<cmd>lua require("various-textobjs").subword("outer")<CR>'
)
vim.keymap.set(
	{ "o", "x" },
	"is",
	'<cmd>lua require("various-textobjs").subword("inner")<CR>'
)
