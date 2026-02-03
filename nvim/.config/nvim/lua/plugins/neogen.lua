return {
	{
		"danymat/neogen",
		lazy = true,
		keys = {
			{
				"<leader>id",
				"<cmd>Neogen<cr>",
				desc = "insert documentation",
			},
		},
		opts = {
			snippet_engine = "luasnip",
			languages = {
				python = {
					template = {
						annotation_convention = "reST",
					},
				},
			},
		},
	},
}
