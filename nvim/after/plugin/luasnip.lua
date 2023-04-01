local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

local s = ls.s
local i = ls.insert_node

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

vim.keymap.set("i", "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)

ls.add_snippets("lua", {
	s(
		"conf",
		fmt(
			[[config = function()
	{}
end]],
			{ i(1, "-- conf") }
		)
	),
}, { key = "lua" })
