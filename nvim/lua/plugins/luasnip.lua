return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		lazy = true,
		event = "InsertEnter",
		config = function()
			local ls = require("luasnip")
			local loaders = require("luasnip.loaders")

			ls.setup({
				enable_autosnippets = true,
				update_events = { "TextChanged", "TextChangedI" },
			})

			local load = require("luasnip.loaders.from_lua").load

			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true, desc = "expand or jump snippet" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true, desc = "jump snippet backwards" })

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { desc = "next snippet choice" })

			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				if ls.choice_active() then
					ls.change_choice(-1)
				end
			end, { desc = "previous snippet choice" })

			vim.keymap.set(
				"n",
				"<leader>es",
				loaders.edit_snippet_files,
				{ desc = "[e]dit [s]nippets" }
			)

			load({ paths = "./snippets" })
		end,
	},
}
