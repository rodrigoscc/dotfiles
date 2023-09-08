local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "mm", mark.add_file, { desc = "harpoon [m]ark" })

vim.keymap.set("n", "<M-m>", function()
	ui.nav_file(1)
end, { desc = "harpoon window 1" })
vim.keymap.set("n", "<M-,>", function()
	ui.nav_file(2)
end, { desc = "harpoon window 2" })
vim.keymap.set("n", "<M-.>", function()
	ui.nav_file(3)
end, { desc = "harpoon window 3" })
vim.keymap.set("n", "<M-/>", function()
	ui.nav_file(4)
end, { desc = "harpoon window 4" })

vim.keymap.set(
	"n",
	"<leader>m",
	ui.toggle_quick_menu,
	{ desc = "harpoon quick [m]enu" }
)
