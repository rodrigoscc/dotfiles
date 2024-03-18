local lsp = require("lsp-zero").preset({ name = "recommended" })
local cmp = require("cmp")

lsp.ensure_installed({
	"tsserver",
	"gopls",
	"pyright",
	"lua_ls",
	"bashls",
})

local mason_ensure_installed = {
	"isort",
	"black",
	"autoflake",
	"flake8",
	"prettier",
	"stylua",
	"goimports",
	"fixjson",
	"sql-formatter",
	"beautysh",
}

-- Ensure installed for formatters and diagnostics
vim.api.nvim_create_user_command("MasonInstallAll", function()
	vim.cmd("MasonInstall " .. table.concat(mason_ensure_installed, " "))
end, {})

local cmp_mappings = lsp.defaults.cmp_mappings()

cmp_mappings["<S-Tab>"] = nil
cmp_mappings["<C-d>"] = nil
cmp_mappings["<C-b>"] = nil
cmp_mappings["<C-Space>"] = cmp.mapping.complete()
cmp_mappings["<CR>"] = cmp.mapping.confirm({
	behavior = cmp.ConfirmBehavior.Insert,
	select = true,
})
cmp_mappings["<Tab>"] = cmp.mapping.confirm({
	behavior = cmp.ConfirmBehavior.Replace,
	select = true,
})
cmp_mappings["<C-y>"] = nil
cmp_mappings["<C-f>"] = nil
cmp_mappings["<C-d>"] = nil
cmp_mappings["<C-h>"] = cmp.mapping.scroll_docs(5)
cmp_mappings["<C-y>"] = cmp.mapping.scroll_docs(-5)

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
		{ name = "orgmode" },
	},
	window = {
		completion = {
			winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
			col_offset = -3,
			side_padding = 0,
		},
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			local kind = require("lspkind").cmp_format({
				mode = "symbol_text",
				maxwidth = 50,
			})(entry, vim_item)
			local strings = vim.split(kind.kind, "%s", { trimempty = true })
			kind.kind = " " .. (strings[1] or "") .. " "
			kind.menu = "    (" .. (strings[2] or "") .. ")"

			return kind
		end,
	},
})

lsp.set_preferences({
	suggest_lsp_servers = false,
})

local telescope = require("telescope.builtin")

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", function()
		telescope.lsp_references({
			show_line = false,
			include_declaration = false,
		}) -- need to see the full file name
	end, opts)
	vim.keymap.set("n", "gy", function()
		telescope.lsp_dynamic_workspace_symbols({
			ignore_symbols = "variable",
		})
	end, opts)
	vim.keymap.set("n", "gY", telescope.lsp_document_symbols, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set(
		"n",
		"<leader>rn",
		vim.lsp.buf.rename,
		{ desc = "[r]e[n]ame" }
	)
	vim.keymap.set(
		"n",
		"<leader>od",
		vim.diagnostic.open_float,
		{ desc = "[o]pen [d]iagnostics float" }
	)
	vim.keymap.set(
		{ "n", "v" },
		"<leader>ca",
		vim.lsp.buf.code_action,
		{ desc = "[c]ode [a]ction" }
	)
	vim.keymap.set({ "n", "v" }, "<leader>bf", function()
		require("conform").format({ bufnr = bufnr })
	end, { desc = "[b]uffer [f]ormat" })

	vim.keymap.set("n", "]d", function()
		vim.g.set_jump(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
		vim.diagnostic.goto_next()
	end, opts)

	vim.keymap.set("n", "[d", function()
		vim.g.set_jump(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
		vim.diagnostic.goto_prev()
	end, opts)
end)

lsp.configure("pyright", {
	root_dir = function()
		return vim.fn.getcwd()
	end,
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
})

local function toggle_format_on_save()
	if vim.g.disable_autoformat then
		vim.g.disable_autoformat = false
	else
		vim.g.disable_autoformat = true
	end
end

vim.keymap.set("n", "<leader>tf", function()
	toggle_format_on_save()
end, { desc = "[t]oggle [f]ormat on save" })

lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
	signs = false,
	severity_sort = true,
})
