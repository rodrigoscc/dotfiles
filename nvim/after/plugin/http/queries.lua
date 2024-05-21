local M = {}

-- TODO: Change parser name from http2 to something else.
M.requests_query = vim.treesitter.query.parse(
	"http2",
	[[
[
 (variable_declaration
	variable_name: (identifier) @variable_name (#lua-match? @variable_name "request.*")
	variable_value: (rest_of_line) @variable_value)
 (method_url) @request
]
]]
)

M.requests_only_query = vim.treesitter.query.parse(
	"http2",
	[[
 (method_url) @request
]]
)

M.variables_query = vim.treesitter.query.parse(
	"http2",
	[[
 (variable_declaration
	variable_name: (identifier) @name (#not-lua-match? @name "request.*")
	variable_value: (rest_of_line) @value)
]]
)

M.request_content_query = vim.treesitter.query.parse(
	"http2",
	[[
[
 (header) @header
 (json_body) @json_body
 (url_encoded_body) @url_encoded_body
 (method_url) @next_request
]
]]
)

return M
