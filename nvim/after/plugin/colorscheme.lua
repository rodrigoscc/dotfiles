local hl = vim.api.nvim_set_hl

vim.g.colorscheme = "vscode"

vim.cmd([[colorscheme ]] .. vim.g.colorscheme)

if
	not string.find(vim.g.colorscheme, "tokyonight")
	and not string.find(vim.g.colorscheme, "gruvbox-material")
then
	hl(0, "IlluminatedWordText", { bg = "#333333", underline = false })
	hl(0, "IlluminatedWordRead", { bg = "#333333", underline = false })
	hl(0, "IlluminatedWordWrite", { bg = "#333333", underline = false })
end

if vim.g.colorscheme == "vscode" then
	local c = require("vscode.colors").get_colors()

	hl(0, "RainbowDelimiterRed", { fg = c.vscLightRed })
	hl(0, "RainbowDelimiterYellow", { fg = c.vscYellowOrange })
	hl(0, "RainbowDelimiterBlue", { fg = c.vscBlue })
	hl(0, "RainbowDelimiterOrange", { fg = c.vscOrange })
	hl(0, "RainbowDelimiterGreen", { fg = c.vscGreen })
	hl(0, "RainbowDelimiterViolet", { fg = c.vscViolet })
	hl(0, "RainbowDelimiterCyan", { fg = c.vscMediumBlue })
end
