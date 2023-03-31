local builtin = require('telescope.builtin')
local telescope = require('telescope')

telescope.load_extension('luasnip')

vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>/', builtin.live_grep)

vim.keymap.set('n', '<leader>ss', builtin.spell_suggest, { desc = '[s]pell [s]uggest' })

vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ no_ignore = true }) end, { desc = '[f]ind [f]iles' })

vim.keymap.set('n', '<leader>ht', builtin.help_tags, { desc = '[h]elp [t]ags' })
vim.keymap.set('n', '<leader>hk', builtin.keymaps, { desc = '[h]elp [k]eymaps' })

vim.keymap.set('n', '<leader>cc', builtin.commands, { desc = '[c]ommands' })

vim.keymap.set('n', '<leader>rr', builtin.resume, { desc = '[r]esume' })

vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[g]it [b]ranches' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[g]it [c]ommits' })

vim.keymap.set('n', '<leader>,', function()
    builtin.buffers({
        ignore_current_buffer = true,
        sort_lastused = true
    })
end, { desc = 'buffers' })

vim.keymap.set('n', '<leader>is', '<cmd>Telescope luasnip<cr>', { desc = '[i]nsert [s]nippet' })
