local oil = require("oil")
vim.keymap.set("n", "-", function()
	oil.open()
end, { desc = "oil" })
