local wezterm = require('wezterm')
local act = wezterm.action

local function isViProcess(pane)
    -- get_foreground_process_name On Linux, macOS and Windows,
    -- the process can be queried to determine this path. Other operating systems
    -- (notably, FreeBSD and other unix systems) are not currently supported
    return pane:get_foreground_process_name():find('n?vim') ~= nil
    -- return pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
    if isViProcess(pane) then
        window:perform_action(
        -- This should match the keybinds you set in Neovim.
            act.SendKey({ key = vim_direction, mods = 'ALT' }),
            pane
        )
    else
        window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
    end
end

wezterm.on('ActivatePaneDirection-right', function(window, pane)
    conditionalActivatePane(window, pane, 'Right', 'l')
end)
wezterm.on('ActivatePaneDirection-left', function(window, pane)
    conditionalActivatePane(window, pane, 'Left', 'h')
end)
wezterm.on('ActivatePaneDirection-up', function(window, pane)
    conditionalActivatePane(window, pane, 'Up', 'k')
end)
wezterm.on('ActivatePaneDirection-down', function(window, pane)
    conditionalActivatePane(window, pane, 'Down', 'j')
end)

return {
    leader = { key = 'Space', mods = 'CTRL' },
    color_scheme = 'tokyonight_night',
    font = wezterm.font { family = 'JetbrainsMono Nerd Font', weight = 'Medium' },
    font_size = 13.0,
    line_height = 1.2,
    window_frame = {
        font = wezterm.font { family = 'JetbrainsMono Nerd Font' },
        font_size = 13.0,
    },
    use_fancy_tab_bar = true,
    enable_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    keys = {
        { key = '0', mods = 'LEADER', action = act.ShowTabNavigator },
        { key = 'h', mods = 'ALT',    action = act.EmitEvent('ActivatePaneDirection-left') },
        { key = 'j', mods = 'ALT',    action = act.EmitEvent('ActivatePaneDirection-down') },
        { key = 'k', mods = 'ALT',    action = act.EmitEvent('ActivatePaneDirection-up') },
        { key = 'l', mods = 'ALT',    action = act.EmitEvent('ActivatePaneDirection-right') },
        { key = 'v', mods = 'LEADER', action = act.SplitHorizontal },
        { key = 'x', mods = 'LEADER', action = act.SplitVertical },
        { key = 'm', mods = 'LEADER', action = act.TogglePaneZoomState },
        {
            key = 'r',
            mods = 'LEADER',
            action = act.ActivateKeyTable {
                name = 'resize_pane',
                one_shot = false,
                timeout_milliseconds = 2000,
                until_unknown = true,
            }
        },
    },
    key_tables = {
        resize_pane = {
            { key = 'h',      action = act.AdjustPaneSize { 'Left', 1 } },
            { key = 'l',      action = act.AdjustPaneSize { 'Right', 1 } },
            { key = 'k',      action = act.AdjustPaneSize { 'Up', 1 } },
            { key = 'j',      action = act.AdjustPaneSize { 'Down', 1 } },

            -- Cancel the mode by pressing escape
            { key = 'Escape', action = 'PopKeyTable' },
        }
    },
    front_end = 'WebGpu',
    window_background_opacity = 0.98
}
