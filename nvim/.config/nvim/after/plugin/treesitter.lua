vim.keymap.set({ "x", "o" }, "aa", function()
	require("nvim-treesitter-textobjects.select").select_textobject(
		"@parameter.outer",
		"textobjects"
	)
end)
vim.keymap.set({ "x", "o" }, "ia", function()
	require("nvim-treesitter-textobjects.select").select_textobject(
		"@parameter.inner",
		"textobjects"
	)
end)

vim.keymap.set("n", "<leader>sn", function()
	require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end)
vim.keymap.set("n", "<leader>sp", function()
	require("nvim-treesitter-textobjects.swap").swap_previous(
		"@parameter.outer"
	)
end)

vim.keymap.set({ "x", "o" }, "ae", function()
	require("nvim-treesitter-textobjects.select").select_textobject(
		"@svelte.element",
		"textobjects"
	)
end)
