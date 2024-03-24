return {
	s(
		"enn",
		fmt(
			[[if err != nil {{
	return {}
}}]],
			{
				i(1, "err"),
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
	return {}
}}]],
			{
				c(1, {
					t(":="),
					t("="),
				}),
				i(2, "function"),
				i(3, "err"),
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
			local struct_name = parent.snippet.env.POSTFIX_MATCH

			local query = vim.treesitter.query.parse(
				"go",
				'(parameter_list (parameter_declaration name: (identifier) @name type: (pointer_type) @type (#lua-match? @type "*'
					.. struct_name
					.. '")))'
			)

			local parser = vim.treesitter.get_parser(0, "go")
			local tree = parser:parse()[1]

			local receiver_name = "receiver"

			local _, first_match = query:iter_matches(tree:root(), 0)()

			if first_match ~= nil then
				for id, node in pairs(first_match) do
					local capture_name = query.captures[id]
					local capture_value = vim.treesitter.get_node_text(node, 0)

					if capture_name == "name" then
						receiver_name = capture_value
						break
					end
				end
			end

			return sn(
				nil,
				fmt([[func ({} *]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
					i(1, receiver_name),
					i(2, "functionName"),
					i(3),
					i(4),
					i(5),
				})
			)
		end)
	),
	postfix(
		".f",
		d(1, function(_, parent)
			local struct_name = parent.snippet.env.POSTFIX_MATCH

			local query = vim.treesitter.query.parse(
				"go",
				'(parameter_list (parameter_declaration name: (identifier) @name type: (pointer_type) @type (#lua-match? @type "'
					.. struct_name
					.. '")))'
			)

			local parser = vim.treesitter.get_parser(0, "go")
			local tree = parser:parse()[1]

			local receiver_name = "receiver"

			local _, first_match = query:iter_matches(tree:root(), 0)()

			if first_match ~= nil then
				for id, node in pairs(first_match) do
					local capture_name = query.captures[id]
					local capture_value = vim.treesitter.get_node_text(node, 0)

					if capture_name == "name" then
						receiver_name = capture_value
						break
					end
				end
			end

			return sn(
				nil,
				fmt([[func ({} ]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
					i(1, receiver_name),
					i(2, "functionName"),
					i(3),
					i(4),
					i(5),
				})
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
	return {}
}}]], {
					i(1, "err"),
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
