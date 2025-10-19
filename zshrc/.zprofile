if command -v Hyprland >/dev/null 2>&1 && [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    export PATH=$PATH:~/.local/share/omarchy/bin
    exec Hyprland
fi

