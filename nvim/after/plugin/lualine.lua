-- Eviline config for lualine
local lualine = require("lualine")

-- Color table for highlights
local colors = {
	bg = "#202328",
	fg = "#bbc2cf",
	yellow = "#ECBE7B",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98be65",
	orange = "#FF8800",
	violet = "#a9a1e1",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ec5f67",
}

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}

local config = {
	options = {
		-- Disable sections and component separators
		component_separators = "",
		section_separators = "",
		theme = "tokyonight",
		globalstatus = true,
	},
	sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		-- These will be filled later
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
}

local function format_on_save()
	if not vim.g.format_on_save then
		return "󰉥"
	end
	return ""
end

local function wrap()
	if vim.wo.wrap then
		return "󰖶"
	end

	return ""
end

local function list_chars()
	if vim.o.list then
		return "󱇇"
	end

	return ""
end

-- Inserts a component in lualine_c at left section
local function ins_left(component)
	table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
	table.insert(config.sections.lualine_x, component)
end

local function mode_color()
	-- auto change color according to neovims mode
	local mode_color = {
		n = colors.green,
		i = colors.red,
		v = colors.blue,
		[""] = colors.blue,
		V = colors.blue,
		c = colors.magenta,
		no = colors.red,
		s = colors.orange,
		S = colors.orange,
		[""] = colors.orange,
		ic = colors.yellow,
		R = colors.violet,
		Rv = colors.violet,
		cv = colors.red,
		ce = colors.red,
		r = colors.cyan,
		rm = colors.cyan,
		["r?"] = colors.cyan,
		["!"] = colors.red,
		t = colors.red,
	}
	return { fg = mode_color[vim.fn.mode()], gui = "bold" }
end

ins_left({ "mode", icon = "", color = mode_color })

ins_left({
	"branch",
	icon = "",
	color = { fg = colors.violet },
})

ins_left({
	"filename",
	file_status = true,
	newfile_status = true,
	color = { fg = colors.violet },
})

ins_left({
	"filesize",
	cond = conditions.buffer_not_empty,
})

ins_left({ "location" })

ins_left({ "progress" })

ins_left({
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = { error = " ", info = " ", warn = " ", hint = " " },
	diagnostics_color = {
		error = { fg = colors.red },
		warn = { fg = colors.orange },
		info = { fg = colors.blue },
	},
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left({
	function()
		return "%="
	end,
})

local function http_project_env()
	local env = GetProjectEnv()
	if env == nil then
		return ""
	end

	return "[ " .. env .. "]"
end

ins_right({ http_project_env, color = { fg = colors.magenta } })

ins_right({ format_on_save })

ins_right({ wrap })

ins_right({ list_chars })

ins_right({ "filetype", colored = true })

-- Add components to right sections
ins_right({
	"o:encoding", -- option component same as &encoding in viml
	fmt = string.upper, -- I'm not sure why it's upper case either ;)
	cond = conditions.hide_in_width,
	color = { fg = colors.green, gui = "bold" },
})

ins_right({
	"fileformat",
	fmt = string.upper,
	icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
	color = { fg = colors.green, gui = "bold" },
})

ins_right({
	"diff",
	-- Is it me or the symbol for modified us really weird
	symbols = { added = " ", modified = " ", removed = " " },
	diff_color = {
		added = { fg = colors.green },
		modified = { fg = colors.orange },
		removed = { fg = colors.red },
	},
	cond = conditions.hide_in_width,
})

-- Now don't forget to initialize lualine
lualine.setup(config)
