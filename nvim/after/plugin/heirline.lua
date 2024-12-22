-- vim: tabstop=4
local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local special2, special, special3 = "#a9a1e1", "#c678dd", "#ecbe7b"

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
	visual = safe_get_highlight("Visual", "Special", "Boolean", "Constant").foreground,
	command = safe_get_highlight("Command", "Identifier", "Normal").foreground,

	background = safe_get_highlight("StatusLine").background,
	base = safe_get_highlight("StatusLine").foreground,
	dim = safe_get_highlight("StatusLineNC", "Comment").foreground,
	special = special,
	special2 = special2,
	special3 = special3,

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
			["!"] = colors.red,
			t = colors.red,
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
		},
	},
	provider = function(self)
		local mode_name = self.mode_names[self.mode]
		if mode_name == nil then
			mode_name = ""
		end

		return "  " .. mode_name .. " "
	end,
	-- Same goes for the highlight. Now the foreground will change according to the current mode.
	hl = function(self)
		local mode = self.mode:sub(1, 1) -- get only the first mode character
		return { fg = self.mode_colors[mode], bold = true }
	end,
}

--[[
  --  FILE BLOCK
  --]]
local FileBlock = {
	init = function(self)
		self.filename = vim.fn.expand("%:t")
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
		local filename = self.filename
		local extension = vim.fn.fnamemodify(filename, ":e")
		self.icon, self.icon_color =
			require("nvim-web-devicons").get_icon_color(
				filename,
				extension,
				{ default = true }
			)
	end,
	provider = function(self)
		return self.icon and (self.icon .. " ")
	end,
	hl = function(self)
		return { fg = self.icon_color }
	end,
}

local FileName = {
	provider = function(self)
		-- first, trim the pattern relative to the current directory. For other
		-- options, see :h filename-modifers
		local filename = vim.fn.fnamemodify(self.filename, ":.")
		if filename == "" then
			return "[No Name] "
		end
		-- now, if the filename would occupy more than 1/4th of the available
		-- space, we trim the file path to its initials
		-- See Flexible Components section below for dynamic truncation
		filename = vim.fn.pathshorten(filename)
		return filename .. " "
	end,
	hl = { fg = colors.special },
}

local FileFlags = {
	{
		provider = function()
			if vim.bo.modified then
				return " "
			end
		end,
		hl = { fg = colors.green },
	},
	{
		provider = function()
			if not vim.bo.modifiable or vim.bo.readonly then
				return " "
			end
		end,
		hl = { fg = colors.orange },
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
	provider = " %3l:%-2c ",
	hl = { fg = colors.dim },
}

-- let's add the children to our FileBlock component
FileBlock = utils.insert(
	FileBlock,
	FileIcon,
	utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
	FileSize,
	unpack(FileFlags), -- A small optimisation, since their parent does nothing
	FilePosition
)

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
	provider = function(self)
		local search = self.search
		return string.format(
			"[%d/%d]",
			search.current,
			math.min(search.total, search.maxcount)
		)
	end,
	hl = { fg = colors.special2 },
}

local MacroRec = {
	condition = function()
		return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
	end,
	provider = " ",
	hl = { fg = colors.special3, bold = true },
	utils.surround({ "[", "]" }, nil, {
		provider = function()
			return vim.fn.reg_recording()
		end,
		hl = { fg = colors.special2, bold = true },
	}),
	update = {
		"RecordingEnter",
		"RecordingLeave",
	},
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
		local servers = vim.lsp.get_clients()
		return (" %s "):format(#servers)
	end,

	on_click = {
		callback = function()
			vim.cmd("LspInfo")
		end,
		name = "lspconfig",
	},
	hl = { fg = colors.dim },
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
			return self.hints > 0 and (self.hint_icon .. self.hints)
		end,
		hl = { fg = colors.diag.hint },
	},
}

--[[
  --  GIT BLOCK
  --]]
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
			hl = { fg = colors.special2 },
			provider = function()
				return " "
			end,
		},
		{
			hl = { fg = colors.special2 },
			provider = function(self)
				return self.status_dict.head
			end,
		},
	},

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

local heirline_config = {
	hl = { bg = colors.background },
	{ ViMode },
	{ FileBlock },
	{ FileEncoding },
	{ SearchCount },
	{ MacroRec },
	{ provider = " %= " },
	-- { MasonStatusElement },
	{ FileTypeElement },
	{ LSPElement },
	{ Diagnostics },
	{ GitBlock },
	{ Ruler },
}

-- Set global statusline
vim.o.laststatus = 3
-- Hide command line
vim.o.cmdheight = 0

require("heirline").setup({ statusline = heirline_config })
