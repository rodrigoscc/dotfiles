local symbols = {
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "",
	Copilot = "",
	Array = "󰅪",
	-- TypeParameter = "",
}

return {
	{
		"saghen/blink.compat",
		-- use the latest release, via version = '*', if you also use the latest release for blink.cmp
		version = "*",
		-- lazy.nvim will automatically load the plugin when it's required by blink.cmp
		lazy = true,
		-- make sure to set opts so that lazy.nvim calls blink.compat's setup
		opts = {},
	},
	{
		"saghen/blink.cmp",
		version = "v1.8.0",
		dependencies = {
			"mikavilpas/blink-ripgrep.nvim",
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "none",
				["<C-space>"] = {
					"show",
					"show_documentation",
					"hide_documentation",
				},
				["<C-s>"] = {
					"show_signature",
					"hide_signature",
				},
				["<C-y>"] = { "select_and_accept" },
				["<C-e>"] = { "cancel", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-b>"] = {},
				["<C-f>"] = {},
				["<C-k>"] = {}, -- Obscures expand luasnip
			},
			appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- will be removed in a future release
				use_nvim_cmp_as_default = true,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
				kind_icons = symbols,
			},
			snippets = { preset = "luasnip" },
			-- default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, via `opts_extend`
			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"buffer",
					"ripgrep",
				},
				per_filetype = {
					lua = {
						"lazydev",
						"lsp",
						"path",
						"snippets",
						"buffer",
						"ripgrep",
					},
					markdown = {
						"snippets",
						"buffer",
						"ripgrep",
						"obsidian",
						"obsidian_new",
						"obsidian_tags",
					},
				},
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						fallbacks = {},
						async = true,
						score_offset = 50, -- always want lsp over buffer
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						---@module "blink-ripgrep"
						---@type blink-ripgrep.Options
						opts = {
							backend = {
								ripgrep = {
									ignore_paths = { "/Users/rsantacruz" },
								},
							},
						},
					},
				},
			},
			completion = {
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				accept = {
					auto_brackets = {
						enabled = false,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = {
						border = "single",
					},
				},
				menu = {
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
					},
				},
			},
			signature = {
				enabled = true,
				window = {
					border = "rounded",
					treesitter_highlighting = true,
					show_documentation = false,
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
