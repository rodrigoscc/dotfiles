return {
	{
		"aznhe21/actions-preview.nvim",
		event = "LspAttach",
		config = function()
			local hl = require("actions-preview.highlight")

			require("actions-preview").setup({
				backend = { "snacks" },
				diff = {
					algorithm = "patience",
					ignore_whitespace = true,
				},
				highlight_command = {
					hl.delta(),
				},
			})
		end,
	},
}
