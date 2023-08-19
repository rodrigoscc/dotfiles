vim.g.colorscheme = "tokyonight-night"

vim.cmd([[colorscheme ]] .. vim.o.colorcolumn)

if vim.g.colorscheme ~= "tokyonight-night" then
	vim.cmd([[highlight IlluminatedWordText gui=bold]])
	vim.cmd([[highlight IlluminatedWordRead gui=bold]])
	vim.cmd([[highlight IlluminatedWordWrite gui=bold]])

	vim.cmd([[highlight IlluminatedWordText guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordRead guibg=#444444]])
	vim.cmd([[highlight IlluminatedWordWrite guibg=#444444]])
end
