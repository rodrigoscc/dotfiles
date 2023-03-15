function ColorMyPencils(color)
    color = color or 'vscode'
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
end

-- ColorMyPencils()
