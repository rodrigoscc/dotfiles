local autocmd = vim.api.nvim_create_autocmd
local groupid = vim.api.nvim_create_augroup

---@param group string
---@vararg { [1]: string|string[], [2]: vim.api.keyset.create_autocmd }
---@return nil
local function augroup(group, ...)
	local id = groupid(group, {})
	for _, a in ipairs({ ... }) do
		a[2].group = id
		autocmd(unpack(a))
	end
end

augroup("Spell", {
	"FileType",
	{
		pattern = "markdown",
		callback = function()
			vim.opt_local.spell = true
		end,
	},
})

autocmd("FileType", {
	pattern = {
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"startuptime",
		"tsplayground",
		"checkhealth",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set(
			"n",
			"q",
			"<cmd>close<cr>",
			{ buffer = event.buf, silent = true }
		)
	end,
})

augroup("BigFiles", {
	"BufReadPost",
	{
		pattern = "*",
		callback = function(args)
			local file_size = vim.fn.getfsize(args.file)

			local file_too_big = file_size > 1024 * 1024

			if file_too_big then
				vim.notify("File is too big!")

				vim.cmd("syntax off")
				vim.cmd("syntax clear")
				require("rainbow-delimiters").disable(0)
				vim.cmd("NoMatchParen")
				vim.cmd("TSBufDisable highlight")
			end
		end,
	},
})
