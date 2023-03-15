export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:$PATH

eval "$(starship init zsh)"

export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "agkozak/zsh-z"

zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "zsh-users/zsh-autosuggestions"

zplug "unixorn/fzf-zsh-plugin"

zplug "hlissner/zsh-autopair"

zplug "MichaelAquilina/zsh-autoswitch-virtualenv"

zplug "lukechilds/zsh-nvm"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# Nicer z tab completion
zstyle ':completion:*' menu select

export TMUX_FZF_LAUNCH_KEY="f"

alias v=nvim
alias ls=exa
