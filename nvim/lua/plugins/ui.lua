return {
	{ "nvim-tree/nvim-web-devicons" },
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
			},
		},
	},
	{ "rebelot/heirline.nvim" },
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			highlight = {
				keyword = "wide_fg",
				after = "",
			},
			gui_style = {
				fg = "BOLD",
			},
		},
	},
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
			user_default_options = {
				tailwind = true,
			},
			filetypes = {
				-- Do not want blink buffers to have colorizer on.
				"html",
				"css",
				"svelte",
				"javascriptreact",
				"typescriptreact",
				"vue",
			},
		},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		submodules = false,
		event = "VeryLazy",
		config = function()
			vim.g.rainbow_delimiters = {
				query = {
					javascript = "rainbow-parens",
					typescript = "rainbow-parens",
					tsx = "rainbow-parens",
					svelte = "rainbow-custom",
				},
				blacklist = { "html" },
			}
		end,
	},
	{
		"folke/zen-mode.nvim",
		lazy = true,
		cmd = { "ZenMode" },
		opts = {},
	},
	{
		"folke/twilight.nvim",
		lazy = true,
		cmd = { "Twilight" },
		opts = {},
	},
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
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
				command_palette = true,
				long_message_to_split = true,
				inc_rename = true,
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"bngarren/checkmate.nvim",
		ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
		opts = {
			files = { "*.md" },
			keys = {
				["<CR>"] = "toggle",
				[",a"] = "archive",
				[",c"] = "create",
				[",r"] = "remove_all_metadata",
			},
			metadata = {
				-- Example: A @priority tag that has dynamic color based on the priority value
				priority = {
					key = ",p",
				},
				-- Example: A @started tag that uses a default date/time string when added
				started = {
					key = ",s",
				},
				-- Example: A @done tag that also sets the todo item state when it is added and removed
				done = {
					key = ",d",
				},
			},
		},
	},
}
