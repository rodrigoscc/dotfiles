local lazy = require("lazy")

local ts_utils = require("nvim-treesitter.ts_utils")
local autopairs = require("ultimate-autopair.core")
local cmp = require("cmp")

vim.keymap.set("n", "<leader>L", lazy.show, { desc = "show [l]azy" })

vim.keymap.set("x", "J", ":move '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":move '<-2<CR>gv=gv")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<cmd>normal! <C-d>zz<CR>")
vim.keymap.set("n", "<C-u>", "<cmd>normal! <C-u>zz<CR>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-s>", "<cmd>silent write<cr>")

vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
end, { desc = "[t]oggle [w]rap" })

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

-- Super Esc key.
vim.keymap.set("n", "<Esc>", function()
	vim.schedule(function()
		vim.cmd([[nohlsearch]])
		vim.cmd([[echon '']]) -- Clear command line
		vim.cmd.NoiceDismiss()
		vim.cmd([[pclose]])
	end)
	return "<Esc>"
end, { expr = true })

vim.keymap.set("n", "Q", "gq")

vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-l>", "<cmd>cnfile<CR>")
vim.keymap.set("n", "<C-h>", "<cmd>cpfile<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")

vim.keymap.set(
	"n",
	"<leader>w",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
)
vim.keymap.set(
	"v",
	"<leader>w",
	[[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "]<space>", "mzo<esc>`z")
vim.keymap.set("n", "[<space>", "mzO<esc>`z")

vim.keymap.set("n", "<leader>sf", function()
	vim.cmd("so")

	local current_buffer = vim.fn.expand("%")
	local sourced_packer = string.find(current_buffer, "packer.lua")
	if sourced_packer then
		vim.cmd.PackerClean()
		vim.cmd.PackerInstall()
		vim.cmd.PackerCompile()
	end
end, { desc = "[s]ource [f]ile" })

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

vim.keymap.set("n", "md", "<cmd>diffthis<cr>")
vim.keymap.set("n", "mD", "<cmd>diffoff!<cr>")

vim.keymap.set(
	"n",
	"<leader>m",
	"<C-w>T",
	{ desc = "[m]aximize window to tab" }
)

vim.keymap.set("n", "<bs>", "<C-^>", { desc = "switch to last buffer" })

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

	-- Ignore triple quote strings since they already support new lines.
	if
		node_type == "string"
		and last_three_chars ~= '"""'
		and last_three_chars ~= "'''"
	then
		local input = quote .. "<CR>" .. quote
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(input, true, false, true),
			"n",
			false
		)
	else
		vim.api.nvim_feedkeys(autopairs.run_run("\r"), "n", false)
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
	local current_win = vim.api.nvim_get_current_win()
	local _, original_cursor_column =
		unpack(vim.api.nvim_win_get_cursor(current_win))

	local expression = ","

	local cursor_node = ts_utils.get_node_at_cursor()
	if cursor_node == nil then
		return expression
	end

	local result_node = find_result_node(cursor_node)
	if result_node == nil then
		-- Try node to the left since cursor might be right after the result
		-- node to insert a comma.
		local previous_node = get_left_node()
		result_node = find_result_node(previous_node)
	end

	if result_node ~= nil then
		local bufnr = vim.api.nvim_get_current_buf()
		local result_node_text =
			vim.treesitter.get_node_text(result_node, bufnr)

		local need_parentheses = result_node_text:sub(1, 1) ~= "("

		if need_parentheses then
			local _, start_column, _ = result_node:start()
			local _, end_column, _ = result_node:end_()

			-- TODO: This is not repeatable with dot command.
			expression = expression
				.. string.rep(
					"<Left>",
					original_cursor_column - start_column + 1
				)
				.. "("
				.. string.rep("<Right>", end_column - start_column + 1)
				.. ")"
				.. string.rep("<Left>", end_column - original_cursor_column + 1)
		end
	end

	return expression
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("i", "<c-m>", function()
			my_cr()
		end, { buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.keymap.set("i", ",", my_comma, { buffer = true, expr = true })
	end,
})

vim.keymap.set("n", "<leader>tc", function()
	vim.cmd.IBLToggle()
	vim.o.list = not vim.o.list
end, { desc = "[t]oggle list [c]hars" })

local go_tests_query = vim.treesitter.query.parse(
	"go",
	[[
[
 (function_declaration
   name: (identifier) @function_name
   (#lua-match? @function_name "^Test.*"))
 (
  (method_declaration
    receiver: (parameter_list (parameter_declaration type: (pointer_type (type_identifier) @suite_name)))
    name: (field_identifier) @method_name
    (#lua-match? @method_name "^Test.*"))
  (function_declaration name: (identifier) @suite_function body: (block (expression_statement (call_expression function: (selector_expression) @suite_run (#eq? @suite_run "suite.Run") arguments: (argument_list (call_expression function: (identifier) @call (#eq? @call "new") arguments: (argument_list (type_identifier) @suite_name_2 (#eq? @suite_name @suite_name_2))))))))
  )
]
]]
)

local go_package_query = vim.treesitter.query.parse(
	"go",
	[[
	(package_clause (package_identifier) @package_name)
	]]
)

local function debug_testify(test, suite, package)
	if package == "main" then
		package = ""
	end

	require("dap").run({
		type = "go",
		name = "test",
		request = "launch",
		mode = "test",
		program = "./" .. package,
		args = {
			"-test.run",
			suite .. "/" .. test,
		},
	})
end

local function debug(test, package)
	require("dap").run({
		type = "go",
		name = "test",
		request = "launch",
		mode = "test",
		program = "./" .. package,
		args = {
			"-test.run",
			test,
		},
	})
end

function DebugGoTest()
	local parser = vim.treesitter.get_parser(0, "go")
	local tree = parser:parse()[1]

	local _, package_node, _ = go_package_query:iter_captures(tree:root(), 0)()
	local package = vim.treesitter.get_node_text(package_node, 0)

	local all_tests = {}

	for _, match in go_tests_query:iter_matches(tree:root(), 0) do
		local test = {}

		for id, node in pairs(match) do
			local capture_name = go_tests_query.captures[id]
			local capture_value = vim.treesitter.get_node_text(node, 0)

			if capture_name == "function_name" then
				test["name"] = capture_value
				test["type"] = "default"
			elseif capture_name == "method_name" then
				test["name"] = capture_value
				test["type"] = "testify"
			else
				test[capture_name] = capture_value
			end
		end

		table.insert(all_tests, test)
	end

	vim.ui.select(all_tests, {
		prompt = "Debug a test",
		format_item = function(test)
			if test.type == "testify" then
				return test.name .. " (" .. test.suite_function .. ")"
			end
			return test.name
		end,
	}, function(test)
		if test == nil then
			return
		end

		if test.type == "default" then
			debug(test.name, package)
		else
			debug_testify(test.name, test.suite_function, package)
		end
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.keymap.set(
			"n",
			"<localleader>d",
			DebugGoTest,
			{ buffer = true, desc = "go: [d]ebug" }
		)
	end,
})

local function init_prettier()
	local prettier_config = {
		semi = true,
		tabWidth = 4,
		singleQuote = false,
		trailingComma = "all",
	}

	local prettier_config_str = vim.fn.json_encode(prettier_config)

	vim.fn.writefile({ prettier_config_str }, ".prettierrc.json")
end

vim.api.nvim_create_user_command("InitPrettier", init_prettier, {})

vim.keymap.set(
	"x",
	"<leader>fj",
	":!jq --indent 4<cr>",
	{ desc = "[f]ormat [j]son" }
)
vim.keymap.set(
	"n",
	"<leader>fj",
	":'{+1,'}-1!jq --indent 4<cr>",
	{ desc = "[f]ormat [j]son" }
)

vim.keymap.set(
	"n",
	"<C-w>]",
	"<cmd>normal! <C-w>v<C-]>zt<cr>",
	{ desc = "go to tag in vertical split" }
)
