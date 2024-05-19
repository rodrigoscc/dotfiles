return {
	{ "nvim-tree/nvim-web-devicons" },
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		opts = {
			icons = {
				enable = true,
				kinds = {
					use_devicons = false,
					symbols = {
						File = "",
						Folder = "",
					},
				},
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = false },
		},
	},
	{
		"lukas-reineke/virt-column.nvim",
		opts = {
			virtcolumn = "80",
			char = "│",
		},
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
		"brenoprata10/nvim-highlight-colors",
		opts = { render = "virtual", enable_tailwind = true },
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			vim.g.rainbow_delimiters = {
				query = {
					javascript = "rainbow-parens",
					tsx = "rainbow-parens",
					vue = "rainbow-parens",
					html = "rainbow-parens",
					svelte = "rainbow-parens",
				},
			}
		end,
	},
	{
		"folke/zen-mode.nvim",
		opts = {},
	},
	{
		"folke/twilight.nvim",
		opts = {},
	},
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	{
		"rcarriga/nvim-notify",
		opts = {
			stages = "static",
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
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
			"rcarriga/nvim-notify",
		},
	},
	{
		"seblj/nvim-tabline",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
}
