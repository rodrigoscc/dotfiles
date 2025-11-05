vim.keymap.set(
	"n",
	"<leader>of",
	":Obsidian quick_switch ", -- Purposely not pressing <CR> to allow entering an argument.
	{ desc = "[f]ind [o]bsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>on",
	"<cmd>Obsidian new<cr>",
	{ desc = "[n]ew [o]bsidian" }
)

vim.keymap.set(
	"n",
	"<leader>o#",
	"<cmd>Obsidian tags<cr>",
	{ desc = "[o]bsidian [t]ags" }
)

vim.keymap.set(
	"n",
	"<leader>.",
	"<cmd>Obsidian tags projects<cr>",
	{ desc = "[s]earch obsidian projects" }
)

vim.keymap.set(
	"n",
	"<leader>os",
	"<cmd>Obsidian search<cr>",
	{ desc = "[o]bsidian [s]earch" }
)

vim.keymap.set(
	"n",
	"<leader>oo",
	"<cmd>Obsidian today<cr>",
	{ desc = "[o]bsidian today" }
)
vim.keymap.set(
	"n",
	"<leader>oy",
	"<cmd>Obsidian yesterday<cr>",
	{ desc = "[o]bsidian [y]esterday" }
)

vim.keymap.set("n", "<leader>ot", function()
	Snacks.picker.grep({
		cwd = "~/obsidian-vault/",
		live = false,
		search = "- \\[ \\]",
		title = "Obsidian TODOs",
		matcher = { fuzzy = false },
		sort = { fields = { "file:desc" } },
		args = { "--sortr", "path" },
		format = function(item, picker)
			local format = require("snacks.picker.format")

			---@type snacks.picker.Highlight[]
			local ret = {}

			vim.list_extend(ret, format.filename(item, picker))

			table.insert(ret, { "TODO", "SnacksPickerComment" })
			table.insert(ret, { " " })

			if item.line then
				local clean_line = vim.trim(item.line:gsub("%- %[ %]", ""))

				local is_high_priority = string.find(
					clean_line,
					"%@priority%(high%)"
				) ~= nil
				local is_medium_priority = string.find(
					clean_line,
					"%@priority%(medium%)"
				) ~= nil
				local is_low_priority = string.find(
					clean_line,
					"%@priority%(low%)"
				) ~= nil

				local hl_group = nil
				if is_high_priority then
					hl_group = "SnacksPickerGitBreaking"
				elseif is_medium_priority then
					hl_group = "SnacksPickerMatch"
				elseif is_low_priority then
					hl_group = "SnacksPickerComment"
				end

				Snacks.picker.highlight.format(
					item,
					clean_line,
					ret,
					{ hl_group = hl_group }
				)
				table.insert(ret, { " " })
			end

			return ret
		end,
		layout = {
			preset = "vertical",
			layout = { width = 0.8 },
			hidden = { "preview" },
		},
	})
end, { desc = "[o]bsidian [t]odos" })

vim.api.nvim_create_autocmd("User", {
	pattern = "ObsidianNoteEnter",
	callback = function(ev)
		-- Replace default <CR> obsidian keymap with checkmate binding.
		-- There's no way to disable obsidian.nvim default keymaps.
		-- See: https://github.com/obsidian-nvim/obsidian.nvim/blob/6b2a22a74d1c883e797764c28f75aa6b532a1ae4/lua/obsidian/autocmds.lua#L48
		vim.keymap.set("n", "<CR>", "<cmd>Checkmate toggle<cr>", {
			buffer = ev.buf,
			desc = "Toggle checkbox",
		})

		vim.wo[0][0].fillchars = "eob:~"
	end,
})
