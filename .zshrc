export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:~/.config/bin:$PATH
export EDITOR=nvim

# Restore C-f and other zsh shortcuts, setting EDITOR to nvim was disabling them.
bindkey -e

eval "$(starship init zsh)"

export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

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

eval "$(zoxide init zsh)"

alias v=nvim
alias ls=exa
