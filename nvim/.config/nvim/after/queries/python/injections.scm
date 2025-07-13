; extends
(
    (string_content) @injection.content
    (#lua-match? @injection.content "\{%s*\"")
    (#set! injection.language "json")
)
