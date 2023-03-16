local lsp = require('lsp-zero')
local wk = require('which-key')

require('neodev').setup {}

lsp.preset('recommended')

lsp.ensure_installed({
    'tsserver',
    'gopls',
    'pylsp',
    'lua_ls',
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
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
                rope_completion = {
                    enabled = true,
                },
                jedi_completion = {
                    enabled = true,
                },
                autopep8 = {
                    enabled = false,
                },
                flake8 = {
                    enabled = true,
                    maxLineLength = 80,
                },
                pycodestyle = {
                    enabled = false
                },
                pyflakes = {
                    enabled = false
                }
            },
            configurationSources = { 'flake8' }
        },
    }
})

-- Using neodev instead.
-- lsp.nvim_workspace()

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
