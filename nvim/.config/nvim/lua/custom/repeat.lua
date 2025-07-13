function make_repeatable(fn)
	return function()
		vim.go.operatorfunc = "v:lua.repeat_action"

		_G.repeat_action = function()
			fn()
		end

		vim.cmd("normal! g@l")
	end
end

return { make_repeatable = make_repeatable }
