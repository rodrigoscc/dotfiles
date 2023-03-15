local wk = require('which-key')
local dap = require('dap')
local dapui = require('dapui')


wk.register({
    t = {
        b = { dap.toggle_breakpoint, '[t]oggle [b]reakpoint' },
        d = { dapui.toggle, '[t]oggle [d]apui' }
    },
    c = {
        b = { dap.clear_breakpoints, '[c]lear [b]reakpoints' }
    },
    d = {
        d = { dap.continue, '[d]ebug / continue' }
    },
    o = {
        r = { dap.repl.open, '[o]pen [r]epl' }
    },
    s = {
        o = { dap.step_over, '[s]tep [o]ver' },
        i = { dap.step_into, '[s]tep [i]nto' },
        u = { dap.step_out, '[s]tep o[u]t' },
    },
    e = { dapui.eval, '[e]val' },
}, { prefix = '<leader>' })
