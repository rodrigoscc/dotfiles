local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', function ()
    builtin.find_files({ no_ignore = true })
end)
vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>/', builtin.live_grep)

vim.keymap.set('n', '<leader>S', builtin.spell_suggest)
