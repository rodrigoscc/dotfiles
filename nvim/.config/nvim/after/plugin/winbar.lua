local navic = require("nvim-navic")

function _G.Winbar()
	local file_icon, icon_hl =
		MiniIcons.get("file", vim.api.nvim_buf_get_name(0))

	if navic.is_available() then
		return ("%%#%s#"):format(icon_hl)
			.. file_icon
			.. "%* %#WinBar#%t >%* %{%v:lua.require'nvim-navic'.get_location()%}"
	else
		return ("%%#%s#"):format(icon_hl) .. file_icon .. "%* %#WinBar#%t%*"
	end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("rodrigoscc/winbar", { clear = true }),
	callback = function(args)
		if
			not vim.api.nvim_win_get_config(0).zindex -- not a floating window
			and vim.bo[args.buf].buftype == "" -- normal buffer
			and vim.api.nvim_buf_get_name(args.buf) ~= "" -- has a file name
			and not vim.wo[0].diff -- not in diff mode
		then
			vim.wo.winbar = "%{%v:lua.Winbar()%}"
		end
	end,
})
