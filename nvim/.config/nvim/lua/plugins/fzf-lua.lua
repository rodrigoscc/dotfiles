return {
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		-- or if using mini.icons/mini.nvim
		dependencies = { "nvim-mini/mini.icons" },
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {
			git = {
				commits = {
					cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
						.. [[%Cgreen(%><(12)%cr%><|(12))%Creset%C(yellow)%d%Creset %s %C(blue)<%an>%Creset"]],
				},
			},
		},
		---@diagnostic enable: missing-fields
	},
}
