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
}
