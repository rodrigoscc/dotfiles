local lsp = require("lsp-zero").preset({ name = "recommended" })
local cmp = require("cmp")

require("neodev").setup({})

lsp.ensure_installed({
	"tsserver",
	"gopls",
	"pyright",
	"lua_ls",
})

local cmp_mappings = lsp.defaults.cmp_mappings()

cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil
cmp_mappings["<C-d>"] = nil
cmp_mappings["<C-b>"] = nil

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		-- { name = 'luasnip', keyword_length = 2 },
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
		telescope.lsp_references({ show_line = false }) -- need to see the full file name
	end, opts)
	vim.keymap.set("n", "gy", telescope.lsp_dynamic_workspace_symbols, opts)
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
		local active_clients = vim.lsp.get_active_clients()
		local is_null_ls_attached = false
		for _, client in pairs(active_clients) do
			if client.name == "null-ls" then
				is_null_ls_attached = true
			end
		end

		local filter_func = nil
		if is_null_ls_attached then
			filter_func = function(client)
				return client.name == "null-ls"
			end
		end

		vim.lsp.buf.format({ filter = filter_func })
	end, { desc = "[b]uffer [f]ormat" })

	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)
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

-- Using neodev instead.
-- lsp.nvim_workspace()

lsp.format_on_save({
	format_opts = {
		timeout_ms = 10000,
	},
	servers = {
		["null-ls"] = { "javascript", "typescript", "lua", "python", "go" },
	},
})

lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
})

local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.gofmt,
		null_ls.builtins.formatting.autoflake.with({
			extra_args = { "--remove-all-unused-imports" },
		}),
		null_ls.builtins.formatting.stylua.with({
			extra_args = { "--column-width=80" },
		}),
		null_ls.builtins.diagnostics.flake8.with({
			prefer_local = ".venv/bin",
			extra_args = {
				"--max-line-length=80",
				"--extend-ignore=E1,W1,E2,W2,E3,W3,E4,W4,E5,W5", -- no formatting rules, black handles it
			},
		}),
	},
})

require("mason-null-ls").setup({
	ensure_installed = {
		"black",
		"isort",
		"stylua",
		"prettier",
		"autoflake",
		"flake8",
	},
	automatic_installation = false,
	automatic_setup = true,
	handlers = {},
})
