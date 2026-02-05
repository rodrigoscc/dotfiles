return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = true,
				view = "cmdline",
				format = {
					cmdline = false,
					search_down = false,
					search_up = false,
					filter = false,
					lua = false,
					help = false,
					input = { view = "cmdline" },
				},
			},
			lsp = {
				signature = {
					enabled = false,
				},
			},
			routes = {
				-- Filter write messages: https://github.com/folke/noice.nvim/issues/568#issuecomment-1673907587
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "%d fewer lines" },
							{ find = "%d more lines" },
						},
					},
					view = "mini",
				},
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
					},
					opts = { skip = true },
				},
			},
			presets = {
				lsp_doc_border = true, -- add a border to hover docs and signature help
				bottom_search = true,
				long_message_to_split = true,
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
}
