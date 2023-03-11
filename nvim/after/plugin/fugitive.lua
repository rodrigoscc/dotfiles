local wk = require('which-key')

wk.register({
    g = {
        name = 'git',
        s = { vim.cmd.Git, 'git status' },
        l = { function () vim.cmd.Git('log') end, 'git log' },
        p = { function () vim.cmd.Git('push') end, 'git push' },
    }
}, { prefix = '<leader>' })

vim.cmd('autocmd User FugitiveEditor startinsert')
