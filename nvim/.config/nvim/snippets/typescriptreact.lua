return {
	s("uses", {
		t("const ["),
		i(1, "state"),
		t(", set"),
		f(function(arg, snip)
			local name = arg[1][1]
			return name:sub(1, 1):upper() .. name:sub(2, -1)
		end, { 1 }),
		t("] = useState("),
		i(2, "initialValue"),
		t(");"),
	}),
	postfix(
		".log",
		f(function(_, parent)
			return [[console.log(]]
				.. parent.snippet.env.POSTFIX_MATCH
				.. [[);]]
		end)
	),
}
