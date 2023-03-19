local neogen = require('neogen')
vim.keymap.set('n', '<leader>id', neogen.generate, { desc = '[i]nsert [d]ocumentation' })
