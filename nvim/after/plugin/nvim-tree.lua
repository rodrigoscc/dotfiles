local api = require('nvim-tree.api')

local function open_nvim_tree(data)
    local directory = vim.fn.isdirectory(data.file) == 1

    if not directory then
        return
    end

    vim.cmd.cd(data.file)
    api.tree.open()
end

vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })

vim.keymap.set('n', '<F3>', '<cmd>NvimTreeToggle<cr>', { desc = 'toggle nvim tree' })
