return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		-- optional for icon support
		-- or if using mini.icons/mini.nvim
		dependencies = { "nvim-mini/mini.icons" },
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {
			"telescope",
			git = {
				commits = {
					-- Include ref names in commit lines (useful for tags)
					cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
						.. [[%Cgreen(%><(12)%cr%><|(12))%Creset%C(yellow)%d%Creset %s %C(blue)<%an>%Creset"]],
				},
			},
		},
		---@diagnostic enable: missing-fields
	},
}
