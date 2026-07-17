vim.keymap.set(
	"n",
	"<leader>of",
	":Obsidian quick_switch ", -- Purposely not pressing <CR> to allow entering an argument.
	{ desc = "find obsidian file" }
)
vim.keymap.set(
	"n",
	"<leader>on",
	"<cmd>Obsidian new<cr>",
	{ desc = "new obsidian" }
)

vim.keymap.set(
	"n",
	"<leader>o#",
	"<cmd>Obsidian tags<cr>",
	{ desc = "obsidian tags" }
)

vim.keymap.set(
	"n",
	"<leader>.",
	"<cmd>Obsidian tags projects<cr>",
	{ desc = "search obsidian projects" }
)

vim.keymap.set("n", "<leader>os", function()
	require("fff").live_grep({
		cwd = "~/obsidian-vault/",
		title = "Obsidian",
		query = "*.md ",
		grep = { modes = { "plain" } },
	})
end, { desc = "obsidian search" })

vim.keymap.set(
	"n",
	"<leader>oo",
	"<cmd>Obsidian today<cr>",
	{ desc = "obsidian today" }
)
vim.keymap.set(
	"n",
	"<leader>oy",
	"<cmd>Obsidian yesterday<cr>",
	{ desc = "obsidian yesterday" }
)

local function new_todo()
	vim.cmd.Obsidian("today")

	vim.schedule(function()
		vim.cmd.normal("G")
		vim.opt.autoindent = false
		vim.cmd.normal("o")
		vim.opt.autoindent = true
		require("checkmate").create()
	end)
end

vim.keymap.set("n", "<leader><space>", new_todo, { desc = "obsidian new todo" })
vim.keymap.set("n", "<leader>[", new_todo, { desc = "obsidian new todo" })

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
			preset = "telescope",
			layout = { width = 0.8 },
			hidden = { "preview" },
		},
	})
end, { desc = "obsidian todos" })

function obsidian_todo_fzf()
	local fzf = require("fzf-lua")

	fzf.fzf_exec(
		"rg --json --column --line-number --sortr created --no-heading '\\- \\[ \\] (.+)' ~/obsidian-vault/",
		{
			file_icons = true,
			fn_transform = function(line)
				local utils = require("fzf-lua.utils")
				local make_entry = require("fzf-lua.make_entry")

				local entry = vim.json.decode(line)

				if
					entry.type == "match"
					and entry.data.lines
					and entry.data.lines.text
				then
					local path = entry.data.path.text
					local line_number = entry.data.line_number

					local todo, _ = entry.data.lines.text:gsub("%- %[ %] ", "")

					local is_high_priority = todo:find("%@priority%(high%)")
						~= nil
					local is_medium_priority = todo:find("%@priority%(medium%)")
						~= nil
					local is_low_priority = todo:find("%@priority%(low%)")
						~= nil

					todo = vim.trim(todo)

					if is_high_priority then
						todo = utils.ansi_codes.red(todo)
					elseif is_medium_priority then
						todo = utils.ansi_codes.yellow(todo)
					elseif is_low_priority then
						todo = utils.ansi_codes.gray(todo)
					else
						todo = utils.ansi_codes.white(todo)
					end

					return make_entry.file(
						path
							.. ":"
							.. tostring(line_number)
							.. ":"
							.. utils.ansi_codes.magenta("TODO ")
							.. todo,
						{ file_icons = true, color_icons = true }
					)
				end

				return nil
			end,
			actions = {
				["default"] = require("fzf-lua").actions.file_edit,
			},
		}
	)
end
vim.keymap.set("n", "<leader>ot", obsidian_todo_fzf)

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
