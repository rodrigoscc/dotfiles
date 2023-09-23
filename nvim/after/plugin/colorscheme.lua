vim.g.colorscheme = "vscode"

vim.cmd([[colorscheme ]] .. vim.g.colorscheme)

if
	not string.find(vim.g.colorscheme, "tokyonight")
	and not string.find(vim.g.colorscheme, "gruvbox-material")
then
	vim.cmd([[highlight IlluminatedWordText guibg=#333333 gui=none]])
	vim.cmd([[highlight IlluminatedWordRead guibg=#333333 gui=none]])
	vim.cmd([[highlight IlluminatedWordWrite guibg=#333333 gui=none]])
end
