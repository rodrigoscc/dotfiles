return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					normal = "gs",
					normal_cur = "gss",
					normal_line = "gS",
					normal_cur_line = "ySS",
					insert = "<C-g>s",
					insert_line = "<C-g>S",
					visual = "gs", -- Remapping visual mode mapping to avoid conflicts with flash.nvim mappings.
					visual_line = "gS", -- Remapping visual mode mapping to avoid conflicts with flash.nvim mappings.
				},
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
