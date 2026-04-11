local navic = require("nvim-navic")

function _G.get_oil_winbar()
	local bufnr = vim.api.nvim_win_get_buf(0)

	local dir = require("oil").get_current_dir(bufnr)
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- If there is no current directory (e.g. over ssh), just show the buffer name
		return vim.api.nvim_buf_get_name(0)
	end
end

function _G.Winbar()
	local file_icon, icon_hl =
		MiniIcons.get("file", vim.api.nvim_buf_get_name(0))

	if vim.bo.filetype == "oil" then
		return ("%%#%s#"):format(icon_hl)
			.. file_icon
			.. "%* %#WinBar#%{v:lua.get_oil_winbar()}%*"
	end

	local fugitive_prefix = ""

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname:match("^fugitive://") then
		local sha = bufname:match("^fugitive://.*/(%x+)/")
		local short_sha = sha and sha:sub(1, 7) or ""

		fugitive_prefix = (
			short_sha ~= "" and (" %#Comment#@" .. short_sha .. "%*") or ""
		) .. " "
	end

	if navic.is_available() then
		return fugitive_prefix
			.. ("%%#%s#"):format(icon_hl)
			.. file_icon
			.. "%* %#WinBar#%t%* %{%v:lua.require'nvim-navic'.get_location()%}"
	else
		return fugitive_prefix
			.. ("%%#%s#"):format(icon_hl)
			.. file_icon
			.. "%* %#WinBar#%t%*"
	end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("rodrigoscc/winbar", { clear = true }),
	callback = function(args)
		if
			not vim.api.nvim_win_get_config(0).zindex -- not a floating window
			and vim.bo[args.buf].buftype ~= "nowrite"
			and vim.bo[args.buf].buftype ~= "nofile"
			and vim.api.nvim_buf_get_name(args.buf) ~= "" -- has a file name
			and not vim.wo[0].diff -- not in diff mode
		then
			vim.wo.winbar = "%{%v:lua.Winbar()%}"
		end
	end,
})
