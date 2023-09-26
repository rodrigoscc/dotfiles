local hl = vim.api.nvim_set_hl

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

if vim.g.colorscheme == "vscode" then
	local c = require("vscode.colors").get_colors()

	hl(0, "RainbowDelimiterRed", { fg = c.vscLightRed })
	hl(0, "RainbowDelimiterYellow", { fg = c.vscYellowOrange })
	hl(0, "RainbowDelimiterBlue", { fg = c.vscDarkBlue })
	hl(0, "RainbowDelimiterOrange", { fg = c.vscOrange })
	hl(0, "RainbowDelimiterGreen", { fg = c.vscBlueGreen })
	hl(0, "RainbowDelimiterViolet", { fg = c.vscViolet })
	hl(0, "RainbowDelimiterCyan", { fg = c.vscMediumBlue })
end
