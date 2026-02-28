return {
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
			options = {
				parsers = {
					css = true, -- preset: enables names, hex, rgb, hsl, oklch
					tailwind = { enable = true },
				},
			},
			filetypes = {
				-- Do not want blink buffers to have colorizer on.
				"html",
				"css",
				"svelte",
				"javascriptreact",
				"typescriptreact",
				"vue",
			},
		},
		keys = {
			{
				"<leader>tc",
				"<cmd>ColorizerToggle<cr>",
				desc = "toggle colorizer",
			},
		},
	},
}
