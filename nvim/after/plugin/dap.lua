local dap = require("dap")
local dapui = require("dapui")

vim.keymap.set("n", "<leader>tb", dap.toggle_breakpoint, { desc = "[t]oggle [b]reakpoint" })
vim.keymap.set("n", "<leader>bL", function()
	vim.ui.input({ prompt = "Log breakpoint message:" }, function(input)
		dap.set_breakpoint(nil, nil, input)
	end)
end, { desc = "[b]reakpoint [l]og message" })
vim.keymap.set("n", "<leader>bc", function()
	vim.ui.input({ prompt = "Condition:" }, function(input)
		dap.set_breakpoint(input, nil, nil)
	end)
end, { desc = "[b]reakpoint [c]ondition" })

vim.keymap.set("n", "<leader>td", dapui.toggle, { desc = "[t]oggle [d]apui" })

vim.keymap.set("n", "<leader>cb", dap.clear_breakpoints, { desc = "[c]lear [b]reakpoints" })

vim.keymap.set("n", "<leader>dd", dap.continue, { desc = "[d]ebug / continue" })

vim.keymap.set("n", "<leader>or", dap.repl.open, { desc = "[o]pen [r]epl" })

vim.keymap.set("n", "<leader>so", dap.step_over, { desc = "[s]tep [o]ver" })
vim.keymap.set("n", "<leader>si", dap.step_into, { desc = "[s]tep [i]nto" })
vim.keymap.set("n", "<leader>su", dap.step_out, { desc = "[s]tep o[u]t" })

vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "[d]ebug [e]val" })

vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })
vim.api.nvim_set_hl(0, "DapStoppedLine", { ctermbg = 0, bg = "#31353f" })

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", numhl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition", { text = "ﳁ", texthl = "DapBreakpoint", numhl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", numhl = "DapBreakpoint" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", numhl = "DapLogPoint" })
vim.fn.sign_define(
	"DapStopped",
	{ text = "", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStopped" }
)
