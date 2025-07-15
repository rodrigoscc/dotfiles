local lazy = require("lazy")

vim.keymap.set("n", "<leader>L", lazy.show, { desc = "show [l]azy" })
vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "show [m]ason" })

vim.keymap.set("x", "J", ":move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("x", "K", ":move '<-2<CR>gv=gv", { silent = true })

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<space><space>y", [[mzgg"+yG`z]], { desc = "copy buffer" })
vim.keymap.set("n", "<space><space>c", [[ggVGc]], { desc = "change buffer" })

local function send_buffer_to_tmux(pane)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local text = vim.fn.join(lines, "\n")
	vim.system({ "tmux", "send-keys", "-t", pane, "-l", text .. "\n" })
end

vim.keymap.set("n", "<space><space>r", function()
	send_buffer_to_tmux(":.+")
end, { desc = "send buffer to tmux" })

vim.keymap.set("n", "<C-s>", "<cmd>silent write<cr>")

-- Default <C-w>t is useless to me, <C-w>T is more useful
vim.keymap.set("n", "<C-w>t", "<C-w>T")

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

-- Yup, these are actually useful
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

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

vim.keymap.set("n", "<leader>ts", "<cmd>TSJToggle<cr>")

vim.keymap.set("n", "md", "<cmd>diffthis<cr>")
vim.keymap.set("n", "mD", "<cmd>diffoff!<cr>")

vim.keymap.set(
	"n",
	"<leader>m",
	"<cmd>tab split<cr>",
	{ desc = "[m]aximize window to tab" }
)

vim.keymap.set("n", "<bs>", "<C-^>", { desc = "switch to last buffer" })

vim.keymap.set("n", "<leader>tc", function()
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

return { counter = counter }
