return {
	s(
		"enn",
		fmt(
			[[if err != nil {{
	{}
}}]],
			{
				i(1),
			}
		)
	),
	s(
		"en",
		fmt(
			[[if err == nil {{
	{}
}}]],
			{
				i(1),
			}
		)
	),
	s(
		"fn",
		fmt(
			[[if err {} {}; err == nil {{
	{}
}}]],
			{
				c(1, {
					t(":="),
					t("="),
				}),
				i(2, "function"),
				i(3),
			}
		)
	),
	s(
		"fnn",
		fmt(
			[[if err {} {}; err != nil {{
	{}
}}]],
			{
				c(1, {
					t(":="),
					t("="),
				}),
				i(2, "function"),
				i(3),
			}
		)
	),
	s(
		"forr",
		fmt(
			[[for {}, {} := range {} {{
	{}
}}]],
			{
				i(1, "_"),
				i(2, "item"),
				i(3, "iterable"),
				i(4),
			}
		)
	),
	s(
		"str",
		fmt(
			[[type {} struct {{
	{}
}}]],
			{
				i(1, "name"),
				i(2),
			}
		)
	),
	s(
		"rnil",
		fmt([[require.Nil(t, {}, "{}")]], {
			i(1, "err"),
			i(2, "must succeed"),
		})
	),
	s(
		"fmte",
		fmt([[fmt.Errorf("{}: {}", err)]], {
			i(1),
			i(2, "%w"),
		})
	),
	postfix(
		".pf",
		d(1, function(_, parent)
			return sn(
				nil,
				fmt(
					[[func ({} *]]
						.. parent.snippet.env.POSTFIX_MATCH
						.. [[) {}({}){} {{
	{}
}}]],
					{
						i(1, "structName"),
						i(2, "functionName"),
						i(3),
						i(4),
						i(5),
					}
				)
			)
		end)
	),
	postfix(
		".f",
		d(1, function(_, parent)
			return sn(
				nil,
				fmt(
					[[func ({} ]]
						.. parent.snippet.env.POSTFIX_MATCH
						.. [[) {}({}){} {{
	{}
}}]],
					{
						i(1, "structName"),
						i(2, "functionName"),
						i(3),
						i(4),
						i(5),
					}
				)
			)
		end)
	),
	postfix(
		{ trig = ".nn", match_pattern = "[%w%.%_%-]+%(.*%)$" },
		d(1, function(_, parent)
			local match = parent.snippet.env.POSTFIX_MATCH:gsub("{", "{{")
			match = match:gsub("}", "}}")

			return sn(
				nil,
				fmt([[if err := ]] .. match .. [[; err != nil {{
	{}
}}]], {
					i(1, ""),
				})
			)
		end)
	),
	postfix(
		".new",
		d(1, function(_, parent)
			return sn(
				nil,
				fmt(
					[[func New]]
						.. parent.snippet.env.POSTFIX_MATCH
						.. [[({}){} {{
	{}
}}]],
					{
						i(1),
						i(2),
						i(3),
					}
				)
			)
		end)
	),
}
