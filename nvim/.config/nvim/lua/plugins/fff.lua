---@return string
local function root()
	local git = require("custom.git")
	local git_root = git.get_root()

	return git_root or vim.uv.cwd() --[[@as string]]
end

return {
	{
		"dmtrKovalenko/fff.nvim",
		build = function()
			-- this will download prebuild binary or try to use existing rustup toolchain to build from source
			-- (if you are using lazy you can use gb for rebuilding a plugin if needed)
			require("fff.download").download_or_build_binary()
		end,
		-- if you are using nixos
		-- build = "nix run .#release",
		opts = { -- (optional)
			prompt = " ",
		},
		-- No need to lazy-load with lazy.nvim.
		-- This plugin initializes itself lazily.
		lazy = false,
		keys = {
			{
				"<C-p>",
				function()
					require("fff").find_files_in_dir(root())
				end,
				desc = "FFFind files",
			},
			{
				"<leader>/",
				function()
					require("fff").live_grep({
						grep = {
							modes = { "plain", "fuzzy", "regex" },
						},
						cwd = root(),
					})
				end,
				desc = "LiFFFe grep",
			},
			{
				"<leader>*",
				function()
					require("fff").live_grep({
						query = vim.fn.expand("<cword>"),
						cwd = root(),
					})
				end,
				desc = "Search current word",
			},
		},
	},
}
