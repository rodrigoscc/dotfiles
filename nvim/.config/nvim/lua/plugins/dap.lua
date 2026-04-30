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
