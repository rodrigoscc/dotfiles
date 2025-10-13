vim.keymap.set("n", "<leader>oT", function()
	vim.cmd.Obsidian("today")

	vim.schedule(function()
		vim.cmd.normal("G")
		vim.opt.autoindent = false
		vim.cmd.normal("o")
		vim.opt.autoindent = true
		require("checkmate").create()
	end)
end, { desc = "[o]bsidian new [t]odo" })
