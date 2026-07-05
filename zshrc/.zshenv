if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

export PATH=~/.config/bin:~/go/bin:~/.local/bin:/opt/nvim-linux64/bin:/usr/local/go/bin:~/.luarocks/bin:~/.local/share/fnm/:~/.local/share/omarchy/bin:/opt/homebrew/bin/:~/.opencode/bin:$PATH

export FZF_DEFAULT_OPTS="
--layout=reverse
--cycle
--ansi
--color=fg:#908caa,hl:#ebbcba
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
--color=border:#403d52,header:#31748f,gutter:#191724
--color=spinner:#f6c177,info:#9ccfd8
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

