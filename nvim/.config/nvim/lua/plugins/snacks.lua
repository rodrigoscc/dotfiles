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
				style = "minimal",
			},
			picker = {
				enabled = true,
				layout = { preset = "ivy" },
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
				doc = {
					enabled = true, -- Must be enabled for terminal to be detected automatically
					inline = false, -- Do not want to replace the images inline
					float = false, -- Do not want a floating window to be automatically open, gK to open it
				},
				math = { latex = { font_size = "large" } },
			},
		},
	},
}
