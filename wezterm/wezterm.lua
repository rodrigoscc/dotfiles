local wezterm = require('wezterm')

return {
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
        { key = '0', mods = 'SUPER', action = wezterm.action.ShowTabNavigator },
    },
    front_end = 'WebGpu',
}
