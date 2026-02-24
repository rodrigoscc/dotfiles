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

vim.keymap.set("n", "<leader>pf", Snacks.picker.git_files)
vim.keymap.set("n", "<leader>ff", Snacks.picker.files)

vim.keymap.set("n", "<C-f>", function()
	Snacks.picker.lines({
		win = {
			preview = {
				minimal = true,
				wo = { signcolumn = "yes:2" },
			},
		},
	})
end)

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
	{ desc = "spell suggest" }
)

vim.keymap.set("n", "<leader>ht", Snacks.picker.help, { desc = "help tags" })
vim.keymap.set(
	"n",
	"<leader>hk",
	Snacks.picker.keymaps,
	{ desc = "help keymaps" }
)

vim.keymap.set("n", "<leader>cc", Snacks.picker.commands, { desc = "commands" })

vim.keymap.set("n", "<leader>rr", Snacks.picker.resume, { desc = "resume" })

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
end, { desc = "git branches" })
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
end, { desc = "git logs" })
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
end, { desc = "git buffer logs" })
vim.keymap.set(
	"n",
	"<leader>gg",
	Snacks.picker.git_status,
	{ desc = "git status" }
)

vim.keymap.set(
	"n",
	"<leader>ir",
	Snacks.picker.registers,
	{ desc = "insert registers" }
)

vim.keymap.set(
	"n",
	"<leader>T",
	Snacks.picker.pickers,
	{ desc = "Snacks builtins" }
)

vim.keymap.set("n", "<leader>bb", Snacks.picker.buffers, { desc = "buffers" })

vim.keymap.set(
	"n",
	"<leader>D",
	Snacks.picker.diagnostics,
	{ desc = "Diagnostics" }
)

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.files({
		cwd = "~/.config/",
	})
end, { desc = "find dotfile" })

vim.api.nvim_create_user_command("StartWorking", function()
	require("fff").find_files()
end, {})

vim.keymap.set("n", "<leader>q", function()
	local files = files_from_qf()

	Snacks.picker.grep({
		dirs = files,
	})
end, { desc = "grep quickfix" })

vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "buffer delete" })

vim.keymap.set(
	"n",
	"<leader>bo",
	Snacks.bufdelete.other,
	{ desc = "buffer only" }
)

vim.keymap.set(
	"n",
	"<leader>bD",
	Snacks.bufdelete.all,
	{ desc = "buffer Delete all" }
)

local images_group =
	vim.api.nvim_create_augroup("custom.snacks.image", { clear = true })

vim.keymap.set("n", "gK", function()
	Snacks.image.hover()

	vim.api.nvim_create_autocmd(
		{ "BufWritePost", "CursorMoved", "ModeChanged", "BufLeave" },
		{
			group = images_group,
			callback = function()
				require("snacks.image.doc").hover_close()
				vim.api.nvim_clear_autocmds({ group = images_group })
				return true
			end,
		}
	)
end, { desc = "show image" })
