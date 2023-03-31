local ts_utils = require("nvim-treesitter.ts_utils")
local wk = require("which-key")
local npairs = require("nvim-autopairs")

vim.g.mapleader = " "
-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-s>", "<cmd>write<cr>")

-- Paste preserving previous copy
vim.keymap.set({ "n", "v" }, "<leader>sp", [["_dP]], { desc = "[s]pecial [p]aste" })
-- Delete preserving previous copy
vim.keymap.set({ "n", "v" }, "<leader>sd", [["_d]], { desc = "[s]pecial [d]elete" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[y]ank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "[y]ank to system clipboard" })

vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, { desc = "[b]uffer [f]ormat" })

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')

vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")

-- vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })
--
-- vim.keymap.set('n', '<leader>vpp', '<cmd>e ~/.config/nvim/lua/custom/packer.lua<CR>');

vim.keymap.set("n", "]<space>", "mzo<esc>`z")
vim.keymap.set("n", "[<space>", "mzO<esc>`z")

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")

	local current_buffer = vim.fn.expand("%")
	local sourced_packer = string.find(current_buffer, "packer.lua")
	if sourced_packer then
		vim.cmd.PackerClean()
		vim.cmd.PackerInstall()
		vim.cmd.PackerCompile()
	end
end)

vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<M-k>", "<cmd>NavigatorUp<cr>")
vim.keymap.set("n", "<M-j>", "<cmd>NavigatorDown<cr>")
vim.keymap.set("n", "<M-h>", "<cmd>NavigatorLeft<cr>")
vim.keymap.set("n", "<M-l>", "<cmd>NavigatorRight<cr>")

vim.keymap.set("n", "<M-L>", "<cmd>vsplit<cr><c-w>l") -- open split and go to it
vim.keymap.set("n", "<M-J>", "<cmd>split<cr><c-w>j") -- open split and go to it
vim.keymap.set("n", "<M-H>", "<cmd>vsplit<cr>") -- open split and don't go to it
vim.keymap.set("n", "<M-K>", "<cmd>split<cr>") -- open split and don't go to it

vim.keymap.set("n", "<M-q>", "<cmd>close<cr>")

vim.keymap.set("n", "<leader>ts", "<cmd>TSJToggle<cr>")

--- Custom behaviour for a carriage return.
-- Splits a string in two lines in a fancy way.
local function my_cr()
	local bufnr = vim.api.nvim_get_current_buf()

	local cursor_node = ts_utils.get_node_at_cursor()
	local node_type = cursor_node:type()

	if node_type == "string_content" then
		cursor_node = cursor_node:parent()
		node_type = cursor_node:type()
	end

	local node_text = vim.treesitter.query.get_node_text(cursor_node, bufnr)
	local quote = string.sub(node_text, -1)
	local last_three_chars = string.sub(node_text, -3)

	-- Ignore triple quote strings since they already support new lines.
	if node_type == "string" and last_three_chars ~= '"""' and last_three_chars ~= "'''" then
		vim.cmd('execute "normal! i\\' .. quote .. "\\<cr>\\" .. quote .. '\\<esc>l"')
	else
		local input = npairs.autopairs_cr()
		local keys = vim.api.nvim_replace_termcodes(input, true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("i", "<c-m>", my_cr, { buffer = true })
	end,
})
