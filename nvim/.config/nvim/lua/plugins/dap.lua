return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{
				"<leader>tb",
				function()
					require("dap").toggle_breakpoint()
				end,
				{ desc = "toggle breakpoint" },
			},
			{
				"<leader>bL",
				function()
					vim.ui.input(
						{ prompt = "Log breakpoint message:" },
						function(input)
							require("dap").set_breakpoint(nil, nil, input)
						end
					)
				end,
				{ desc = "breakpoint log message" },
			},
			{
				"<leader>bc",
				function()
					vim.ui.input({ prompt = "Condition:" }, function(input)
						require("dap").set_breakpoint(input, nil, nil)
					end)
				end,
				{ desc = "breakpoint condition" },
			},
			{
				"<leader>cb",
				function()
					require("dap").clear_breakpoints()
					vim.cmd("echo 'Breakpoints cleared!'")
				end,
				{ desc = "clear breakpoints" },
			},
			{
				"<leader>dd",
				function()
					require("dap").continue()
				end,
				{ desc = "debug / continue" },
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				{ desc = "debug last" },
			},
			{
				"<leader>tr",
				function()
					require("dap").repl.toggle()
				end,
				{ desc = "toggle repl" },
			},
			{
				"<leader>dp",
				function()
					require("dap.ui.widgets").preview()
				end,
				{ desc = "dap hover" },
			},
			{
				"<leader>dh",
				function()
					require("dap-view").hover()
				end,
				{ desc = "dap hover" },
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				{ desc = "debug / continue" },
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				{ desc = "step over" },
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				{ desc = "step into" },
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				{ desc = "step out" },
			},
			{
				"<leader>df",
				function()
					require("dap").focus_frame()
				end,
				{ desc = "dap focus frame" },
			},
			{
				"<leader>dc",
				function()
					require("dap").run_to_cursor()
				end,
				{ desc = "dap focus frame" },
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate({ hierarchy = true })
				end,
				{ desc = "dap focus frame" },
			},
			{
				"]f",
				function()
					require("dap").down()
				end,
				{ desc = "dap down" },
			},
			{
				"[f",
				function()
					require("dap").up()
				end,
				{ desc = "dap up" },
			},
		},
		config = function()
			local dap = require("dap")

			dap.defaults.fallback.external_terminal = {
				command = "kitten",
				args = {
					"@",
					"action",
					"launch",
					"--add-to-session=.",
					"--keep-focus",
				},
			}

			-- Force debugee to be launched in a terminal
			dap.defaults.fallback.force_external_terminal = true

			dap.listeners.before.attach.dapui_config = function()
				vim.cmd("DapViewOpen")
				vim.api.nvim_exec_autocmds(
					"User",
					{ pattern = "DapSessionAttached" }
				)
			end
			dap.listeners.before.launch.dapui_config = function()
				vim.cmd("DapViewOpen")
				vim.api.nvim_exec_autocmds(
					"User",
					{ pattern = "DapSessionLaunched" }
				)
			end

			dap.listeners.before.event_terminated["statusline"] = function()
				vim.api.nvim_exec_autocmds(
					"User",
					{ pattern = "DapSessionTerminated" }
				)
			end
			dap.listeners.before.event_exited["statusline"] = function()
				vim.api.nvim_exec_autocmds(
					"User",
					{ pattern = "DapSessionExited" }
				)
			end

			vim.api.nvim_set_hl(
				0,
				"DapBreakpoint",
				{ ctermbg = 0, fg = "#993939" }
			)
			vim.api.nvim_set_hl(
				0,
				"DapLogPoint",
				{ ctermbg = 0, fg = "#61afef" }
			)
			vim.api.nvim_set_hl(
				0,
				"DapStopped",
				{ ctermbg = 0, fg = "#98c379" }
			)
			vim.api.nvim_set_hl(
				0,
				"DapStoppedLine",
				{ ctermbg = 0, bg = "#31353f" }
			)

			vim.fn.sign_define("DapBreakpoint", {
				text = "",
				texthl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointCondition", {
				text = "",
				texthl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointRejected", {
				text = "",
				texthl = "DiagnosticError",
				numhl = "DiagnosticError",
			})
			vim.fn.sign_define(
				"DapLogPoint",
				{ text = "", texthl = "DapLogPoint", numhl = "DapLogPoint" }
			)
			vim.fn.sign_define("DapStopped", {
				text = "",
				texthl = "DapStopped",
				linehl = "DapStoppedLine",
				numhl = "DapStopped",
			})

			local function find_python_path()
				if vim.uv.fs_stat(".venv") then
					return ".venv/bin/python"
				else
					return os.getenv("HOME") .. "/.venvs/tools/bin/python"
				end
			end

			dap.adapters.debugpy = function(callback, config)
				callback({
					type = "executable",
					command = find_python_path(),
					args = { "-m", "debugpy.adapter" },
				})
			end

			dap.configurations.python = {
				{
					type = "debugpy",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = find_python_path,
				},
			}

			dap.adapters.go = function(callback, config)
				callback({
					type = "server",
					host = "127.0.0.1",
					port = "${port}",
					executable = {
						command = "dlv",
						args = { "dap", "--listen", "127.0.0.1:${port}" },
					},
				})
			end

			dap.configurations.go = {
				{
					type = "go",
					name = "Debug file",
					request = "launch",
					program = "${file}",
					outputMode = "remote", -- send output to REPL view
				},
			}

			-- JavaScript/TypeScript debugging via vscode-js-debug
			local js_debug_path = vim.fn.stdpath("data")
				.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug_path, "${port}" },
				},
			}

			dap.adapters["pwa-chrome"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug_path, "${port}" },
				},
			}

			local js_configurations = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to Node (9229)",
					port = 9229,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to Node (9230)",
					port = 9230,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch Chrome (localhost:3000)",
					url = "http://localhost:3000",
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch Chrome (localhost:5173)",
					url = "http://localhost:5173",
				},
			}

			dap.configurations.javascript = js_configurations
			dap.configurations.typescript = js_configurations
			dap.configurations.typescriptreact = js_configurations
			dap.configurations.javascriptreact = js_configurations

			dap.configurations.lua = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
			}

			dap.adapters.nlua = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 8086,
				})
			end
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		keys = {
			{
				"<leader>lb",
				function()
					require("dapui").float_element("breakpoints")
				end,
				{ desc = "list breakpoints" },
			},
			{
				"<leader>tD",
				function()
					require("dapui").toggle()
				end,
				{ desc = "toggle dapui" },
			},
		},
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		opts = {},
	},
	{
		"igorlfs/nvim-dap-view",
		---@module 'dap-view'
		---@type dapview.Config
		opts = {
			winbar = {
				sections = {
					"scopes",
					"watches",
					"exceptions",
					"breakpoints",
					"threads",
					"console",
					"repl",
				},
				default_section = "scopes",
			},
			virtual_text = {
				enabled = true,
			},
		},
		cmd = { "DapViewOpen" },
		keys = {
			{
				"<leader>td",
				"<cmd>DapViewToggle<cr>",
				{ desc = "toggle Dap view" },
			},
		},
	},
	{ "jbyuki/one-small-step-for-vimkind" },
}
