return {
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "williamboman/mason.nvim" },
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		lazy = true,
		event = "InsertEnter",
		config = function()
			local ls = require("luasnip")
			local loaders = require("luasnip.loaders")

			ls.setup({
				enable_autosnippets = true,
				update_events = { "TextChanged", "TextChangedI" },
			})

			local load = require("luasnip.loaders.from_lua").load

			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true, desc = "expand or jump snippet" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true, desc = "jump snippet backwards" })

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { desc = "next snippet choice" })

			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				if ls.choice_active() then
					ls.change_choice(-1)
				end
			end, { desc = "previous snippet choice" })

			vim.keymap.set(
				"n",
				"<leader>es",
				loaders.edit_snippet_files,
				{ desc = "[e]dit [s]nippets" }
			)

			load({ paths = "./snippets" })
		end,
	},
	{
		"hedyhli/outline.nvim",
		lazy = true,
		keys = {
			{ "<leader>ty", vim.cmd.Outline, desc = "Toggle Outline" },
			{ "<leader>fy", vim.cmd.OutlineFocus, desc = "Focus Outline" },
		},
		opts = {
			keymaps = {
				close = { "q" }, -- Do not want Escape to close the outline.
			},
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				"plenary.nvim/lua/plenary",
				"luvit-meta/library",
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- `vim.uv` typings
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
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				["<C-space>"] = {
					"show",
					"show_documentation",
					"hide_documentation",
				},
				["<C-y>"] = { "select_and_accept" },
				["<C-e>"] = { "cancel", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-b>"] = {},
				["<C-f>"] = {},
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
						name = "http", -- IMPORTANT: use the same name as you would for nvim-cmp
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
				},
			},
			completion = {
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
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
		},
		opts_extend = { "sources.default" },
	},
}
