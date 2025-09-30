local function files_from_qf()
	local dedup = {}
	for _, l in ipairs(vim.fn.getqflist()) do
		local fname = vim.api.nvim_buf_get_name(l.bufnr)
		if fname and #fname > 0 then
			dedup[fname] = true
		end
	end
	return vim.tbl_keys(dedup)
end

return { files_from_qf = files_from_qf }
