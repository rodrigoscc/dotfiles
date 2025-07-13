return {
	{ "Bilal2453/luvit-meta", lazy = true }, -- `vim.uv` typings
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				{ path = "${3rd}/luassert/library", words = { "assert" } },
				{ path = "${3rd}/busted/library", words = { "describe" } },
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
			},
		},
	},
}
