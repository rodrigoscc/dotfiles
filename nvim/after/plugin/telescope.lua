local fzf_lua = require("fzf-lua")

vim.keymap.set("n", "<C-p>", fzf_lua.files)
vim.keymap.set("n", "<leader>pf", fzf_lua.git_files)

vim.keymap.set("n", "<C-f>", fzf_lua.grep_curbuf)
vim.keymap.set("n", "<leader>/", fzf_lua.live_grep)
vim.keymap.set("n", "<leader>*", fzf_lua.grep_cword)
vim.keymap.set("x", "<leader>*", fzf_lua.grep_visual)

vim.keymap.set(
	"n",
	"<leader>ss",
	fzf_lua.spell_suggest,
	{ desc = "[s]pell [s]uggest" }
)

vim.keymap.set("n", "<leader>ht", fzf_lua.help_tags, { desc = "[h]elp [t]ags" })
vim.keymap.set(
	"n",
	"<leader>hk",
	fzf_lua.keymaps,
	{ desc = "[h]elp [k]eymaps" }
)

vim.keymap.set("n", "<leader>cc", fzf_lua.commands, { desc = "[c]ommands" })

vim.keymap.set("n", "<leader>rr", fzf_lua.resume, { desc = "[r]esume" })

vim.keymap.set(
	"n",
	"<leader>gb",
	fzf_lua.git_branches,
	{ desc = "[g]it [b]ranches" }
)
vim.keymap.set(
	"n",
	"<leader>gl",
	fzf_lua.git_commits,
	{ desc = "[g]it [l]ogs" }
)
vim.keymap.set(
	"n",
	"<leader>gL",
	fzf_lua.git_bcommits,
	{ desc = "[g]it buffer [l]ogs" }
)
vim.keymap.set("n", "<leader>gg", fzf_lua.git_status, { desc = "[g]it status" })

vim.keymap.set(
	"n",
	"<leader>ir",
	fzf_lua.registers,
	{ desc = "[i]nsert [r]egisters" }
)

vim.keymap.set(
	"n",
	"<leader>T",
	fzf_lua.builtin,
	{ desc = "[T]elescope builtins" }
)

vim.keymap.set("n", "<leader>bb", fzf_lua.buffers, { desc = "[b]uffers" })

vim.keymap.set(
	"n",
	"<leader>D",
	fzf_lua.diagnostics_workspace,
	{ desc = "[D]iagnostics" }
)

vim.keymap.set("n", "<leader>fd", function()
	fzf_lua.files({
		cwd = "~/.config/",
	})
end, { desc = "[f]ind [d]otfile" })

local function open_file_at_startup()
	fzf_lua.files()
end

vim.api.nvim_create_user_command("StartWorking", function()
	open_file_at_startup()
end, {})
