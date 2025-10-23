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
				previewers = {
					diff = { builtin = false },
					git = { builtin = false },
				},
				actions = {
					diff_head = function(picker)
						picker:close()

						local current = picker:current()

						if current and current.commit then
							vim.cmd.DiffviewOpen(current.commit .. "...HEAD")
						end
					end,
					diff_parent = function(picker)
						picker:close()

						local current = picker:current()

						if current and current.commit then
							vim.cmd.DiffviewOpen(
								current.commit .. "~" .. ".." .. current.commit
							)
						end
					end,
				},
				win = {
					input = {
						keys = {
							["<c-l>"] = { "loclist", mode = { "i", "n" } },
							-- Some tweaks to avoid conflicting with tmux bindings
							["<a-m>"] = nil,
							["<a-w>"] = nil,
							["<a-c>"] = "cycle_win",
							["<a-o>"] = {
								"toggle_maximize",
								mode = { "i", "n" },
							},
							["<c-b>"] = nil,
							["<c-y>"] = {
								"preview_scroll_up",
								mode = { "i", "n" },
							},
						},
					},
					list = {
						keys = {
							["<c-l>"] = { "loclist", mode = { "i", "n" } },
							-- Some tweaks to avoid conflicting with tmux bindings
							["<a-m>"] = nil,
							["<a-w>"] = nil,
							["<a-c>"] = "cycle_win",
							["<a-o>"] = {
								"toggle_maximize",
								mode = { "i", "n" },
							},
							["<c-b>"] = nil,
							["<c-y>"] = {
								"preview_scroll_up",
								mode = { "i", "n" },
							},
						},
					},
					preview = {
						keys = {
							["<a-w>"] = nil,
							["<a-c>"] = "cycle_win",
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
			dim = { scope = { min_size = 1, siblings = false } },
			image = {
				doc = { enabled = false },
				math = { latex = { font_size = "large" } },
			},
		},
	},
}
