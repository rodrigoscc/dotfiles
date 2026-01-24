export PATH=~/.config/bin:~/go/bin:~/.local/bin:/opt/nvim-linux64/bin:/usr/local/go/bin:~/.luarocks/bin:~/.local/share/fnm/:~/.local/share/omarchy/bin:$PATH
export EDITOR=nvim

if [[ $OSTYPE == darwin* ]]; then
    export PATH=/opt/homebrew/bin:$PATH

    if [ -x "$(command -v brew)" ]; then
        export PATH=$(brew --prefix python)/libexec/bin:$(brew --prefix mysql-client)/bin:$PATH
    fi
fi

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
    source $ZPLUG_HOME/init.zsh
else
    source /usr/share/zsh/scripts/zplug/init.zsh
fi

zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "zsh-users/zsh-autosuggestions"

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

alias ls=eza
alias ll="eza --long"
alias la="eza --long --all"
alias lt="eza --tree --ignore-glob='node_modules|.git'"
alias lta="eza --tree --all --ignore-glob='node_modules|.git'"

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gl="git log --oneline"

alias pn="pnpm"

alias ..="cd .."

# Home and end keys.
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line

# setup history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config ~/.config/omp/omp.json)"
fi

# Add zsh functions to fpath (e.g. poetry completions).
fpath+=~/.zfunc
fpath+=~/.docker/completions
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
    eval "$(fnm env --use-on-cd --shell zsh)"
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

# Has to be here after all zsh setup
if [ -x "$(command -v fzf)" ]; then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
fi

source ~/fzf-git.sh

export PATH=~/.opencode/bin:$PATH
