return {
	{
		"max397574/better-escape.nvim",
		opts = {
			default_mappings = false,
			mappings = {
				i = {
					--  first_key[s]
					j = {
						--  second_key[s]
						k = "<Esc>",
					},
				},
				c = {
					j = {
						k = "<C-c>",
					},
				},
				t = {
					j = {
						k = "<C-\\><C-n>",
					},
				},
				s = {
					j = {
						k = "<Esc>",
					},
				},
			},
		},
	},
}
