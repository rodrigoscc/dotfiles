local builtin = require('telescope.builtin')
local wk = require('which-key')

vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>/', builtin.live_grep)

wk.register({
	s = {
		s = { builtin.spell_suggest, '[s]pell [s]uggest' }
	},
	f = {
		f = { function() builtin.find_files({ no_ignore = true }) end, '[f]ind [f]iles' }
	}
}, { prefix = '<leader>' })
