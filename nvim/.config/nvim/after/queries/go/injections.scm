; extends
(var_declaration
  (var_spec name: (identifier) @identifier (#lua-match? @identifier "TSQuery")
            value: (expression_list (interpreted_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                                    (#set! injection.language "query"))))
(var_declaration
  (var_spec name: (identifier) @identifier (#lua-match? @identifier "TSQuery")
            value: (expression_list (raw_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                                    (#set! injection.language "query"))))

(var_declaration
  (var_spec name: (identifier) @identifier (#lua-match? @identifier "SQLQuery")
            value: (expression_list (interpreted_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                                    (#set! injection.language "sql"))))
(var_declaration
  (var_spec name: (identifier) @identifier (#lua-match? @identifier "SQLQuery")
            value: (expression_list (raw_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                                    (#set! injection.language "sql"))))

(call_expression
  (selector_expression) @identifier (#lua-match? @identifier "dbState\.Query")
  (argument_list (interpreted_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                 (#set! injection.language "sql")))
(call_expression
  (selector_expression) @identifier (#lua-match? @identifier "dbState\.Query")
  (argument_list (raw_string_literal) @injection.content (#offset! @injection.content 0 1 0 -1)
                 (#set! injection.language "sql")))
