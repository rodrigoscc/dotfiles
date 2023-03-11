local wk = require('which-key')

wk.register({
    g = {
        name = 'git',
        s = { vim.cmd.Git, '[g]it [s]tatus' },
        l = { function () vim.cmd.Git('log') end, '[g]it [l]og' },
        p = { function () vim.cmd.Git('push') end, '[g]it [p]ush' },
    }
}, { prefix = '<leader>' })

vim.cmd('autocmd User FugitiveEditor startinsert')
