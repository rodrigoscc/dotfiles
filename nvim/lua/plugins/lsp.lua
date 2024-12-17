return {
	{
		"kndndrj/nvim-dbee",
		lazy = true,
		cmd = { "DBUIToggle", "DBUI" },
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			-- Install tries to automatically detect the install method.
			-- if it fails, try calling it with one of these parameters:
			--    "curl", "wget", "bitsadmin", "go"
			require("dbee").install()
		end,
		config = function()
			require("dbee").setup(--[[optional config]])
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		dependencies = {
			-- LSP Support
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
	},
	{ "williamboman/mason.nvim" },
	{ "onsails/lspkind.nvim" },
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
		lazy = false, -- lazy loading handled internally
		-- use a release tag to download pre-built binaries
		version = "v0.*",
		-- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		event = "InsertEnter",

		dependencies = {
			{ "L3MON4D3/LuaSnip", version = "v2.*" },
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

			-- default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, via `opts_extend`
			sources = {
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
					-- 👇🏻👇🏻 add the ripgrep provider config below
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
				completion = {
					enabled_providers = function(ctx)
						local providers = {
							"lsp",
							"path",
							"luasnip",
							"buffer",
							"ripgrep",
						}

						if vim.bo.filetype == "lua" then
							table.insert(providers, "lazydev")
						end

						if vim.bo.filetype == "http" then
							table.insert(providers, "http")
						end

						if vim.bo.filetype == "markdown" then
							table.insert(providers, "obsidian")
							table.insert(providers, "obsidian_new")
							table.insert(providers, "obsidian_tags")
						end

						return providers
					end,
				},
			},

			completion = {
				accept = {
					-- experimental auto-brackets support
					auto_brackets = {
						enabled = true,
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

			-- experimental signature help support
			-- signature = { enabled = true }
		},
		-- allows extending the providers array elsewhere in your config
		-- without having to redefine it
		opts_extend = { "sources.completion.enabled_providers" },
	},
}
