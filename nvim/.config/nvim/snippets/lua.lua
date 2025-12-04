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
	s(
		"ret",
		fmt(
			[[return {{
    {}
}}]],
			{
				i(1),
			}
		)
	),
	s(
		"req",
		fmt(
			[[{{
    {}
}}]],
			{
				c(1, {
					fmt([["{}",{}]], { i(1), i(2) }),
					fmt([[url = {{ {} }},{}]], { i(1), i(2) }),
					fmt(
						[[url = function()
        {}
end,{}]],
						{ i(1), i(2) }
					),
				}),
			}
		)
	),
	s(
		"h",
		fmt(
			[[headers = {{
    {}
}},]],
			{ i(1) }
		)
	),
	s("json", { t([[["Content-Type"] = "application/json",]]) }),
}
