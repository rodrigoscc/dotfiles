return {
	{
		"danymat/neogen",
		lazy = true,
		keys = {
			{
				"<leader>id",
				"<cmd>Neogen<cr>",
				desc = "[i]nsert [d]ocumentation",
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
