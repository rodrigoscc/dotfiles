vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes:2"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.showmode = false

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Not setting this since virt-column handles this.
-- vim.opt.colorcolumn = "80"

vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Do not show the tilde on the end of the file.
vim.opt.fillchars:append({ eob = " " })
-- Do not show the dashes when diffing files.
vim.opt.fillchars:append({ diff = " " })

vim.opt.listchars = { space = "⋅", eol = "↴", tab = "»⋅" }

-- Make sure requirements.txt are correctly highlighted.
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "requirements.txt",
	callback = function(ev)
		vim.cmd([[setfiletype requirements]])
	end,
})

-- Avoid neovim to create maps in python mode (e.g. [[ and ]]).
vim.g.no_python_maps = true

vim.treesitter.language.register("requirements", "requirements")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	callback = function()
		vim.bo.formatprg = "jq"
		vim.bo.formatexpr = ""
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt.conceallevel = 2
	end,
})

-- From vim defaults.vim
-- ---
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler
-- (happens when dropping a file on gvim) and for a commit message (it's
-- likely a different one than last time).
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local valid_line = vim.fn.line([['"]]) >= 1
			and vim.fn.line([['"]]) < vim.fn.line("$")
		local not_commit = vim.b[args.buf].filetype ~= "commit"

		if valid_line and not_commit then
			vim.cmd([[normal! g`"zz]])
		end
	end,
})
