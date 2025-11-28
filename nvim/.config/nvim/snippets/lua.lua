return {
	s(
		"use",
		c(1, {
			fmt([[use({{ "{}" }})]], {
				i(1, "plugin"),
			}),
			fmt(
				[[use({{
	"{}",
	config = function()
		{}
	end
}})]],
				{
					i(1, "plugin"),
					i(2, "-- TODO: config"),
				}
			),
			fmt(
				[[use({{
	"{}",
	config = function()
		local {} = require("{}")
		{}
	end
}})]],
				{
					i(1, "plugin"),
					i(2),
					i(3),
					i(4),
				}
			),
		})
	),
	s(
		"ins",
		fmt([[print(vim.inspect({}))]], {
			i(1),
		})
	),
}
