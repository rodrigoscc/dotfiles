local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
	ui = { border = "rounded" },
	change_detection = { notify = false },
	-- None of my plugins use luarocks so disable this.
	rocks = {
		enabled = false,
	},
	performance = {
		rtp = {
			-- Stuff I don't use.
			disabled_plugins = {
				"gzip",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
