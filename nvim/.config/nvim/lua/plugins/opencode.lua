return {
	{
		"NickvanDyke/opencode.nvim",
		keys = {
			{
				"<leader>a",
				function()
					require("opencode").ask("@this: ", { submit = true })
				end,
				desc = "Ask opencode",
			},
			{
				"<leader>A",
				function()
					require("opencode").select()
				end,
				desc = "Execute opencode action…",
			},
			{
				"<C-]>",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle opencode",
			},
			{
				"go",
				function()
					return require("opencode").operator("@this ")
				end,
				expr = true,
				desc = "Add range to opencode",
			},
			{
				"goo",
				function()
					return require("opencode").operator("@this ") .. "_"
				end,
				expr = true,
				desc = "Add line to opencode",
			},
		},
		dependencies = {
			-- Recommended for `ask()` and `select()`.
			-- Required for `snacks` provider.
			---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
			{
				"folke/snacks.nvim",
				opts = { input = {}, picker = {}, terminal = {} },
			},
		},
		config = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {}

			-- Required for `opts.events.reload`.
			vim.o.autoread = true
		end,
	},
}
