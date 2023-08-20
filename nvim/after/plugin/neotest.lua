local neotest = require("neotest")

vim.keymap.set(
	"n",
	"<leader>tn",
	neotest.run.run,
	{ desc = "[t]est [n]earest" }
)
vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "[t]est [f]ile" })
vim.keymap.set("n", "<leader>tS", function()
	neotest.run.run({ suite = true })
end, { desc = "[t]est [S]uite" })
vim.keymap.set("n", "<leader>ot", function()
	neotest.output.open({ enter = true })
end, { desc = "[o]pen [t]est output window" })
vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "[t]oggle test [s]ummary" })

vim.keymap.set("n", "<leader>dn", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "[d]ebug [n]earest test" })
