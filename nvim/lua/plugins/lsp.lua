return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		dependencies = {
			-- LSP Support
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"gh-liu/cmp-omni", -- original hrsh7th/cmp-omni does not work

			-- Snippets
			"L3MON4D3/LuaSnip", -- Required
		},
	},
	{ "williamboman/mason.nvim" },
	{ "onsails/lspkind.nvim" },
	{
		"hedyhli/outline.nvim",
		opts = {
			keymaps = {
				close = { "q" }, -- Do not want Escape to close the outline.
			},
		},
	},
	{ "folke/neodev.nvim", opts = {} },
}
