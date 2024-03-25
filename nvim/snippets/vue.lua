return {
	postfix(
		".log",
		f(function(_, parent)
			return [[console.log(]]
				.. parent.snippet.env.POSTFIX_MATCH
				.. [[);]]
		end)
	),
}
