local augroup = vim.api.nvim_create_augroup("MyOil", { clear = true })

local function delete_missing_file_buffers()
	local buffers_to_delete = {}

	for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if
			buf.name
			and buf.name ~= ""
			and vim.fn.filereadable(buf.name) == 0
			and buf.changed == 0
		then
			table.insert(buffers_to_delete, buf.bufnr)
		end
	end

	if #buffers_to_delete > 0 then
		for _, bufnr in ipairs(buffers_to_delete) do
			-- Delete the buffer. The empty options table {} means force=false.
			vim.api.nvim_buf_delete(bufnr, {})
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	group = augroup,
	callback = function(e)
		if e.data.actions == nil then
			return
		end

		for _, action in ipairs(e.data.actions) do
			if action.type == "delete" then
				delete_missing_file_buffers()
				break
			end
		end
	end,
})
