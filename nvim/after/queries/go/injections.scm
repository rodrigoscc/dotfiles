; extends
(call_expression
  (selector_expression) @_function (#match? @_function "(tx|db)\.(Prepare|Exec)")
  (argument_list
    . [(raw_string_literal) (interpreted_string_literal)] @sql (#offset! @sql 0 1 0 -1)))
