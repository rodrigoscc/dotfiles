vim.keymap.set("n", "<C-p>", function()
	Snacks.picker.smart({
		layout = { preview = false },
		multi = { "git_status", "marks", "buffers", "files" },
		formatters = {
			file = {
				truncate = 256,
			},
		},
	})
end)
vim.keymap.set("n", "<leader>pf", Snacks.picker.git_files)
vim.keymap.set("n", "<leader>ff", Snacks.picker.files)

vim.keymap.set("n", "<C-f>", Snacks.picker.lines)
vim.keymap.set("n", "<leader>/", function()
	Snacks.picker.grep({ regex = false }) -- easier to include dots and braces without regex
end)
vim.keymap.set("n", "<leader>*", Snacks.picker.grep_word)
vim.keymap.set("x", "<leader>*", Snacks.picker.grep_word)

vim.keymap.set("n", "]w", function()
	vim.g.set_jump(function()
		Snacks.words.jump(1, true)
	end, function()
		Snacks.words.jump(-1, true)
	end)
	Snacks.words.jump(1, true)
end)
vim.keymap.set("n", "[w", function()
	vim.g.set_jump(function()
		Snacks.words.jump(1, true)
	end, function()
		Snacks.words.jump(-1, true)
	end)
	Snacks.words.jump(-1, true)
end)

vim.keymap.set(
	"n",
	"<leader>ss",
	Snacks.picker.spelling,
	{ desc = "[s]pell [s]uggest" }
)

vim.keymap.set(
	"n",
	"<leader>ht",
	Snacks.picker.help,
	{ desc = "[h]elp [t]ags" }
)
vim.keymap.set(
	"n",
	"<leader>hk",
	Snacks.picker.keymaps,
	{ desc = "[h]elp [k]eymaps" }
)

vim.keymap.set(
	"n",
	"<leader>cc",
	Snacks.picker.commands,
	{ desc = "[c]ommands" }
)

vim.keymap.set("n", "<leader>rr", Snacks.picker.resume, { desc = "[r]esume" })

vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches({
		win = {
			input = {
				keys = {
					["<C-d>"] = {
						"diff_branch",
						mode = { "i", "n" },
					},
				},
			},
		},
	})
end, { desc = "[g]it [b]ranches" })
vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log({ layout = "ivy_split" })
end, { desc = "[g]it [l]ogs" })
vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_file({ layout = "ivy_split" })
end, { desc = "[g]it buffer [l]ogs" })
vim.keymap.set(
	"n",
	"<leader>gg",
	Snacks.picker.git_status,
	{ desc = "[g]it status" }
)

vim.keymap.set(
	"n",
	"<leader>ir",
	Snacks.picker.registers,
	{ desc = "[i]nsert [r]egisters" }
)

vim.keymap.set(
	"n",
	"<leader>T",
	Snacks.picker.pickers,
	{ desc = "[T]elescope builtins" }
)

vim.keymap.set("n", "<leader>bb", Snacks.picker.buffers, { desc = "[b]uffers" })

vim.keymap.set(
	"n",
	"<leader>D",
	Snacks.picker.diagnostics,
	{ desc = "[D]iagnostics" }
)

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.files({
		cwd = "~/.config/",
	})
end, { desc = "[f]ind [d]otfile" })

local function open_file_at_startup()
	Snacks.picker.smart({
		layout = { preview = false },
		multi = { "git_status", "marks", "buffers", "files" },
		formatters = {
			file = {
				truncate = 256,
			},
		},
	})
end

vim.api.nvim_create_user_command("StartWorking", function()
	open_file_at_startup()
end, {})
