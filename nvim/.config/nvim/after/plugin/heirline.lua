local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local text = "#e0def4"
local subtle = "#908caa"
local muted = "#6e6a86"
local overlay = "#26233a"
local surface = "#1f1d2e"
local base = "#191724"
local iris = "#c4a7e7"
local purple = "#c678dd"
local gold = "#f6c177"
local pine = "#31748f"
local love = "#eb6f92"
local rose = "#ebbcba"
local foam = "#9ccfd8"

local safe_get_highlight = function(...)
	for _, hlname in ipairs({ ... }) do
		if vim.fn.hlexists(hlname) == 1 then
			local id = vim.fn.synIDtrans(vim.api.nvim_get_hl_id_by_name(hlname))

			local foreground = vim.fn.synIDattr(id, "fg")

			local background = vim.fn.synIDattr(id, "bg")

			if vim.fn.synIDattr(id, "reverse") == "1" then
				foreground, background = background, foreground
			end

			if foreground and foreground:find("^#") then
				return { foreground = foreground, background = background }
			end
		end
	end

	return { foreground = "#000000", background = "#000000" }
end

local colors = {
	normal = safe_get_highlight("Normal").foreground,
	insert = safe_get_highlight("Insert", "String", "MoreMsg").foreground,
	replace = safe_get_highlight("Replace", "Number", "Type").foreground,
	visual = safe_get_highlight("Visual", "Boolean", "Constant").foreground,
	command = safe_get_highlight("Error", "Identifier", "Normal").foreground,

	background = safe_get_highlight("StatusLine").background,

	dim = safe_get_highlight("StatusLineNC", "Comment").foreground,
	purple = purple,
	iris = iris,
	gold = gold,
	love = love,
	pine = pine,
	rose = rose,
	foam = foam,
	text = text,
	subtle = subtle,
	muted = muted,
	overlay = overlay,
	surface = surface,
	base = base,

	diag = {
		warn = safe_get_highlight("DiagnosticWarn").foreground,
		error = safe_get_highlight("DiagnosticError").foreground,
		hint = safe_get_highlight("DiagnosticHint").foreground,
		info = safe_get_highlight("DiagnosticInfo").foreground,
	},
	git = {
		del = safe_get_highlight(
			"diffRemoved",
			"DiffRemoved",
			"DiffDelete",
			"SignDelete"
		).foreground,
		add = safe_get_highlight(
			"diffAdded",
			"DiffAdded",
			"DiffAdd",
			"SignAdd"
		).foreground,
		change = safe_get_highlight(
			"diffChanged",
			"DiffChange",
			"DiffChange",
			"SignChange"
		).foreground,
	},
}

local ViMode = {
	-- get vim current mode, this information will be required by the provider
	-- and the highlight functions, so we compute it only once per component
	-- evaluation and store it as a component attribute
	init = function(self)
		self.mode = vim.fn.mode(1) -- :h mode()

		self.mode_name = self.mode_names[self.mode]
		if self.mode_name == nil then
			self.mode_name = ""
		end
	end,
	-- Now we define some dictionaries to map the output of mode() to the
	-- corresponding string and color. We can put these into `static` to compute
	-- them at initialisation time.
	static = {
		mode_colors = {
			n = "#98be65",
			i = colors.insert,
			v = colors.visual,
			V = colors.visual,
			["\22"] = colors.visual,
			c = colors.command,
			s = colors.purple,
			S = colors.purple,
			["\19"] = colors.purple,
			R = colors.replace,
			r = colors.replace,
			["!"] = colors.love,
			t = colors.love,
		},
		mode_names = {
			n = "NORMAL",
			i = "INSERT",
			v = "VISUAL",
			[""] = "VISUAL",
			V = "V-LINE",
			c = "COMMAND",
			s = "SELECT",
			S = "S-LINE",
			[""] = "S-LINE",
			ic = "INSERT",
			R = "REPLACE",
			Rv = "V-REPLACE",
			cv = "COMMAND",
			ce = "COMMAND",
			r = "REPLACE",
			rm = "MORE",
			["r?"] = "CONFIRM",
			["!"] = "SHELL",
			t = "TERMINAL",
			nt = "NTERMINAL",
		},
	},
	-- Same goes for the highlight. Now the foreground will change according to the current mode.
	hl = function(self)
		local mode = self.mode:sub(1, 1) -- get only the first mode character
		return { fg = self.mode_colors[mode], bold = true }
	end,
	flexible = 2,
	{
		provider = function(self)
			return "  " .. self.mode_name .. " "
		end,
	},
	{
		provider = function(self)
			return "  "
		end,
	},
}

--[[
  --  FILE BLOCK
  --]]
local FileBlock = {
	init = function(self)
		self.filename = vim.api.nvim_buf_get_name(0)
		self.filepath = vim.fn.expand("%:p")
	end,
}

local FileSecondaryBlock = {
	init = function(self)
		self.filename = vim.api.nvim_buf_get_name(0)
		self.filepath = vim.fn.expand("%:p")
	end,
}

local FileSize = {
	provider = function(self)
		-- Return early if no file size
		local fsize = vim.fn.getfsize(self.filepath)
		if fsize <= 0 then
			return ""
		end

		local suffix = { "b", "k", "M", "G", "T", "P", "E" }
		local i = 1
		while fsize > 1024 do
			fsize = fsize / 1024
			i = i + 1
		end
		return string.format(" %.1f%s ", fsize, suffix[i])
	end,
	hl = { fg = colors.dim },
}

local FileIcon = {
	init = function(self)
		local icon, hl, is_default =
			require("mini.icons").get("file", self.filename)
		if not is_default then
			self.icon = icon
			self.icon_hl = hl
			return
		end

		self.icon, self.icon_hl =
			require("mini.icons").get("filetype", vim.bo.filetype)
	end,
	provider = function(self)
		return self.icon and (self.icon .. " ")
	end,
	hl = function(self)
		return self.icon_hl
	end,
}

local FileName = {
	init = function(self)
		self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
		if self.lfilename == "" then
			self.lfilename = "[No Name]"
		end
	end,
	hl = { fg = colors.iris },
	flexible = 2,
	{
		provider = function(self)
			return self.lfilename .. " "
		end,
	},
	{
		provider = function(self)
			return vim.fn.pathshorten(self.lfilename) .. " "
		end,
	},
}

local FileFlags = {
	{
		provider = function()
			if vim.bo.modified then
				return "[+] "
			end
		end,
		hl = { fg = colors.love },
	},
	{
		provider = function()
			if not vim.bo.modifiable or vim.bo.readonly then
				return "[-] "
			end
		end,
		hl = { fg = colors.purple },
	},
}

local FileNameModifer = {
	hl = function()
		if vim.bo.modified then
			-- use `force` because we need to override the child's hl foreground
			return { fg = colors.cyan, bold = true, force = true }
		end
	end,
}

local FilePosition = {
	provider = " %3l:%-2c",
	hl = { fg = colors.dim },
}

-- let's add the children to our FileBlock component
FileBlock = utils.insert(
	FileBlock,
	FileIcon,
	utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
	unpack(FileFlags) -- A small optimisation, since their parent does nothing
)

FilePosition = utils.insert(FileSecondaryBlock, FilePosition)
FileSize = utils.insert(FileSecondaryBlock, FileSize)

local SearchCount = {
	condition = function()
		return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
	end,
	init = function(self)
		local ok, search = pcall(vim.fn.searchcount)
		if ok and search.total then
			self.search = search
		end
	end,
	-- current match
	{
		provider = function(self)
			if self.search then
				return " " .. tostring(self.search.current)
			end
		end,
		hl = { fg = colors.text, bold = true },
	},
	-- separator + total
	{
		provider = function(self)
			if self.search then
				local total = self.search.total
				local maxcount = self.search.maxcount
				local suffix = total > maxcount and "+" or ""
				return "/" .. math.min(total, maxcount) .. suffix
			end
		end,
		hl = { fg = colors.dim },
	},
}

local DapElement = {
	condition = function()
		local ok, dap = pcall(require, "dap")
		if not ok then
			return false
		end

		return dap.session() ~= nil
	end,
	init = function(self)
		local dap = require("dap")
		self.session = dap.session()

		self.name = ""
		self.adapter_type = ""

		if self.session and self.session.config then
			self.name = self.session.config.name or ""
			self.adapter_type = self.session.config.type or ""
		end

		self.is_stopped = self.session and self.session.stopped_thread_id ~= nil

		self.func_name = nil
		if self.is_stopped and self.session.current_frame then
			self.func_name = self.session.current_frame.name
		end
	end,
	-- NOTE: intentionally no `update` field here. Heirline's per-window cache
	-- (`_freeze_cache`) can re-freeze stale state before a scheduled redraw
	-- runs, causing the component to get stuck. Without `update`, heirline
	-- evaluates fresh on every redraw, and the autocmd below ensures redraws
	-- happen when DAP state changes.
	-- State-aware icon: paused vs running
	{
		provider = function(self)
			return self.is_stopped and "  " or "  "
		end,
		hl = function(self)
			if self.is_stopped then
				return { fg = colors.gold, bold = true }
			else
				return { fg = colors.love, bold = true }
			end
		end,
	},
	-- Adapter type badge
	utils.surround({ "[", "]" }, nil, {
		{
			provider = function(self)
				if self.adapter_type ~= "" then
					return self.adapter_type
				else
					return "DAP"
				end
			end,
			hl = { fg = colors.iris, bold = true },
		},
	}),
	-- Session config name
	{
		provider = function(self)
			if self.name ~= "" then
				return (" " .. self.name)
			else
				return ""
			end
		end,
		hl = { fg = colors.foam },
	},
	-- Current function name when stopped
	{
		provider = function(self)
			if self.func_name then
				return (" @ " .. self.func_name)
			else
				return ""
			end
		end,
		hl = { fg = colors.subtle },
	},
}

vim.api.nvim_create_autocmd("User", {
	pattern = {
		"DapSessionAttached",
		"DapSessionLaunched",
		"DapSessionTerminated",
		"DapSessionExited",
		"DapStopped",
		"DapContinued",
	},
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

local VisualRange = {
	condition = function()
		local mode = vim.fn.mode()
		return mode == "v" or mode == "V" or mode == "\22"
	end,
	update = { "CursorMoved", "ModeChanged" },
	-- icon
	{
		provider = " 󰒅 ",
		hl = { fg = colors.visual, bold = true },
	},
	-- line count
	{
		provider = function()
			local start_line = vim.fn.line("v")
			local end_line = vim.fn.line(".")
			return math.abs(end_line - start_line) + 1 .. "L"
		end,
		hl = { fg = colors.iris, bold = true },
	},
	-- character count
	{
		provider = function()
			local chars = (vim.fn.wordcount()).visual_chars or 0
			return " " .. chars .. "C"
		end,
		hl = { fg = colors.foam },
	},
	-- word count (only when meaningful)
	{
		provider = function()
			local words = (vim.fn.wordcount()).visual_words or 0
			if words > 1 then
				return " " .. words .. "W"
			end
			return ""
		end,
		hl = { fg = colors.gold },
	},
}

local MacroRec = {
	condition = function()
		return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
	end,
	provider = " ",
	hl = { fg = colors.gold, bold = true },
	utils.surround({ "[", "]" }, nil, {
		provider = function()
			return vim.fn.reg_recording()
		end,
		hl = { fg = colors.iris, bold = true },
	}),
	update = {
		"RecordingEnter",
		"RecordingLeave",
	},
}

local function shorten_path(path)
	local splits = vim.split(path, "/")

	for i, split in ipairs(splits) do
		if i ~= #splits then
			splits[i] = split:sub(1, 1)
		end
	end

	return table.concat(splits, "/")
end

local function prepare_paths(paths)
	local shortened_paths = {}

	for i, path in ipairs(paths) do
		local buffer_name = vim.fn.expand("%")
		local relative_buffer_name = vim.fs.relpath(vim.uv.cwd(), buffer_name)

		local is_this_buffer = path == relative_buffer_name
		if not is_this_buffer then
			table.insert(shortened_paths, { i, shorten_path(path) })
		end
	end

	return shortened_paths
end

local TogglesElement = {
	static = {
		toggles = {
			{
				is_enabled = function()
					return vim.wo.wrap
				end,
				icon = "󰖶 ",
			},
			{
				is_enabled = function()
					return vim.b[0].disable_autoformat
				end,
				icon = "󰉥 ",
			},
		},
	},
	condition = function(self)
		for _, value in ipairs(self.toggles) do
			if value.is_enabled() then
				return true
			end
		end

		return false
	end,
	provider = function()
		return " 󰨙 "
	end,
	hl = { fg = colors.gold, bold = true },
	utils.surround({ "[", "] " }, nil, {
		provider = function(self)
			local toggles = ""

			for _, value in ipairs(self.toggles) do
				if value.is_enabled() then
					toggles = toggles .. " " .. value.icon
				end
			end

			return toggles
		end,
		hl = { fg = colors.iris, bold = true },
	}),
}

local HarpoonElement = {
	static = {
		icons = {
			"󰲠",
			"󰲢",
			"󰲤",
			"󰲦",
			"󰲨",
		},
	},
	provider = function(self)
		local harpoon = require("harpoon")
		local harpoon_items = harpoon:list().items

		local files_names = vim.tbl_map(function(item)
			return item.value
		end, harpoon_items)

		local items = prepare_paths(files_names)

		local text = ""

		for _, item in ipairs(items) do
			local position, filename = unpack(item)

			text = text
				.. string.format("%s %s", self.icons[position], filename)
				.. " "
		end

		return text
	end,
	hl = { fg = colors.iris },
}

local FileTypeElement = {
	provider = function()
		return string.format(" %s ", vim.bo.filetype)
	end,
	hl = { fg = colors.dim },
}

local LSPElement = {
	condition = conditions.lsp_attached,
	provider = function()
		local names = {}

		local servers = vim.lsp.get_clients({ bufnr = 0 })
		for _, server in ipairs(servers) do
			table.insert(names, server.name)
		end

		return (" [%s] "):format(table.concat(names, " "))
	end,
	hl = { fg = colors.foam },
}

local FileEncoding = {
	hl = { fg = colors.dim },
	provider = function()
		local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
		return enc:upper() .. " "
	end,
}

local Diagnostics = {
	static = {
		error_icon = " ",
		warn_icon = " ",
		info_icon = " ",
		hint_icon = " ",
	},

	condition = conditions.has_diagnostics,

	init = function(self)
		self.errors =
			#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings =
			#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints =
			#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info =
			#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,

	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self)
			-- 0 is just another output, we can decide to print it or not!
			return self.errors > 0 and (self.error_icon .. self.errors .. " ")
		end,
		hl = { fg = colors.diag.error },
	},
	{
		provider = function(self)
			return self.warnings > 0
				and (self.warn_icon .. self.warnings .. " ")
		end,
		hl = { fg = colors.diag.warn },
	},
	{
		provider = function(self)
			return self.info > 0 and (self.info_icon .. self.info .. " ")
		end,
		hl = { fg = colors.diag.info },
	},
	{
		provider = function(self)
			return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
		end,
		hl = { fg = colors.diag.hint },
	},
}

local GitBlock = {
	condition = function()
		local is_git_repo = conditions.is_git_repo()
		local has_status_dict = vim.b.gitsigns_status_dict ~= nil
		return is_git_repo and has_status_dict
	end,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
	end,
	{
		{
			hl = { fg = colors.git.add },
			provider = function(self)
				local count = self.status_dict.added or 0
				return count > 0 and ("  " .. count)
			end,
		},
		-- Changed component
		{
			hl = { fg = colors.git.change },
			provider = function(self)
				local count = self.status_dict.changed or 0
				return count > 0 and ("  " .. count)
			end,
		},
		-- Deleted component
		{
			hl = { fg = colors.git.del },
			provider = function(self)
				local count = self.status_dict.removed or 0
				return count > 0 and ("  " .. count .. " ")
			end,
		},
	},
	{ provider = " " },
}

local GitBranchBlock = {
	condition = function()
		return conditions.is_git_repo()
	end,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
	end,
	{
		{
			hl = { fg = colors.gold },
			provider = function()
				return " "
			end,
		},
		{
			hl = { fg = colors.foam },
			provider = function(self)
				return self.status_dict.head
			end,
		},
	},
}

local Ruler = {
	{
		static = {
			sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
		},
		provider = function(self)
			local curr_line = vim.api.nvim_win_get_cursor(0)[1]
			local lines = vim.api.nvim_buf_line_count(0)
			local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
			return string.rep(self.sbar[i], 1)
		end,
		hl = { fg = colors.insert, bg = colors.dim },
	},
}

local Nurl = {
	{
		provider = function()
			local has_nurl, nurl = pcall(require, "nurl")
			if not has_nurl then
				return ""
			end

			local env = nurl.env.project_active_env
			if env ~= nil then
				return "[ " .. env .. "] "
			end

			return ""
		end,
		hl = { fg = colors.iris },
	},
}

local statusline = {
	hl = function()
		local dap = require("dap")
		local session = dap.session()

		if session == nil then
			return { bg = colors.background }
		end

		return { bg = colors.overlay }
	end,
	{ ViMode },
	{ FileBlock },
	{ GitBranchBlock },
	{ FilePosition },
	{ SearchCount },
	{ VisualRange },
	{ DapElement },
	{ provider = "%<" },
	{ MacroRec },
	{ TogglesElement },
	{ provider = " %= " },
	{ Nurl },
	{ HarpoonElement },
	{ FileSize },
	{ FileEncoding },
	{ FileTypeElement },
	{ LSPElement },
	{ Diagnostics },
	{ GitBlock },
	{ Ruler },
}

local Tabpage = {
	init = function(self)
		local winid = vim.api.nvim_tabpage_get_win(self.tabpage)
		local bufnr = vim.api.nvim_win_get_buf(winid)
		local filename = vim.api.nvim_buf_get_name(bufnr)

		self.bufnr = bufnr
		self.basename = vim.fn.fnamemodify(filename, ":t")

		local ft = vim.bo[bufnr].filetype

		self.icon = nil
		self.icon_hl = nil

		if ft == "fugitive" then
			local icon, icon_hl = MiniIcons.get("filetype", "git")
			self.icon = icon
			self.icon_hl = icon_hl

			self.basename = "Git Status"
		elseif ft == "git" or filename:match("^fugitive://") then
			local label = vim.fn.fnamemodify(filename, ":t")
			if label == "" then
				label = "Git"
			end

			self.basename = label
		elseif self.basename ~= "" then
			local icon, icon_hl, is_default =
				MiniIcons.get("file", vim.api.nvim_buf_get_name(0))

			if not is_default then
				self.icon = icon
				self.icon_hl = icon_hl
			else
				self.icon, self.icon_hl = MiniIcons.get("filetype", ft)
			end
		else
			self.basename = "[No Name]"
		end
	end,
	hl = function(self)
		if self.is_active then
			return { bg = colors.surface }
		else
			return "TabLine"
		end
	end,
	-- Click region start
	{
		provider = function(self)
			return "%" .. self.tabnr .. "T"
		end,
	},
	{ provider = " " },
	-- Tab number
	{
		provider = function(self)
			return self.tabnr .. " "
		end,
		hl = function(self)
			if self.is_active then
				return { fg = colors.gold, bold = true }
			else
				return { fg = colors.muted }
			end
		end,
	},
	-- File icon
	{
		provider = function(self)
			return self.icon and (self.icon .. " ") or ""
		end,
		hl = function(self)
			if self.is_active then
				return self.icon_hl
			else
				return { fg = colors.muted }
			end
		end,
	},
	-- File name
	{
		provider = function(self)
			return self.basename
		end,
		hl = function(self)
			if self.is_active then
				return { fg = colors.text, bold = true }
			else
				return { fg = colors.subtle }
			end
		end,
	},
	{ provider = " " },
	-- Click region end
	{
		provider = "%T",
	},
}

local tabline = utils.make_tablist(Tabpage)

-- Set global statusline
vim.o.laststatus = 3
-- Hide command line
vim.o.cmdheight = 0

require("heirline").setup({ statusline = statusline, tabline = tabline })
