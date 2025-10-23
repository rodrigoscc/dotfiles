local files_from_qf = require("custom.quickfix").files_from_qf

local function smart_picker()
	local cwd = vim.fn.getcwd()
	local cwd_contains_dotfiles = string.find(cwd, "dotfiles") ~= nil

	Snacks.picker.smart({
		layout = { preview = false },
		multi = { "git_status", "marks", "buffers", "files" },
		hidden = cwd_contains_dotfiles,
	})
end

local function smart_grep()
	local cwd = vim.fn.getcwd()
	local cwd_contains_dotfiles = string.find(cwd, "dotfiles") ~= nil

	Snacks.picker.grep({
		hidden = cwd_contains_dotfiles,
		regex = false,
	})
end

local function smart_grep_word()
	local cwd = vim.fn.getcwd()
	local cwd_contains_dotfiles = string.find(cwd, "dotfiles") ~= nil

	Snacks.picker.grep_word({
		hidden = cwd_contains_dotfiles,
	})
end

vim.keymap.set("n", "<C-p>", smart_picker)
vim.keymap.set("n", "<leader>pf", Snacks.picker.git_files)
vim.keymap.set("n", "<leader>ff", Snacks.picker.files)

vim.keymap.set("n", "<C-f>", Snacks.picker.lines)
vim.keymap.set("n", "<leader>/", smart_grep)
vim.keymap.set({ "n", "x" }, "<leader>*", smart_grep_word)

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
					["<c-e>h"] = {
						"diff_head",
						mode = { "i", "n" },
					},
				},
			},
		},
	})
end, { desc = "[g]it [b]ranches" })
vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log({
		layout = "ivy_split",
		win = {
			input = {
				keys = {
					["<c-e>h"] = {
						"diff_head",
						mode = { "i", "n" },
					},
					["<c-e>p"] = {
						"diff_parent",
						mode = { "i", "n" },
					},
				},
			},
		},
	})
end, { desc = "[g]it [l]ogs" })
vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_file({
		layout = "ivy_split",
		win = {
			input = {
				keys = {
					["<c-e>h"] = {
						"diff_head",
						mode = { "i", "n" },
					},
					["<c-e>p"] = {
						"diff_parent",
						mode = { "i", "n" },
					},
				},
			},
		},
	})
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

vim.api.nvim_create_user_command("StartWorking", function()
	smart_picker()
end, {})

vim.keymap.set("n", "<leader>q", function()
	local files = files_from_qf()

	Snacks.picker.grep({
		dirs = files,
	})
end, { desc = "grep [q]uickfix" })

vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "[b]uffer [d]elete" })

vim.keymap.set(
	"n",
	"<leader>bo",
	Snacks.bufdelete.other,
	{ desc = "[b]uffer [o]nly" }
)

vim.keymap.set(
	"n",
	"<leader>bD",
	Snacks.bufdelete.all,
	{ desc = "[b]uffer [D]elete all" }
)

vim.keymap.set("n", "gK", Snacks.image.hover, { desc = "show image" })
