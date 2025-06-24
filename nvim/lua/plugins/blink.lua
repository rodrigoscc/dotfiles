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
		version = "*",
		dependencies = {
			"mikavilpas/blink-ripgrep.nvim",
			"rodrigoscc/blink-cmp-words",
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
					http = {
						"http",
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
						"thesaurus",
						"dictionary",
					},
				},
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						max_items = 3,
						score_offset = -5,
						---@module "blink-ripgrep"
						---@type blink-ripgrep.Options
						opts = {
							prefix_min_len = 5,
							context_size = 5,
							max_filesize = "1M",
							ignore_paths = { "/Users/rsantacruz" },
						},
					},
					http = {
						name = "http",
						module = "blink.compat.source",
					},
					obsidian = {
						name = "obsidian",
						module = "blink.compat.source",
					},
					obsidian_new = {
						name = "obsidian_new",
						module = "blink.compat.source",
					},
					obsidian_tags = {
						name = "obsidian_tags",
						module = "blink.compat.source",
					},
					thesaurus = {
						name = "thesaurus",
						module = "blink-cmp-words.thesaurus",
						opts = {
							-- A score offset applied to returned items.
							-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
							score_offset = 0,

							-- Default pointers define the lexical relations listed under each definition,
							-- see Pointer Symbols below.
							-- Default is as below ("antonyms", "similar to" and "also see").
							pointer_symbols = { "!", "&", "^" },
						},
					},
					dictionary = {
						name = "dictionary",
						module = "blink-cmp-words.dictionary",
						opts = {
							-- The number of characters required to trigger completion.
							-- Set this higher if completion is slow, 3 is default.
							dictionary_search_threshold = 4,

							-- See above
							score_offset = 0,

							-- See above
							pointer_symbols = { "!", "&", "^" },
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
					treesitter_highlighting = true,
					show_documentation = false,
				},
			},
			fuzzy = {
				sorts = {
					"exact",
					"score",
					"sort_text",
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
