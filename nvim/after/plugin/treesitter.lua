require("nvim-treesitter.configs").setup({
	-- A list of parser names, or 'all' (the four listed parsers should always be installed)
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"javascript",
		"typescript",
		"python",
		"requirements",
		"go",
		"bash",
		"regex",
		"sql",
		"json",
		"gitcommit",
		"html",
		"css",
		"scss",
		"vue",
		"svelte",
		"markdown",
		"markdown_inline",
		"yaml",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	indent = {
		enable = true,
		-- disable = { "python" },
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

				["aC"] = "@class.outer",
				["iC"] = "@class.inner",
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
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.http2 = {
	install_info = {
		url = "https://github.com/rstcruzo/tree-sitter-http2",
		branch = "main",
		files = { "src/parser.c" },
	},
	filetype = "http",
}

vim.treesitter.language.register("http2", "http")

vim.filetype.add({
	extension = {
		http = "http",
	},
})
