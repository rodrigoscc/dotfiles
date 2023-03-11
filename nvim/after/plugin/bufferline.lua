local wk = require('which-key')

wk.register({
	['<tab>'] = { vim.cmd.BufferLineCycleNext, 'next buffer' },
	['<s-tab>'] = { vim.cmd.BufferLineCyclePrev, 'previous buffer' }, -- s-tab is interpreted as c-Y in warp sadly.
})
