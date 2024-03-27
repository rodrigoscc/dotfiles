# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:~/.config/bin:~/go/bin:~/.local/bin:/opt/homebrew/opt/mysql-client/bin:$PATH
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
alias vv="nvim ."

alias ls=lsd
alias ll="lsd --long"
alias lt="lsd --tree --ignore-glob='node_modules|.git'"

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gl="git log"

# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down

# Home and end keys.
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add zsh functions to fpath (e.g. poetry completions).
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# Rose pine fzf theme
export FZF_DEFAULT_OPTS="--layout=reverse --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8,separator:#403d52 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# Disable auto update for homebrew
export HOMEBREW_NO_AUTO_UPDATE=1
