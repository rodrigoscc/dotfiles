return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				surrounds = {
					-- Do not add enclosing whitespace on either character
					["("] = {
						add = { "(", ")" },
					},
					["{"] = {
						add = { "{", "}" },
					},
					["["] = {
						add = { "[", "]" },
					},
					["<"] = {
						add = { "<", ">" },
					},
					["s"] = {
						add = function()
							local config = require("nvim-surround.config")
							local result =
								config.get_input("Enter the subscript name: ")
							if result then
								return { { result .. "[" }, { "]" } }
							end
						end,
						find = function()
							local config = require("nvim-surround.config")

							return config.get_selection({
								pattern = "[^=%s%[%]{}]+%b[]",
							})
						end,
						delete = "^(.-%[)().-(%])()$",
						change = {
							target = "^(.-%[)().-(%])()$",
							replacement = function()
								local config = require("nvim-surround.config")
								local result = config.get_input(
									"Enter the subscript name: "
								)
								if result then
									return { { result .. "[" }, { "]" } }
								end
							end,
						},
					},
				},
				aliases = { ["s"] = false },
			})
		end,
	},
}
