return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				surrounds = {
					-- Do not add enclosing whitespace on either character
					["("] = {
						add = { "(", ")" },
					},
					["{"] = {
						add = { "{", "}" },
					},
					["["] = {
						add = { "[", "]" },
					},
					["<"] = {
						add = { "<", ">" },
					},
				},
			})
		end,
	},
}
