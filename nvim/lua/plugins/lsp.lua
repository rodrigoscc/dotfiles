return {
	{
		"kndndrj/nvim-dbee",
		lazy = true,
		cmd = { "DBUIToggle", "DBUI" },
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			-- Install tries to automatically detect the install method.
			-- if it fails, try calling it with one of these parameters:
			--    "curl", "wget", "bitsadmin", "go"
			require("dbee").install()
		end,
		config = function()
			require("dbee").setup(--[[optional config]])
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
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

			"lukas-reineke/cmp-rg",
		},
	},
	{ "williamboman/mason.nvim" },
	{ "onsails/lspkind.nvim" },
	{
		"hedyhli/outline.nvim",
		lazy = true,
		keys = {
			{ "<leader>ty", vim.cmd.Outline, desc = "Toggle Outline" },
			{ "<leader>fy", vim.cmd.OutlineFocus, desc = "Focus Outline" },
		},
		opts = {
			keymaps = {
				close = { "q" }, -- Do not want Escape to close the outline.
			},
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				"plenary.nvim/lua/plenary",
				"luvit-meta/library",
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- `vim.uv` typings
	{
		"rstcruzo/cmp-dbee", -- original cmp-dbee does not work
		dependencies = {
			{ "kndndrj/nvim-dbee" },
		},
		ft = "sql", -- optional but good to have
		opts = {},
	},
}
