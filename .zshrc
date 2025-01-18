export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:~/.config/bin:~/go/bin:~/.local/bin:/opt/homebrew/opt/mysql-client/bin:/opt/nvim-linux64/bin:/usr/local/go/bin:$PATH
export EDITOR=nvim

# Make sure the history is appended to new shells.
setopt incappendhistory

# Allow comments in command line.
setopt interactivecomments

# Restore C-f and other zsh shortcuts, setting EDITOR to nvim was disabling them.
bindkey -e

# Edit command line in $EDITOR.
autoload edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# Autocomplete without case sensitivity.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

if [ -d /opt/homebrew/opt/zplug ]; then
    export ZPLUG_HOME=/opt/homebrew/opt/zplug
else
    export ZPLUG_HOME=$HOME/.zplug
fi
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "zsh-users/zsh-autosuggestions"

zplug "unixorn/fzf-zsh-plugin"

zplug "hlissner/zsh-autopair"

zplug "MichaelAquilina/zsh-autoswitch-virtualenv"

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
alias vv="nvim +StartWorking"

alias ls=lsd
alias ll="lsd --long"
alias lt="lsd --tree --ignore-glob='node_modules|.git'"

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gl="git log --oneline"

alias pn="pnpm"

alias ..="cd .."

# Up and down arrow keys.
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Home and end keys.
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config ~/.config/omp/omp.json)"
fi

# Add zsh functions to fpath (e.g. poetry completions).
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# Rose pine fzf theme
export FZF_DEFAULT_OPTS="
    --layout=reverse
    --cycle
    --ansi
    --color=fg:#908caa,bg:#191724,hl:#ebbcba
    --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
    --color=border:#403d52,header:#31748f,gutter:#191724
    --color=spinner:#f6c177,info:#9ccfd8
    --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# Disable auto update for homebrew
export HOMEBREW_NO_AUTO_UPDATE=1

if [ -d $HOME/n ]; then
    export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
fi
