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
	"n",
	"<leader>sh",
	gitsigns.stage_hunk,
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

vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "next hunk" })
vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "previous hunk" })

local hint = [[
 _J_: next hunk   _S_: stage hunk
 _K_: prev hunk   _P_: preview hunk inline
 ^
 _q_: exit
]]

Hydra({
	name = "Git stage",
	mode = "n",
	hint = hint,
	body = "<leader>G",
	config = {
		on_key = function()
			-- vim.wait(50)
		end,
		color = "pink",
		invoke_on_body = true,
	},
	heads = {
		{
			"J",
			function()
				gitsigns.next_hunk()
			end,
		},
		{
			"K",
			function()
				gitsigns.prev_hunk()
			end,
		},
		{
			"S",
			function()
				gitsigns.stage_hunk()
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
