vim.g.scratch_dir = ".scratch"

local filetype_extension = {
	python = ".py",
	lua = ".lua",
	go = ".go",
	javascript = ".js",
	json = ".json",
	html = ".html",
	yaml = ".yml",
	text = ".txt",
	csv = ".csv",
	sql = ".sql",
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
				vim.api.nvim_buf_set_option(buf, "filetype", filetype)
			end)
		end
	)
end

local function find_scratch()
	Snacks.picker.files({ cwd = vim.g.scratch_dir })
end

vim.api.nvim_create_user_command("NewScratch", new_scratch, {})
vim.api.nvim_create_user_command("FindScratch", find_scratch, {})

vim.keymap.set(
	"n",
	"<leader>ns",
	"<cmd>NewScratch<cr>",
	{ desc = "[n]ew [s]cratch" }
)
vim.keymap.set(
	"n",
	"<leader>fs",
	"<cmd>FindScratch<cr>",
	{ desc = "[f]ind [s]cratch" }
)
