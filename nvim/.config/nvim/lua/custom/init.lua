vim.g.mapleader = " "
vim.g.maplocalleader = "  "

require("custom.lazy")
require("custom.set")
require("custom.remap")
require("custom.autocmds")
require("custom.user-commands")

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group =
	vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})
