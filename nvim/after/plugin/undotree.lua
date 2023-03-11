local wk = require('which-key')

wk.register({
	t = {
		u = { vim.cmd.UndotreeToggle, '[t]oggle [u]ndo tree' }
	}
}, { prefix = '<leader>' })
