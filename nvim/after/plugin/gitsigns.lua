local gitsigns = require('gitsigns')

vim.keymap.set('n', '<leader>ph', gitsigns.preview_hunk, { desc = '[p]review [h]unk' })
vim.keymap.set('n', '<leader>pH', gitsigns.preview_hunk_inline, { desc = '[p]review [h]unk inline' })
vim.keymap.set('n', '<leader>rh', gitsigns.reset_hunk, { desc = '[r]eset [h]unk' })
vim.keymap.set('n', '<leader>bl', gitsigns.blame_line, { desc = '[b]lame [l]ine' })

vim.keymap.set('n', ']h', gitsigns.next_hunk, { desc = 'next hunk' })
vim.keymap.set('n', '[h', gitsigns.prev_hunk, { desc = 'previous hunk' })
