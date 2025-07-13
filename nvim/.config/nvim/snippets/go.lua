function struct_receiver_name(type_name, is_pointer)
	local receiver_type = type_name
	if is_pointer then
		receiver_type = "*" .. receiver_type
	end

	-- Must be a full match
	receiver_type = "^" .. receiver_type .. "$"

	local query = vim.treesitter.query.parse(
		"go",
		'(method_declaration receiver: (parameter_list (parameter_declaration name: (identifier) @name type: (_) @type (#lua-match? @type "'
			.. receiver_type
			.. '"))))'
	)

	local parser = vim.treesitter.get_parser(0, "go")
	local tree = parser:parse()[1]

	local receiver_name = nil

	local _, first_match = query:iter_matches(tree:root(), 0)()

	if first_match ~= nil then
		for id, nodes in pairs(first_match) do
			local capture_name = query.captures[id]

			for _, node in ipairs(nodes) do
				local capture_value = vim.treesitter.get_node_text(node, 0)

				if capture_name == "name" then
					receiver_name = capture_value
					break
				end
			end
		end
	end

	return receiver_name
end

local function error_return_values()
	local node = vim.treesitter.get_node()

	while
		node ~= nil
		and not vim.tbl_contains(
			{ "function_declaration", "method_declaration" },
			node:type()
		)
	do
		node = node:parent()
	end

	if node == nil then
		return nil
	end

	local parent_result_node = node:field("result")[1]

	local results_nodes = {}

	if parent_result_node then
		if parent_result_node:type() ~= "parameter_list" then
			results_nodes = { parent_result_node }
		else
			for _, child in ipairs(parent_result_node:named_children()) do
				local parameter_node = child:field("type")[1]
				table.insert(results_nodes, parameter_node)
			end
		end
	end

	local values = {}

	for _, result_node in ipairs(results_nodes) do
		if result_node:type() == "pointer_type" then
			table.insert(values, "nil")
		elseif result_node:type() == "slice_type" then
			table.insert(values, "nil")
		else
			local text = vim.treesitter.get_node_text(result_node, 0)

			if text == "error" then
				table.insert(values, "err")
			else
				if
					vim.tbl_contains({
						"int",
						"int32",
						"int64",
						"float32",
						"float64",
					}, text)
				then
					table.insert(values, "0")
				elseif text == "string" then
					table.insert(values, '""')
				elseif text == "bool" then
					table.insert(values, "false")
				else -- struct
					table.insert(values, text .. "{}")
				end
			end
		end
	end

	return values
end

local function error_return_values_to_snippet_nodes(results)
	if results == nil then
		return { i(1) }
	end

	local insert_nodes = vim.iter(results)
		:enumerate()
		:map(function(idx, v)
			return i(idx, v)
		end)
		:totable()

	local all_nodes = {}
	for index, value in ipairs(insert_nodes) do
		if index < #insert_nodes then
			table.insert(all_nodes, value)
			table.insert(all_nodes, t(", "))
		else
			table.insert(all_nodes, value)
		end
	end

	return all_nodes
end

return {
	s(
		"enn",
		fmt(
			[[if err != nil {{
	return {}
}}]],
			{
				d(1, function()
					local results = error_return_values()
					local all_nodes =
						error_return_values_to_snippet_nodes(results)
					return sn(nil, all_nodes)
				end),
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
				d(3, function()
					local results = error_return_values()
					local all_nodes =
						error_return_values_to_snippet_nodes(results)
					return sn(nil, all_nodes)
				end),
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

			local receiver_name = struct_receiver_name(struct_name, true)

			if receiver_name == nil then
				return sn(
					nil,
					fmt([[func ({} *]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
						i(1, "receiver"),
						i(2, "functionName"),
						i(3),
						i(4),
						i(5),
					})
				)
			end

			return sn(
				nil,
				fmt([[func ({} *]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
					t(receiver_name),
					i(1, "functionName"),
					i(2),
					i(3),
					i(4),
				})
			)
		end)
	),
	postfix(
		".f",
		d(1, function(_, parent)
			local struct_name = parent.snippet.env.POSTFIX_MATCH

			local receiver_name = struct_receiver_name(struct_name, false)

			if receiver_name == nil then
				return sn(
					nil,
					fmt([[func ({} ]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
						i(1, "receiver"),
						i(2, "functionName"),
						i(3),
						i(4),
						i(5),
					})
				)
			end

			return sn(
				nil,
				fmt([[func ({} ]] .. struct_name .. [[) {}({}){} {{
	{}
}}]], {
					t(receiver_name),
					i(1, "functionName"),
					i(2),
					i(3),
					i(4),
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
					d(1, function()
						local results = error_return_values()
						local all_nodes =
							error_return_values_to_snippet_nodes(results)
						return sn(nil, all_nodes)
					end),
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
