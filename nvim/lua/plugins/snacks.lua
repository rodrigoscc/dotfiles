return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			indent = { scope = { enabled = false } },
			input = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			picker = {
				enabled = true,
				layout = { preset = "ivy" },
				actions = {
					diff_branch = function(picker)
						picker:close()

						local current = picker:current()

						if current and current.commit then
							vim.cmd.DiffviewOpen(current.commit .. "...HEAD")
						end
					end,
				},
			},
			quickfile = { enabled = true },
			scope = { enabled = true },
			statuscolumn = { enabled = false },
			words = { enabled = true },
			styles = {
				notification = {
					-- wo = { wrap = true } -- Wrap notifications
				},
			},
		},
	},
}
