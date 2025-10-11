return {
	"ahkohd/buffer-sticks.nvim",
	config = function()
		require("buffer-sticks").setup({
			inactive_modified_char = " 󰇘",
			alternate_modified_char = " 󰇘",
		})
		BufferSticks.toggle()
	end,
}
