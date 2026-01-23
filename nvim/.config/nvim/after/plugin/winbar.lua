local navic = require("nvim-navic")

function _G.Winbar()
	local file_icon, icon_hl =
		MiniIcons.get("file", vim.api.nvim_buf_get_name(0))

	if navic.is_available() then
		return ("%%#%s#"):format(icon_hl)
			.. file_icon
			.. "%* %t > %{%v:lua.require'nvim-navic'.get_location()%}"
	else
		return ("%%#%s#"):format(icon_hl) .. file_icon .. "%* %t"
	end
end

vim.o.winbar = "%{%v:lua.Winbar()%}"
