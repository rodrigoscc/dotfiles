local function new_todo()
	vim.cmd.Obsidian("today")

	vim.schedule(function()
		vim.cmd.normal("G")
		vim.opt.autoindent = false
		vim.cmd.normal("o")
		vim.opt.autoindent = true
		require("checkmate").create()
	end)
end

vim.keymap.set(
	"n",
	"<leader><space>",
	new_todo,
	{ desc = "[o]bsidian new [t]odo" }
)
vim.keymap.set("n", "<leader>[", new_todo, { desc = "[o]bsidian new [t]odo" })
