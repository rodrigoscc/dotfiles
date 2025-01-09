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
		"echasnovski/mini.indentscope",
		version = "*",
		opts = { symbol = "│", options = { try_as_border = true } },
	},
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
	{ "echasnovski/mini.cursorword", version = "*", opts = {} },
	{
		"stevearc/dressing.nvim",
		opts = { input = { relative = "editor" } },
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
			{ "rcarriga/nvim-notify", opts = { render = "compact" } },
		},
	},
	{
		"lukas-reineke/headlines.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		lazy = true,
		ft = "markdown",
		opts = {
			markdown = {
				headline_highlights = { "Headline1", "Headline2", "Headline3" },
				fat_headlines = false,
			},
		},
	},
}
