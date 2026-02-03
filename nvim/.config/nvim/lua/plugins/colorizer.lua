return {
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
			user_default_options = {
				tailwind = true,
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
