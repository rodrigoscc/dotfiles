local builtin = require("telescope.builtin")
local telescope = require("telescope")

telescope.setup({
	defaults = {
		layout_config = {
			prompt_position = "top",
			flex = {
				flip_columns = 170,
			},
			vertical = {
				mirror = true,
			},
		},
		layout_strategy = "flex",
	},
})

telescope.load_extension("luasnip")

vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find)

vim.keymap.set("n", "<leader>/", builtin.live_grep)

vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "[s]pell [s]uggest" })

vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ no_ignore = true })
end, { desc = "[f]ind [f]iles" })

vim.keymap.set("n", "<leader>ht", builtin.help_tags, { desc = "[h]elp [t]ags" })
vim.keymap.set("n", "<leader>hk", builtin.keymaps, { desc = "[h]elp [k]eymaps" })

vim.keymap.set("n", "<leader>cc", builtin.commands, { desc = "[c]ommands" })

vim.keymap.set("n", "<leader>rr", builtin.resume, { desc = "[r]esume" })

vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "[g]it [b]ranches" })
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[g]it [c]ommits" })
vim.keymap.set("n", "<leader>gC", builtin.git_bcommits, { desc = "[g]it buffer [C]ommits" })

vim.keymap.set("n", "<leader>ir", builtin.registers, { desc = "[i]nsert [r]egisters" })

vim.keymap.set("n", "<leader>T", builtin.builtin, { desc = "[T]elescope builtins" })

vim.keymap.set("n", "<leader>,", function()
	builtin.buffers({
		ignore_current_buffer = true,
		sort_lastused = true,
	})
end, { desc = "buffers" })

vim.keymap.set("n", "<leader>is", "<cmd>Telescope luasnip<cr>", { desc = "[i]nsert [s]nippet" })

local function open_file_at_startup(data)
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end

	builtin.git_files()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_file_at_startup })
