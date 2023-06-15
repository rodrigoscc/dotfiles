; extends
(
    (string_content) @json
    (#lua-match? "^{\".*")
)
