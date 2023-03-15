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
    },
    h = {
        t = { builtin.help_tags, '[h]elp [t]ags' },
        k = { builtin.keymaps, '[h]elp [k]eymaps' }
    },
    c = {
        c = { builtin.commands, '[c]ommands' }
    },
    r = {
        r = { builtin.resume, '[r]esume' }
    },
    g = {
        b = { builtin.git_branches, '[g]it [b]ranches' },
        c = { builtin.git_commits, '[g]it [c]ommits' }
    }
}, { prefix = '<leader>' })

wk.register({
    ['<tab>'] = {
        function()
            builtin.buffers({
                ignore_current_buffer = true,
                sort_lastused = true
            })
        end,
        'buffers'
    },
})
