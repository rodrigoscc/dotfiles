local builtin = require("telescope.builtin")
local telescope = require("telescope")

telescope.setup({
	defaults = vim.tbl_extend(
		"force",
		require("telescope.themes").get_ivy(),
		{}
	),
	pickers = {
		git_status = {
			attach_mappings = function(_, map)
				map({ "i", "n" }, "<C-d>", function(_)
					local action_state = require("telescope.actions.state")
					local entry = action_state.get_selected_entry()
					vim.cmd("edit! " .. entry.value)
					vim.cmd.Ghdiffsplit()
				end)
				return true
			end,
		},
	},
})

telescope.load_extension("luasnip")
telescope.load_extension("fzf")
telescope.load_extension("harpoon")

vim.keymap.set("n", "<C-p>", function()
	local cwd = vim.loop.cwd()
	if cwd and string.find(cwd, ".config") then
		builtin.git_files()
	else
		builtin.find_files()
	end
end, {})
vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find)

vim.keymap.set("n", "<leader>/", function()
	builtin.grep_string({
		shorten_path = true,
		word_match = "-w",
		only_sort_text = true,
		search = "",
	})
end)

vim.keymap.set(
	"n",
	"<leader>ss",
	builtin.spell_suggest,
	{ desc = "[s]pell [s]uggest" }
)

vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ no_ignore = true, hidden = true })
end, { desc = "[f]ind all [f]iles" })

vim.keymap.set("n", "<leader>ht", builtin.help_tags, { desc = "[h]elp [t]ags" })
vim.keymap.set(
	"n",
	"<leader>hk",
	builtin.keymaps,
	{ desc = "[h]elp [k]eymaps" }
)

vim.keymap.set("n", "<leader>cc", builtin.commands, { desc = "[c]ommands" })

vim.keymap.set("n", "<leader>rr", builtin.resume, { desc = "[r]esume" })

vim.keymap.set(
	"n",
	"<leader>gb",
	builtin.git_branches,
	{ desc = "[g]it [b]ranches" }
)
vim.keymap.set(
	"n",
	"<leader>gh",
	builtin.git_commits,
	{ desc = "[g]it [h]istory" }
)
vim.keymap.set(
	"n",
	"<leader>gH",
	builtin.git_bcommits,
	{ desc = "[g]it buffer [H]istory" }
)
vim.keymap.set("n", "<leader>gg", builtin.git_status, { desc = "[g]it status" })

vim.keymap.set(
	"n",
	"<leader>ir",
	builtin.registers,
	{ desc = "[i]nsert [r]egisters" }
)

vim.keymap.set(
	"n",
	"<leader>T",
	builtin.builtin,
	{ desc = "[T]elescope builtins" }
)

vim.keymap.set("n", "<leader>,", function()
	builtin.buffers({
		ignore_current_buffer = true,
		sort_lastused = true,
	})
end, { desc = "buffers" })

vim.keymap.set(
	"n",
	"<leader>is",
	"<cmd>Telescope luasnip<cr>",
	{ desc = "[i]nsert [s]nippet" }
)

vim.keymap.set(
	"n",
	"<leader>D",
	"<cmd>Telescope diagnostics<cr>",
	{ desc = "[D]iagnostics" }
)

local function open_file_at_startup(data)
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end

	if string.find(data.file, ".config") then
		builtin.git_files()
	else
		builtin.find_files()
	end
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_file_at_startup })
