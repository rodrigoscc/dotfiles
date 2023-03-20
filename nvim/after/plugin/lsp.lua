local lsp = require('lsp-zero')

require('neodev').setup {}

lsp.preset('recommended')

lsp.ensure_installed({
    'tsserver',
    'gopls',
    'pylsp',
    'lua_ls',
})

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings()

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
cmp_mappings['<C-d>'] = nil
cmp_mappings['<C-b>'] = nil

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'buffer',  keyword_length = 3 },
        -- { name = 'luasnip', keyword_length = 2 },
    }
})

lsp.set_preferences({
    suggest_lsp_servers = false,
})

local telescope = require('telescope.builtin')

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
    vim.keymap.set('n', 'gy', telescope.lsp_dynamic_workspace_symbols, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[r]e[n]ame' })
    vim.keymap.set('n', '<leader>of', vim.diagnostic.open_float, { desc = '[o]pen [f]loat' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[c]ode [a]ction' })

    vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
end)

lsp.configure('pylsp', {
    settings = {
        pylsp = {
            plugins = {
                rope_autoimport = {
                    enabled = true,
                },
                jedi_completion = {
                    enabled = true,
                },
                black = {
                    enabled = true,
                    line_length = 79,
                },
                pyls_isort = {
                    enabled = true
                }
            },
        },
    }
})

-- Using neodev instead.
-- lsp.nvim_workspace()

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
