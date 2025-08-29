return {
	s(
		"fr",
		fmt(
			[[@app.route("{}")
def {}():
    {}]],
			{
				i(1, "route"),
				i(2, "view_name"),
				i(3, "# TODO: implement view"),
			}
		)
	),
	s(
		"def",
		fmt(
			[[def {}({}):
    {}]],
			{
				i(1, "func_name"),
				i(2),
				i(3, "pass"),
			}
		)
	),
	s(
		"defs",
		fmt(
			[[def {}(self{}):
    {}]],
			{
				i(1, "func_name"),
				i(2),
				i(3, "pass"),
			}
		)
	),
	s(
		"forin",
		fmt(
			[[for {} in {}:
    {}]],
			{
				i(1, "i"),
				i(2, "iteratable"),
				i(3, "pass"),
			}
		)
	),
	s(
		"fore",
		fmt(
			[[for idx, {} in enumerate({}):
    {}]],
			{
				i(1, "i"),
				i(2, "iteratable"),
				i(3, "pass"),
			}
		)
	),
	s(
		"forit",
		fmt(
			[[for {}, {} in {}.items():
    {}]],
			{
				i(1, "key"),
				i(2, "value"),
				i(3, "dict"),
				i(4, "pass"),
			}
		)
	),
	s(
		"deft",
		fmt(
			[[def test_{}({}):
    {}]],
			{
				i(1, "test_name"),
				i(2),
				i(3, "pass"),
			}
		)
	),
	s(
		"ifn",
		fmt(
			[[if {} is None:
    {}]],
			{
				i(1, "value"),
				i(2, "pass"),
			}
		)
	),
	s(
		"ifnn",
		fmt(
			[[if {} is not None:
    {}]],
			{
				i(1, "value"),
				i(2, "pass"),
			}
		)
	),
	s(
		"if",
		fmt(
			[[if {}:
    {}]],
			{
				i(1, "condition"),
				i(2, "pass"),
			}
		)
	),
	s(
		"smodel",
		fmt(
			[[class {}(db.Model):
    __bind_key__ = "{}"
    uuid = db.Column(
        postgresql.UUID(as_uuid=True),
        primary_key=True,
        nullable=False,
        server_default=text("uuid_generate_v4()"),
    )
			]],
			{
				i(1, "ModelName"),
				c(2, { t("core"), t("azotel"), t("freeradius") }),
			}
		)
	),
	postfix(
		".opt",
		d(1, function(_, parent)
			return sn(nil, {
				t("Optional[" .. parent.snippet.env.POSTFIX_MATCH .. "]"),
			})
		end)
	),
}
