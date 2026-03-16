local git = require("custom.git")

return {
	s("si", {
		d(1, function()
			local branch = git.branch()
			if branch == nil then
				return sn(nil, t(""))
			end

			if vim.startswith(branch, "snms-") then
				local split = vim.split(branch, "-")
				local ticket = split[1] .. "-" .. split[2]

				return sn(nil, fmt([[{}: {}]], { t(ticket), i(1) }))
			end
		end),
	}),
}
