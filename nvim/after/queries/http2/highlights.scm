(method) @keyword
(url) @text.uri
(variable_declaration) @attribute
(variable_declaration name: (identifier) @var (#lua-match? @var "request.title")) @text.title
(variable_ref) @attribute
(header name: (_) @property)

(http_version) @tag

(json_key_value key: _* @property)
(url_encoded_key_value key: (_) @property)
(string) @string
(number) @number
(boolean) @boolean

(status_code) @property
(reason_phrase) @keyword

(separator) @comment
