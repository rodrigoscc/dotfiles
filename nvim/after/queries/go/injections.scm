; extends
(call_expression
  (selector_expression) @_function (#any-of? @_function
                                    "db.Prepare")
  (argument_list
    . [(raw_string_literal) (interpreted_string_literal)] @sql (#offset! @sql 0 1 0 -1)))
