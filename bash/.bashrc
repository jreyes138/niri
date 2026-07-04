# .bashrc
#[[ $- == *i* ]] || exit 0
#fastfetch

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ── Bash Completion ──────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ── History ──────────────────────────────────────────────────────────────────
HISTSIZE=10000                  # lines kept in memory
HISTFILESIZE=20000              # lines kept on disk
HISTFILE="$HOME/.bash_history"
HISTCONTROL=ignoreboth          # ignore duplicates & lines starting with space
HISTTIMEFORMAT="%F %T "         # timestamp each entry

shopt -s histappend             # append instead of overwrite on exit
shopt -s cmdhist                # save multi-line commands as one entry
shopt -s histreedit             # allow re-editing a failed history substitution

# Sync history across terminals after every command
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# ── Shell Options ────────────────────────────────────────────────────────────
shopt -s autocd                 # type a dir name to cd into it
shopt -s cdspell                # autocorrect minor cd typos
shopt -s dirspell               # autocorrect dir spelling in completion
shopt -s checkwinsize           # update LINES/COLUMNS after each command
shopt -s globstar               # enable ** glob pattern

# Better tab completion behaviour
bind 'set completion-ignore-case on'        # case-insensitive completion
bind 'set show-all-if-ambiguous on'         # show list on first Tab
bind 'set menu-complete-display-prefix on'
bind '"\t": menu-complete'                  # cycle through completions with Tab
bind '"\e[Z": menu-complete-backward'       # Shift-Tab goes backward
bind '"\e[A": history-search-backward'      # Up arrow searches history
bind '"\e[B": history-search-forward'       # Down arrow searches history

# ── PATH ─────────────────────────────────────────────────────────────────────
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ── Bat ( better cat ) ───────────────────────────────────────────────────────
export BAT_THEME="gruvbox-dark"

# ── FZF ──────────────────────────────────────────────────────────────────────
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${{}}'  2>/dev/null"          "$@" ;;
    ssh)          fzf --preview 'dig {}'                                    "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview"                 "$@" ;;
  esac
}

# ── FZF Theme ────────────────────────────────────────────────────────────────
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# ── Prompt (PS1) ─────────────────────────────────────────────────────────────
PS1="\[\e[0m\]\[\e[38;5;35m\]╭─(\[\e[38;5;38m\]\t\[\e[38;5;35m\])-(\[\e[38;5;38m\]\j\[\e[38;5;35m\])-(\[\e[38;5;38m\]\H\[\e[38;5;35m\])-(\[\e[38;5;38m\]\w\[\e[38;5;35m\])\n\[\e[38;5;35m\]╰──🚀 \[\e[0m\]"
#PS1="\[\e[38;5;35m\]╭─\[\e[m\]\[\e[38;5;35m\](\[\e[m\]\[\e[38;5;9m\]\t\[\e[m\]\[\e[38;5;35m\])\[\e[m\]\[\e[38;5;35m\]-\[\e[m\]\[\e[38;5;35m\](\[\e[m\]\[\e[38;5;9m\]\j\[\e[m\]\[\e[38;5;35m\])\[\e[m\]\[\e[38;5;35m\]-\[\e[m\]\[\e[38;5;35m\](\[\e[m\]\[\e[38;5;9m\]\H\[\e[m\]\[\e[38;5;35m\])\[\e[m\]\[\e[38;5;35m\]-\[\e[m\]\[\e[38;5;35m\](\[\e[m\]\[\e[38;5;9m\]\w\[\e[m\]\[\e[38;5;35m\])\[\e[m\]\n\[\e[38;5;35m\]╰──💣\[\e[m\] "
#eval "$(starship init bash)"

# ── Tool Inits ───────────────────────────────────────────────────────────────
eval "$(zoxide init bash)"
eval "$(fzf --bash)"

# ── User specific aliases and functions ──────────────────────────────────────
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# ── Aliases ──────────────────────────────────────────────────────────────────
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias update='sudo dnf update -y --refresh && flatpak update -y'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias cat='bat --paging=never'
alias install='sudo dnf install'
# ── cd with ls ───────────────────────────────────────────────────────────────
function cd() {
    local new_directory="${*:-$HOME}"
    builtin cd "$new_directory" && eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions
}

# zoxide + eza
zl() {
    z "$@" && eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions
}

# ── extract ──────────────────────────────────────────────────────────────────
function extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case "$1" in
        *.tar.bz2)   tar xjvf "$1"     ;;
        *.tar.gz)    tar xzvf "$1"     ;;
        *.tar.xz)    tar xvf  "$1"     ;;
        *.bz2)       bzip2 -d "$1"     ;;
        *.rar)       unrar2dir "$1"    ;;
        *.gz)        gunzip "$1"       ;;
        *.tar)       tar xf  "$1"      ;;
        *.tbz2)      tar xjf "$1"      ;;
        *.tgz)       tar xzf "$1"      ;;
        *.zip)       unzip2dir "$1"    ;;
        *.Z)         uncompress "$1"   ;;
        *.7z)        7z x "$1"         ;;
        *.ace)       unace x "$1"      ;;
        *)           echo "'$1' cannot be extracted via extract()" ; return 1 ;;
    esac
}

# ── mkcd: make dir and cd into it ────────────────────────────────────────────
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Pi
export PATH="/home/joser/.hermes/node/bin:$PATH"
