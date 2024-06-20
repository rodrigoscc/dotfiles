; extends
(call_expression
  (selector_expression (field_identifier) @identifier (#lua-match? @identifier "Query"))
  (argument_list (interpreted_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                 (#set! injection.language "query")))
