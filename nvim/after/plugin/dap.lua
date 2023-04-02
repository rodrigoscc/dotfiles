local dap = require("dap")
local dapui = require("dapui")

vim.keymap.set("n", "<leader>tb", dap.toggle_breakpoint, { desc = "[t]oggle [b]reakpoint" })
vim.keymap.set("n", "<leader>td", dapui.toggle, { desc = "[t]oggle [d]apui" })

vim.keymap.set("n", "<leader>cb", dap.clear_breakpoints, { desc = "[c]lear [b]reakpoints" })

vim.keymap.set("n", "<leader>dd", dap.continue, { desc = "[d]ebug / continue" })

vim.keymap.set("n", "<leader>or", dap.repl.open, { desc = "[o]pen [r]epl" })

vim.keymap.set("n", "<leader>so", dap.step_over, { desc = "[s]tep [o]ver" })
vim.keymap.set("n", "<leader>si", dap.step_into, { desc = "[s]tep [i]nto" })
vim.keymap.set("n", "<leader>su", dap.step_out, { desc = "[s]tep o[u]t" })

vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "[d]ebug [e]val" })
