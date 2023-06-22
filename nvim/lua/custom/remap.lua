local ts_utils = require("nvim-treesitter.ts_utils")
local npairs = require("nvim-autopairs")
local cmp = require("cmp")

vim.g.mapleader = " "
-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<cmd>normal! <C-d>zz<CR>")
vim.keymap.set("n", "<C-u>", "<cmd>normal! <C-u>zz<CR>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-s>", "<cmd>silent write<cr>")

vim.g.format_on_save = true
vim.keymap.set("n", "<leader>tw", function()
	if vim.g.format_on_save then
		vim.g.format_on_save = false
		vim.keymap.set("n", "<C-s>", "<cmd>silent noautocmd write<cr>")
	else
		vim.g.format_on_save = true
		vim.keymap.set("n", "<C-s>", "<cmd>silent write<cr>")
	end
end, { desc = "[t]oggle [w]rite" })

-- Paste preserving previous copy
vim.keymap.set(
	{ "n", "v" },
	"<leader>sp",
	[["_dP]],
	{ desc = "[s]pecial [p]aste" }
)
-- Delete preserving previous copy
vim.keymap.set(
	{ "n", "v" },
	"<leader>sd",
	[["_d]],
	{ desc = "[s]pecial [d]elete" }
)

vim.keymap.set(
	{ "n", "v" },
	"<leader>y",
	[["+y]],
	{ desc = "[y]ank to system clipboard" }
)
vim.keymap.set(
	"n",
	"<leader>Y",
	[["+Y]],
	{ desc = "[y]ank to system clipboard" }
)

vim.keymap.set(
	"n",
	"<leader>bf",
	vim.lsp.buf.format,
	{ desc = "[b]uffer [f]ormat" }
)

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')

vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-l>", "<cmd>cnfile<CR>")
vim.keymap.set("n", "<C-h>", "<cmd>cpfile<CR>")
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
	if cursor_node == nil then
		return
	end

	local node_type = cursor_node:type()

	if node_type == "string_content" then
		cursor_node = cursor_node:parent()
		node_type = cursor_node:type()
	end

	local node_text = vim.treesitter.get_node_text(cursor_node, bufnr)
	local quote = string.sub(node_text, -1)
	local last_three_chars = string.sub(node_text, -3)

	if cmp.visible() then
		cmp.confirm({ select = false })
		return "<Ignore>"
	end

	-- Ignore triple quote strings since they already support new lines.
	if
		node_type == "string"
		and last_three_chars ~= '"""'
		and last_three_chars ~= "'''"
	then
		return quote .. "<CR>" .. quote
	else
		local input = npairs.autopairs_cr()
		local keys = vim.api.nvim_replace_termcodes(input, true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)

		return "<Ignore>"
	end
end

local function find_result_node(node)
	local parent = node:parent()

	while parent ~= nil do
		local parent_result_nodes = parent:field("result")
		if
			next(parent_result_nodes) ~= nil
			and parent_result_nodes[1]:equal(node)
		then
			return parent_result_nodes[1]
		end

		node = parent
		parent = node:parent()
	end

	return nil
end

local function get_left_node()
	local current_win = vim.api.nvim_get_current_win()
	local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))

	local bufnr = vim.api.nvim_get_current_buf()
	return vim.treesitter.get_node({ bufnr = bufnr, pos = { row - 1, col - 1 } })
end

local function my_comma()
	local current_line = vim.api.nvim_get_current_line()
	local current_win = vim.api.nvim_get_current_win()
	local row, col = unpack(vim.api.nvim_win_get_cursor(current_win))

	local cursor_node = ts_utils.get_node_at_cursor()
	if cursor_node == nil then
		return
	end

	local new_line = current_line

	local result_node = find_result_node(cursor_node)
	if result_node == nil then
		-- Try node to the left since cursor might be right after the result
		-- node to insert a comma.
		local previous_node = get_left_node()

		result_node = find_result_node(previous_node)
		if result_node == nil then
			new_line = current_line:sub(0, col)
				.. ","
				.. current_line:sub(col + 1)

			-- Update cursor after adding the comma
			col = col + 1
		end
	end

	if result_node ~= nil then
		local bufnr = vim.api.nvim_get_current_buf()
		local result_node_text =
			vim.treesitter.get_node_text(result_node, bufnr)

		local need_parentheses = result_node_text:sub(1, 1) ~= "("

		if need_parentheses then
			local _, start_column, _ = result_node:start()
			local _, end_column, _ = result_node:end_()
			new_line = current_line:sub(0, start_column)
				.. "("
				.. current_line:sub(start_column + 1, end_column)
				.. ")"
				.. current_line:sub(end_column + 1)

			-- Update cursor after adding the parenthesis
			col = col + 1

			new_line = new_line:sub(0, col) .. "," .. new_line:sub(col + 1)

			-- Update cursor after adding the comma
			col = col + 1
		end
	end

	vim.api.nvim_set_current_line(new_line)
	vim.api.nvim_win_set_cursor(current_win, { row, col })
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("i", "<c-m>", my_cr, { buffer = true, expr = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.keymap.set("i", ",", my_comma, { buffer = true })
	end,
})

vim.keymap.set("n", "<leader>tc", function()
	vim.cmd.IndentBlanklineToggle()
	vim.o.list = not vim.o.list
end, { desc = "[t]oggle list [c]hars" })
