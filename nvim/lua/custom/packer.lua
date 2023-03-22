vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

    use('nvim-treesitter/playground')

    use({
        'nvim-treesitter/nvim-treesitter-textobjects',
        after = 'nvim-treesitter',
        requires = 'nvim-treesitter/nvim-treesitter',
    })

    use('mbbill/undotree')

    use('tpope/vim-fugitive')
    use('tpope/vim-rhubarb')

    use { 'folke/neodev.nvim' }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },             -- Required
            { 'williamboman/mason.nvim' },           -- Optional
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },         -- Required
            { 'hrsh7th/cmp-nvim-lsp' },     -- Required
            { 'hrsh7th/cmp-buffer' },       -- Optional
            { 'hrsh7th/cmp-path' },         -- Optional
            { 'saadparwaiz1/cmp_luasnip' }, -- Optional
            { 'hrsh7th/cmp-nvim-lua' },     -- Optional

            -- Snippets
            { 'L3MON4D3/LuaSnip' },             -- Required
            { 'rafamadriz/friendly-snippets' }, -- Optional
        }
    }

    use 'HiPhish/nvim-ts-rainbow2'

    use {
        'windwp/nvim-autopairs',
        config = function()
            local npairs = require('nvim-autopairs')
            npairs.setup {}
        end
    }

    use({
        'kylechui/nvim-surround',
        tag = '*', -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require('nvim-surround').setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    use 'nvim-tree/nvim-web-devicons'

    use({
        'utilyre/barbecue.nvim',
        tag = '*',
        requires = {
            'SmiteshP/nvim-navic',
            'nvim-tree/nvim-web-devicons', -- optional dependency
        },
        after = 'nvim-web-devicons',       -- keep this if you're using NvChad
        config = function()
            require('barbecue').setup()
        end,
    })

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup({
                options = {
                    component_separators = '|',
                    section_separators = '',
                }
            })
        end
    }

    use {
        'folke/tokyonight.nvim',
        config = function()
            require('tokyonight').setup({
                style = 'night',
                styles = {
                    sidebars = 'normal'
                }
            })
            vim.cmd [[colorscheme tokyonight-night]]
        end
    }

    use {
        'folke/which-key.nvim',
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require('which-key').setup()
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    use {
        'ggandor/leap.nvim',
        config = function()
            require('leap').add_default_mappings()
        end
    }

    use 'lukas-reineke/indent-blankline.nvim'

    use 'tpope/vim-sleuth'

    use {
        'akinsho/toggleterm.nvim',
        tag = '*',
        config = function()
            require('toggleterm').setup()
        end
    }

    use { 'mfussenegger/nvim-dap' }
    use {
        'rcarriga/nvim-dap-ui',
        requires = { 'mfussenegger/nvim-dap' },
        config = function()
            local dap, dapui = require('dap'), require('dapui')

            dapui.setup()

            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated['dapui_config'] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited['dapui_config'] = function()
                dapui.close()
            end
        end
    }
    use {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
            require('nvim-dap-virtual-text').setup {}
        end
    }
    use {
        'nvim-telescope/telescope-dap.nvim',
        requires = { 'nvim-telescope/telescope.nvim' },
        config = function()
            require('telescope').load_extension('dap')
        end
    }
    use {
        'leoluz/nvim-dap-go',
        config = function()
            require('dap-go').setup()
        end
    }

    use {
        'mfussenegger/nvim-dap-python',
        config = function()
            require('dap-python').setup('~/.venvs/debugpy/bin/python')
        end
    }

    use({
        'Wansmer/treesj',
        requires = { 'nvim-treesitter' },
        config = function()
            require('treesj').setup {
                use_default_keymaps = false
            }
        end,
    })

    use {
        'tpope/vim-dispatch',
        config = function()
        end
    }

    use {
        'vim-test/vim-test',
        after = { 'vim-dispatch' },
        config = function()
            vim.cmd('let g:dispatch_compilers = {}')
            vim.cmd('let g:dispatch_compilers["python -m unittest"] = "pyunit"')
            vim.g['test#strategy'] = 'dispatch'
        end
    }

    use {
        'j-hui/fidget.nvim',
        config = function()
            require('fidget').setup {}
        end
    }

    use {
        'lukas-reineke/virt-column.nvim',
        config = function()
            require('virt-column').setup({
                char = '│'
            })
        end
    }

    use {
        'ntpeters/vim-better-whitespace',
        config = function()
            vim.cmd('let g:better_whitespace_enabled=0')
            vim.cmd('let g:strip_whitespace_on_save=1')
            vim.cmd('let g:strip_whitespace_confirm=0')
            vim.cmd("let g:better_whitespace_operator='_s'")
        end
    }

    -- use {
    --     'christoomey/vim-tmux-navigator',
    --     config = function()
    --         vim.cmd('let g:tmux_navigator_no_mappings = 1')
    --     end
    -- }

    use {
        'knubie/vim-kitty-navigator',
        config = function()
            vim.cmd('let g:kitty_navigator_no_mappings = 1')
        end
    }

    use {
        'folke/todo-comments.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup {
                signs = false,
                highlight = {
                    keyword = 'fg',
                    after = ''
                }
            }
        end
    }

    use {
        'RRethy/vim-illuminate',
        config = function()
            require('illuminate').configure({
                filetypes_denylist = { 'NvimTree' }
            })
        end
    }

    use {
        'max397574/better-escape.nvim',
        config = function()
            require('better_escape').setup()
        end,
    }

    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional
        },
        config = function()
            require('nvim-tree').setup({
                view = {
                    side = 'right'
                },
                update_focused_file = {
                    enable = true,
                },
                sort_by = 'modification_time',
                hijack_cursor = true,
            })
        end
    }

    use {
        'benfowler/telescope-luasnip.nvim',
    }

    use {
        'danymat/neogen',
        config = function()
            require('neogen').setup {
                snippet_engine = 'luasnip'
            }
        end,
        requires = 'nvim-treesitter/nvim-treesitter',
    }

    use 'Vimjas/vim-python-pep8-indent'
end)
