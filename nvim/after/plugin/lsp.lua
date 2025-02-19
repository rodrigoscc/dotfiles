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

		-- Fix for svelte language server to update after ts or js files are updated
		-- https://github.com/sveltejs/language-tools/issues/2008#issuecomment-2090014756
		if client.name == "svelte" then
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.js", "*.ts" },
				callback = function(ctx)
					client.notify(
						"$/onDidChangeTsOrJsFile",
						{ uri = ctx.match }
					)
				end,
			})
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
		vim.keymap.set("n", "gr", function()
			Snacks.picker.lsp_references()
		end, opts)
		vim.keymap.set("n", "gy", Snacks.picker.lsp_workspace_symbols, opts)
		vim.keymap.set("n", "gY", Snacks.picker.lsp_symbols, opts)

		vim.keymap.set(
			"n",
			"<leader>rn",
			vim.lsp.buf.rename,
			{ desc = "[r]e[n]ame" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			{ desc = "[c]ode [a]ction" }
		)
		vim.keymap.set({ "n", "v" }, "<leader>fb", function()
			require("conform").format({ bufnr = bufnr })
		end, { desc = "[f]ormat [b]uffer" })

		vim.keymap.set("n", "]d", function()
			vim.g.set_jump(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
			vim.diagnostic.goto_next()
		end, opts)

		vim.keymap.set("n", "[d", function()
			vim.g.set_jump(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
			vim.diagnostic.goto_prev()
		end, opts)

		vim.keymap.set("n", "]e", function()
			vim.g.set_jump(function()
				vim.diagnostic.goto_next({
					severity = vim.diagnostic.severity.ERROR,
				})
			end, function()
				vim.diagnostic.goto_prev({
					severity = vim.diagnostic.severity.ERROR,
				})
			end)
			vim.diagnostic.goto_next({
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)

		vim.keymap.set("n", "[e", function()
			vim.g.set_jump(function()
				vim.diagnostic.goto_next({
					severity = vim.diagnostic.severity.ERROR,
				})
			end, function()
				vim.diagnostic.goto_prev({
					severity = vim.diagnostic.severity.ERROR,
				})
			end)
			vim.diagnostic.goto_prev({
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)
	end,
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

vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("LspRestart")
	vim.print("LSP Restarted!")
end, { desc = "[r]estart [l]sp" })

vim.diagnostic.config({
	virtual_text = true,
	signs = false,
	severity_sort = true,
	float = {
		source = true,
	},
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		"ts_ls",
		"rust_analyzer",
		"gopls",
		"basedpyright",
		"lua_ls",
		"bashls",
		"jsonls",
		"yamlls",
		"bashls",
		"svelte",
		"tailwindcss",
	},
	handlers = {
		function(server_name)
			local lspconfig = require("lspconfig")
			local config = {}

			config.capabilities =
				require("blink.cmp").get_lsp_capabilities(config.capabilities)

			lspconfig[server_name].setup(config)
		end,
		lua_ls = function()
			local lspconfig = require("lspconfig")

			local config = {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								vim.env.VIMRUNTIME,
							},
						},
					},
				},
			}

			lspconfig.lua_ls.setup(config)
		end,
		pyright = function()
			local lspconfig = require("lspconfig")
			lspconfig.pyright.setup({
				root_dir = function()
					return vim.fn.getcwd()
				end,
				capabilities = capabilities,
			})
		end,
		ts_ls = function()
			local lspconfig = require("lspconfig")
			lspconfig.ts_ls.setup({
				settings = {
					javascript = {
						inlayHints = {
							includeInlayEnumMemberValueHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
							includeInlayParameterNameHintsWhenArgumentMatchesName = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayVariableTypeHints = true,
						},
					},

					typescript = {
						inlayHints = {
							includeInlayEnumMemberValueHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
							includeInlayParameterNameHintsWhenArgumentMatchesName = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayVariableTypeHints = true,
						},
					},
				},
				capabilities = capabilities,
			})
		end,
		gopls = function()
			local lspconfig = require("lspconfig")
			lspconfig.gopls.setup({
				settings = {
					gopls = {
						codelenses = {
							gc_details = false,
							generate = true,
							regenerate_cgo = true,
							run_govulncheck = true,
							test = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
						},
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						usePlaceholders = false,
						symbolScope = "workspace",
					},
				},
				capabilities = capabilities,
			})
		end,
		ruff = function() end,
		buf_ls = function() end,
		jsonls = function()
			local lspconfig = require("lspconfig")
			lspconfig.jsonls.setup({
				-- lazy-load schemastore when needed
				on_new_config = function(new_config)
					new_config.settings.json.schemas = new_config.settings.json.schemas
						or {}
					vim.list_extend(
						new_config.settings.json.schemas,
						require("schemastore").json.schemas()
					)
				end,
				settings = {
					json = {
						validate = { enable = true },
					},
				},
				capabilities = capabilities,
			})
		end,
		yamlls = function()
			local lspconfig = require("lspconfig")
			lspconfig.yamlls.setup({
				-- Have to add this for yamlls to understand that we support line folding
				capabilities = capabilities,
				on_attach = function(client)
					client.server_capabilities.dynamicRegistration = false
					client.server_capabilities.lineFoldingOnly = true
				end,
				-- lazy-load schemastore when needed
				on_new_config = function(new_config)
					new_config.settings.yaml.schemas = vim.tbl_deep_extend(
						"force",
						new_config.settings.yaml.schemas or {},
						require("schemastore").yaml.schemas()
					)
				end,
				settings = {
					yaml = {
						schemaStore = {
							-- You must disable built-in schemaStore support if you want to use
							-- this plugin and its advanced options like `ignore`.
							enable = false,
							-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
							url = "",
						},
					},
				},
			})
		end,
	},
})
