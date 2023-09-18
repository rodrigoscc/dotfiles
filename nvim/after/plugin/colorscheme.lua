vim.g.colorscheme = "gruvbox-material"

vim.cmd([[colorscheme ]] .. vim.g.colorscheme)

if
	not string.find(vim.g.colorscheme, "tokyonight")
	and not string.find(vim.g.colorscheme, "gruvbox-material")
then
	vim.cmd([[highlight IlluminatedWordText guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordRead guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordWrite guibg=#444444]])
end
