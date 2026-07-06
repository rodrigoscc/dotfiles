vim.g.scratch_dir = ".scratch"

local filetype_extension = {
	python = ".py",
	lua = ".lua",
	go = ".go",
	javascript = ".js",
	typescript = ".js",
	rust = ".rs",
	json = ".json",
	html = ".html",
	yaml = ".yml",
	text = ".txt",
	csv = ".csv",
	sql = ".sql",
	sh = ".sh",
	bash = ".sh",
}

local function new_scratch()
	vim.fn.mkdir(vim.g.scratch_dir, "p", "0o755")

	local filetypes = vim.fn.getcompletion("", "filetype")
	local current_filetype = vim.o.filetype

	for index, filetype in ipairs(filetypes) do
		if filetype == current_filetype then
			table.remove(filetypes, index)
		end
	end

	table.insert(filetypes, 1, current_filetype)

	vim.ui.select(
		filetypes,
		{ prompt = "Create scratch file with filetype: " },
		function(filetype)
			if filetype == nil then
				return
			end

			local extension = filetype_extension[filetype] or ""
			local default_basename = "scratch." .. os.date("!%Y%m%d%H%M%S")

			vim.ui.input({
				prompt = "Create scratch file with base name: ",
				default = default_basename,
			}, function(basename)
				if basename == nil then
					return
				end

				local fullname = vim.g.scratch_dir
					.. "/"
					.. basename
					.. extension

				vim.cmd("split " .. fullname)

				local buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_set_option_value(
					"filetype",
					filetype,
					{ buf = buf }
				)
			end)
		end
	)
end

local function find_scratch()
	Snacks.picker.files({
		title = "Scratch files",
		cwd = vim.g.scratch_dir,
		args = {
			"--strip-cwd-prefix", -- stat includes a ./ as prefix to file names
			"--exec-batch",
			"stat",
			"-f",
			"%SB > %N",
			"-t",
			"%Y-%m-%d %H:%M",
		},
		sort = { fields = { "full_item:desc" } },
		transform = function(ctx)
			local time, file = unpack(vim.split(ctx.file, " > "))
			ctx.full_item = ctx.file
			ctx.label = time
			ctx.file = file
			return true
		end,
		matcher = {
			sort_empty = true, -- important for the initial list to be sorted with file:desc
		},
	})
end

function find_scratch_fzf()
	local fzf = require("fzf-lua")

	fzf.fzf_exec(
		"fd --type f --exec-batch stat -f '%SB > %N' -t '%Y-%m-%d %H:%M' | sort --reverse",
		{
			cwd = vim.g.scratch_dir,
			fzf_opts = {
				["--no-sort"] = true,
				["--delimiter"] = " > ",
			},
			fn_transform = function(line)
				local utils = require("fzf-lua.utils")

				local parts = vim.split(line, " > ")

				local item = utils.ansi_codes.magenta(parts[1])

				item = item
					.. " > "
					.. table.concat(
						vim.iter(parts):slice(2, #parts + 1):totable()
					)

				return item
			end,
			actions = {
				["default"] = {
					fn = function(r, opts)
						require("fzf-lua").actions.file_edit(r, opts)
					end,
					field_index = "{2}",
				},
			},
		}
	)
end

vim.api.nvim_create_user_command("NewScratch", new_scratch, {})
vim.api.nvim_create_user_command("FindScratch", find_scratch, {})

vim.keymap.set(
	"n",
	"<leader>ns",
	"<cmd>NewScratch<cr>",
	{ desc = "new scratch" }
)
vim.keymap.set(
	"n",
	"<leader>fs",
	"<cmd>FindScratch<cr>",
	{ desc = "find scratch" }
)
