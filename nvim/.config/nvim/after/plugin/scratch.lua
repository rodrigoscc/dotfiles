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
	svelte = ".svelte",
}

local function create_scratch_with(filetype)
	local extension = filetype_extension[filetype] or ""
	local basename = "scratch." .. os.date("!%Y%m%d%H%M%S")

	local fullname = vim.g.scratch_dir .. "/" .. basename .. extension

	vim.cmd("split " .. fullname)

	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })

	return buf
end

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

			create_scratch_with(filetype)
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

local function create(content, filetype)
	vim.fn.mkdir(vim.g.scratch_dir, "p", "0o755")

	local lines = vim.split(content, "\n")

	local sql_starts = {
		DELETE = true,
		INSERT = true,
		MERGE = true,
		SELECT = true,
		UPDATE = true,
		WITH = true,
	}

	local first_word = content:match("^%s*(%a+)")
	local first_char = content:match("^%s*(.)")

	if filetype == nil then
		local is_sql = first_word and sql_starts[first_word:upper()]
		local is_json = first_char and (first_char == "{" or first_char == "[")

		if is_sql then
			filetype = "sql"
		elseif is_json then
			filetype = "json"
		else
			filetype = "text"
		end
	end

	local buf = create_scratch_with(filetype)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end

local function create_from_register(register)
	if register == nil then
		register = '"'
	end

	local content = vim.fn.getreg(register)
	if not content then
		return
	end

	create(content)
end

local function create_from_region(start_pos, end_pos, region_type, exclusive)
	local opts = { type = region_type }

	if exclusive ~= nil then
		opts.exclusive = exclusive
	end

	local lines = vim.fn.getregion(start_pos, end_pos, opts)

	create(table.concat(lines, "\n"), vim.bo.filetype)
end

function scratch_create_operator(operator_type)
	local region_types = {
		char = "v",
		line = "V",
		block = "\22",
	}

	create_from_region(
		vim.fn.getpos("'["),
		vim.fn.getpos("']"),
		region_types[operator_type],
		false
	)
end

vim.api.nvim_create_user_command("NewScratch", new_scratch, {})
vim.api.nvim_create_user_command("FindScratch", find_scratch, {})
vim.api.nvim_create_user_command("AutoNewScratch", function(opts)
	create_from_register(opts.reg)
end, { register = true })

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

vim.keymap.set("n", "gp", function()
	create_from_register(vim.v.register)
end, { desc = "auto new scratch" })

vim.keymap.set("n", "gP", function()
	create_from_register("+")
end, { desc = "auto new scratch from clipboard" })

vim.keymap.set("n", "gs", function()
	vim.go.operatorfunc = "v:lua.scratch_create_operator"
	return "g@"
end, { expr = true, desc = "create scratch from motion" })

vim.keymap.set("x", "gs", function()
	create_from_region(vim.fn.getpos("v"), vim.fn.getpos("."), vim.fn.mode())
end, { desc = "create scratch from selection" })
