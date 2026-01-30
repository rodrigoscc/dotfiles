return {
	{
		"hedyhli/outline.nvim",
		lazy = true,
		keys = {
			{
				"<leader>ty",
				"<cmd> belowright Outline<CR>",
				desc = "Toggle Outline",
			},
			{ "<leader>fy", vim.cmd.OutlineFocus, desc = "Focus Outline" },
		},
		opts = {
			keymaps = {
				close = { "q" }, -- Do not want Escape to close the outline.
			},
		},
	},
}
