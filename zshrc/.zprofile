if command -v Hyprland >/dev/null 2>&1 && [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec Hyprland
fi

