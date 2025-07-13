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
				win = {
					-- Some tweaks to avoid conflicting with tmux bindings
					input = {
						keys = {
							["<a-m>"] = nil,
							["<a-o>"] = {
								"toggle_maximize",
								mode = { "i", "n" },
							},
							["<c-b>"] = nil,
							["<C-y>"] = {
								"preview_scroll_up",
								mode = { "i", "n" },
							},
						},
					},
					list = {
						keys = {
							["<a-m>"] = nil,
							["<a-o>"] = {
								"toggle_maximize",
								mode = { "i", "n" },
							},
							["<c-b>"] = nil,
							["<C-y>"] = {
								"preview_scroll_up",
								mode = { "i", "n" },
							},
						},
					},
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
