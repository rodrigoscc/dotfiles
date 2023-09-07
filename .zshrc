# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:~/.config/bin:~/go/bin:$PATH
export EDITOR=nvim

# Make sure the history is appended to new shells.
setopt incappendhistory

# Restore C-f and other zsh shortcuts, setting EDITOR to nvim was disabling them.
bindkey -e

# Edit command line in $EDITOR.
autoload edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "romkatv/powerlevel10k", as:theme, depth:1

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

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Home and end keys.
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
