require("nvim-treesitter.configs").setup({
	-- A list of parser names, or 'all' (the four listed parsers should always be installed)
	ensure_installed = {
		"help",
		"javascript",
		"typescript",
		"python",
		"requirements",
		"go",
		"c",
		"lua",
		"bash",
		"regex",
		"sql",
		"json",
		"vim",
		"help",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	indent = {
		enable = true,
		disable = { "python" },
	},
	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",

				["af"] = "@function.outer",
				["if"] = "@function.inner",

				["ac"] = "@conditional.outer",
				["ic"] = "@conditional.inner",
			},
			-- More convenient than including it most of the time.
			include_surrounding_whitespace = false,
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>sn"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>sp"] = "@parameter.inner",
			},
		},
	},
	-- Disabled for now because of bug with treesitter.
	incremental_selection = {
		enable = true,
		keymaps = {
			-- init_selection = '<c-space>',
			node_incremental = "<C-k>",
			-- scope_incremental = '<c-s>',
			node_decremental = "<C-j>",
		},
	},
	autotag = {
		enable = true,
	},
})
