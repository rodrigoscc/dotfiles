return {
	{
		"Bekaboo/dropbar.nvim",
		opts = {
			bar = {
				enable = function(buf, win)
					return vim.fn.win_gettype(win) == ""
						and vim.wo[win].winbar == ""
						and vim.bo[buf].bt == ""
						and (
							vim.bo[buf].ft == "markdown"
							or (buf and vim.api.nvim_buf_is_valid(buf))
						)
				end,
			},
			icons = {
				enable = true,
				kinds = {
					symbols = {
						File = "",
						Folder = "",
					},
				},
				ui = {
					bar = { separator = "  " },
				},
			},
		},
	},
}
