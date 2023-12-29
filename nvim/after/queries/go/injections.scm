; extends
(call_expression
  (selector_expression) @_function (#match? @_function "(sqlMock|mock|tx|db)\.(Prepare|Exec|ExpectExec|Query)")
  (argument_list
    . [(raw_string_literal) (interpreted_string_literal)] @sql (#offset! @sql 0 1 0 -1)))

(var_declaration
  (var_spec
    name: (identifier) @_name (#match? @_name ".*TSQuery")
    value: (_) @query))
