local gitsigns = require("gitsigns")
local Hydra = require("hydra")

vim.keymap.set(
	"n",
	"<leader>ph",
	gitsigns.preview_hunk_inline,
	{ desc = "[p]review [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>pH",
	gitsigns.preview_hunk,
	{ desc = "[p]review [h]unk popup" }
)
vim.keymap.set(
	{ "n", "v" },
	"<leader>sh",
	"<cmd>Gitsigns stage_hunk<cr>",
	{ desc = "[s]tage [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>rh",
	gitsigns.reset_hunk,
	{ desc = "[r]eset [h]unk" }
)
vim.keymap.set(
	"n",
	"<leader>bl",
	gitsigns.blame_line,
	{ desc = "[b]lame [l]ine" }
)

vim.keymap.set("n", "]h", function()
	vim.g.set_jump(gitsigns.next_hunk, gitsigns.prev_hunk)
	gitsigns.next_hunk()
end, { desc = "next hunk" })

vim.keymap.set("n", "[h", function()
	vim.g.set_jump(gitsigns.next_hunk, gitsigns.prev_hunk)
	gitsigns.prev_hunk()
end, { desc = "previous hunk" })

local hint = [[
Git stage:
 _J_: next hunk   _S_: stage hunk            _U_: undo stage hunk
 _K_: prev hunk   _P_: preview hunk inline   _R_: reset hunk
 ^
 _q_: exit
]]

Hydra({
	name = "Git stage",
	mode = "n",
	hint = hint,
	body = "<leader>G",
	config = {
		color = "pink",
		invoke_on_body = true,
		hint = {
			border = "rounded",
		},
	},
	heads = {
		{
			"J",
			function()
				gitsigns.next_hunk()
				vim.schedule(function()
					vim.api.nvim_feedkeys("zz", "n", false)
				end)
			end,
		},
		{
			"K",
			function()
				gitsigns.prev_hunk()
				vim.schedule(function()
					vim.api.nvim_feedkeys("zz", "n", false)
				end)
			end,
		},
		{
			"S",
			function()
				gitsigns.stage_hunk()
			end,
		},
		{
			"U",
			function()
				gitsigns.undo_stage_hunk()
			end,
		},
		{
			"R",
			function()
				gitsigns.reset_hunk()
			end,
		},
		{
			"P",
			function()
				gitsigns.preview_hunk_inline()
			end,
		},
		{
			"q",
			nil,
			{ exit = true, nowait = true, desc = "exit" },
		},
	},
})

vim.keymap.set("n", "<leader>H", function()
	gitsigns.setqflist("all")
end, { desc = "show all [H]unks" })
