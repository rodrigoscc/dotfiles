vim.g.colorscheme = "tokyonight-night"

vim.cmd([[colorscheme ]] .. vim.g.colorscheme)

if not string.find(vim.g.colorscheme, "tokyonight") then
	vim.cmd([[highlight IlluminatedWordText guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordRead guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordWrite guibg=#444444]])
end
