return {
	{
		"SmiteshP/nvim-navic",
		opts = {
			click = true,
			highlight = true,
			separator = " ",
			icons = {
				File = " ",
				Module = " ",
				Namespace = " ",
				Package = " ",
				Class = " ",
				Method = " ",
				Property = " ",
				Field = " ",
				Constructor = " ",
				Enum = " ",
				Interface = " ",
				Function = " ",
				Variable = " ",
				Constant = " ",
				String = " ",
				Number = " ",
				Boolean = " ",
				Array = " ",
				Object = " ",
				Key = " ",
				Null = " ",
				EnumMember = " ",
				Struct = " ",
				Event = " ",
				Operator = " ",
				TypeParameter = " ",
			},
			format_text = function(text)
				if vim.bo.filetype == "svelte" then
					-- Trim classes from jsx elements (e.g. div.flex.bg-white...)
					-- They get too long
					local dot_pos = string.find(text, "%.")

					if dot_pos ~= nil then
						return text:sub(1, dot_pos - 1)
					end
				end

				return text
			end,
		},
	},
}
