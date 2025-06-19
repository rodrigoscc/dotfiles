export PATH=/opt/homebrew/opt/python@3.9/libexec/bin:~/.config/bin:~/go/bin:~/.local/bin:/opt/homebrew/opt/mysql-client/bin:/opt/nvim-linux64/bin:/usr/local/go/bin:~/.luarocks/bin:$PATH
export EDITOR=nvim

# Luarocks needs this to work properly
if [ -x "$(command -v luarocks)" ]; then
    eval $(luarocks --lua-version=5.1 path)
fi

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

if [ -x "$(command -v fnm)" ]; then
    eval "`fnm env`"
fi

# ripgrep->fzf->vim [QUERY]
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            $EDITOR {1} +{2}     # No selection. Open the current line in Vim.
          else
            $EDITOR +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'ctrl-a:toggle-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

source ~/.config/fzf-git.sh

if command -v docker &> /dev/null; then
  source <(docker completion zsh)
fi
