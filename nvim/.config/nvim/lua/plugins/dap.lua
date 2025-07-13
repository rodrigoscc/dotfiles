return {
	{ "mfussenegger/nvim-dap", lazy = true },
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		keys = {
			{
				"<leader>tb",
				function()
					require("dap").toggle_breakpoint()
				end,
				{ desc = "[t]oggle [b]reakpoint" },
			},
			{
				"<leader>lb",
				function()
					require("dapui").float_element("breakpoints")
				end,
				{ desc = "[l]ist [b]reakpoints" },
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
				{ desc = "[b]reakpoint [l]og message" },
			},
			{
				"<leader>bc",
				function()
					vim.ui.input({ prompt = "Condition:" }, function(input)
						require("dap").set_breakpoint(input, nil, nil)
					end)
				end,
				{ desc = "[b]reakpoint [c]ondition" },
			},
			{
				"<leader>td",
				function()
					require("dapui").toggle()
				end,
				{ desc = "[t]oggle [d]apui" },
			},
			{
				"<leader>cb",
				function()
					require("dap").clear_breakpoints()
					vim.cmd("echo 'Breakpoints cleared!'")
				end,
				{ desc = "[c]lear [b]reakpoints" },
			},
			{
				"<leader>dd",
				function()
					require("dap").continue()
				end,
				{ desc = "[d]ebug / continue" },
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				{ desc = "[d]ebug [l]ast" },
			},
			{
				"<leader>tr",
				function()
					require("dap").repl.toggle()
				end,
				{ desc = "[t]oggle [r]epl" },
			},
			{
				"<leader>so",
				function()
					require("dap").step_over()
				end,
				{ desc = "[s]tep [o]ver" },
			},
			{
				"<leader>si",
				function()
					require("dap").step_into()
				end,
				{ desc = "[s]tep [i]nto" },
			},
			{
				"<leader>su",
				function()
					require("dap").step_out()
				end,
				{ desc = "[s]tep o[u]t" },
			},
			{
				"<F8>",
				function()
					require("dap").continue()
				end,
				{ desc = "debug / continue" },
			},
			{
				"<F9>",
				function()
					require("dap").step_over()
				end,
				{ desc = "step over" },
			},
			{
				"<F10>",
				function()
					require("dap").step_into()
				end,
				{ desc = "step into" },
			},
			{
				"<F11>",
				function()
					require("dap").step_out()
				end,
				{ desc = "step out" },
			},
		},
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dap.defaults.fallback.external_terminal = {
				command = "tmux",
				args = { "split-window", "-p", "20" },
			}

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.8 },
							{ id = "watches", size = 0.2 },
						},
						position = "left",
						size = 40,
					},
					{
						elements = {
							{ id = "console", size = 0.5 },
							{ id = "repl", size = 0.5 },
						},
						position = "bottom",
						size = 10,
					},
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			require("dap.ext.vscode").load_launchjs()

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
				text = "",
				texthl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointCondition", {
				text = "ﳁ",
				texthl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointRejected", {
				text = "",
				texthl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define(
				"DapLogPoint",
				{ text = "", texthl = "DapLogPoint", numhl = "DapLogPoint" }
			)
			vim.fn.sign_define("DapStopped", {
				text = "",
				texthl = "DapStopped",
				linehl = "DapStoppedLine",
				numhl = "DapStopped",
			})
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap" },
	},
}
