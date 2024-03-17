local oil = require("oil")
vim.keymap.set("n", "-", function()
	oil.open_float()
end, { desc = "oil" })
