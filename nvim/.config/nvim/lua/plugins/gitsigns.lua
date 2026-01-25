return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			attach_to_untracked = true,
			signs_staged_enable = false,
			-- Set a higher priority than dap breakpoint sign priority which is 21
			sign_priority = 30,
		},
	},
}
