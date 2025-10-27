return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"ts_ls",
				"rust_analyzer",
				"gopls",
				"basedpyright",
				"lua_ls",
				"bashls",
				"jsonls",
				"yamlls",
				"svelte",
				"tailwindcss",
			},
			automatic_enable = false, -- otherwise LSPs like ruff and buf_ls are enabled too
		},
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {
					ui = { border = "rounded" },
				},
			},
			"neovim/nvim-lspconfig",
		},
	},
}
