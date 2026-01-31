local navic = require("nvim-navic")

local mason_ensure_installed = {
	"ruff",
	"prettier",
	"stylua",
	"goimports",
	"fixjson",
	"sql-formatter",
	"beautysh",
	"selene",
	"golangci-lint",
	"codespell",
	"commitlint",
	"buf",
	"taplo",
}

-- Ensure installed for formatters and diagnostics
vim.api.nvim_create_user_command("MasonInstallAll", function()
	vim.cmd("MasonInstall " .. table.concat(mason_ensure_installed, " "))
end, {})

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function(event)
		local bufnr = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		assert(client, "LSP client not found")

		if client.server_capabilities.documentSymbolProvider then
			navic.attach(client, event.buf)
		end

		-- if
		-- 	client.supports_method("textDocument/codeLens")
		-- 	and client.name ~= "lua_ls"
		-- then
		-- 	vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
		-- 		buffer = bufnr,
		-- 		callback = vim.lsp.codelens.refresh,
		-- 	})
		-- end

		local opts = { buffer = bufnr, remap = false }

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "grr", function()
			Snacks.picker.lsp_references()
		end, opts)
		vim.keymap.set("n", "gy", Snacks.picker.lsp_workspace_symbols, opts)
		vim.keymap.set("n", "gY", Snacks.picker.lsp_symbols, opts)

		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			{ desc = "[c]ode [a]ction" }
		)

		vim.keymap.set("n", "]d", function()
			vim.g.set_jump(function()
				vim.diagnostic.jump({ count = 1 })
			end, function()
				vim.diagnostic.jump({ count = -1 })
			end)
			vim.diagnostic.jump({ count = 1 })
		end, opts)

		vim.keymap.set("n", "[d", function()
			vim.g.set_jump(function()
				vim.diagnostic.jump({ count = 1 })
			end, function()
				vim.diagnostic.jump({ count = -1 })
			end)
			vim.diagnostic.jump({ count = -1 })
		end, opts)

		vim.keymap.set("n", "]e", function()
			vim.g.set_jump(function()
				vim.diagnostic.jump({
					count = 1,
					severity = vim.diagnostic.severity.ERROR,
				})
			end, function()
				vim.diagnostic.jump({
					count = -1,
					severity = vim.diagnostic.severity.ERROR,
				})
			end)
			vim.diagnostic.jump({
				count = 1,
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)

		vim.keymap.set("n", "[e", function()
			vim.g.set_jump(function()
				vim.diagnostic.jump({
					count = 1,
					severity = vim.diagnostic.severity.ERROR,
				})
			end, function()
				vim.diagnostic.jump({
					count = -1,
					severity = vim.diagnostic.severity.ERROR,
				})
			end)
			vim.diagnostic.jump({
				count = -1,
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)
	end,
})

local function toggle_format_on_save()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
end

vim.keymap.set("n", "<leader>tf", function()
	toggle_format_on_save()
	vim.cmd.redrawstatus()
end, { desc = "[t]oggle [f]ormat on save" })

vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("LspRestart")
	vim.print("LSP Restarted!")
end, { desc = "[r]estart [l]sp" })

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
	},
	signs = false,
	severity_sort = true,
	float = {
		source = true,
		border = "rounded",
	},
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	once = true,
	callback = function()
		-- Extend neovim's client capabilities with the completion ones.
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
		})

		local servers = vim.iter(
			vim.api.nvim_get_runtime_file("lsp/*.lua", true)
		)
			:map(function(file)
				return vim.fn.fnamemodify(file, ":t:r")
			end)
			:totable()
		vim.lsp.enable(servers)
	end,
})
