# ============================================================
# INK · ~/.bashrc
# ============================================================

# Solo seguir si es interactiva
case $- in
    *i*) ;;
      *) return ;;
esac

# -------- historial --------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# -------- completado --------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'

# -------- colores base (grises + xterm-256, sin depender de truecolor) --------
INK_RESET="\[\e[0m\]"
INK_DIM="\[\e[38;5;242m\]"     # gris apagado
INK_FG="\[\e[38;5;253m\]"      # casi blanco
INK_WHITE="\[\e[1;97m\]"       # blanco fuerte
INK_MUTE_GREEN="\[\e[38;5;108m\]"
INK_MUTE_RED="\[\e[38;5;138m\]"

# -------- prompt de dos líneas --------
# ┌─[user@host]─[~/ruta]─(rama git)
# └─❯
__ink_git_branch() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    b=$(git rev-parse --short HEAD 2>/dev/null) || return
    # head -n1: basta saber si hay algo; no hace falta leer todo el status
    if [ -n "$(git status --porcelain 2>/dev/null | head -n1)" ]; then
        printf ' %s(%s ✗)%s' "$INK_MUTE_RED" "$b" "$INK_RESET"
    else
        printf ' %s(%s)%s' "$INK_MUTE_GREEN" "$b" "$INK_RESET"
    fi
}

__ink_prompt() {
    local last=$?
    local mark
    history -a    # guarda el historial al instante (varias terminales a la vez)
    if [ $last -ne 0 ]; then
        mark="${INK_MUTE_RED}❯${INK_RESET}"
    else
        mark="${INK_WHITE}❯${INK_RESET}"
    fi
    PS1="${INK_DIM}┌─[${INK_FG}\u@\h${INK_DIM}]─[${INK_WHITE}\w${INK_DIM}]$(__ink_git_branch)${INK_RESET}\n${INK_DIM}└─${mark} ${INK_RESET}"
}
PROMPT_COMMAND=__ink_prompt

# -------- ls / dircolors: escala de grises, sin colores saturados --------
export LS_COLORS="di=1;97:ln=38;5;250:so=38;5;242:pi=38;5;242:ex=1;37:bd=38;5;242:cd=38;5;242:su=38;5;242:sg=38;5;242:tw=38;5;242:ow=38;5;242"

if command -v eza >/dev/null 2>&1; then
    # icons=auto: sin iconos al redirigir a un pipe o archivo
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lh --group-directories-first --icons=auto'
    alias la='eza -lah --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lah --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never --theme=ansi'
fi

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# -------- navegación --------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# -------- herramientas que ya usas --------
# yazi: al salir, cambia el shell al directorio donde te quedaste
y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd" || return
    fi
    rm -f -- "$tmp"
}

# cmst no está en los repos oficiales; si falta, connmanctl
if command -v cmst >/dev/null 2>&1; then
    alias netui='cmst'
else
    alias netui='connmanctl'
fi
alias sysmon='btop'
alias ff='fastfetch'
alias ports='ss -tulpn'
alias update='sudo pacman -Syu'

# -------- git corto --------
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'

# -------- man pages en escala de grises --------
export LESS='-R'
export LESS_TERMCAP_mb=$'\e[1;37m'
export LESS_TERMCAP_md=$'\e[1;97m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;5;242m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;97m'

# -------- fzf (Ctrl+R historial, Ctrl+T archivos, Alt+C directorios) --------
if command -v fzf >/dev/null 2>&1; then
    [ -f /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash
    [ -f /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    # escala de grises, a juego con el resto del tema
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=sharp --color=bw'
fi

# -------- zoxide (z <dir>, zi) --------
# Va DESPUÉS de definir PROMPT_COMMAND: si no, lo pisaríamos.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# -------- fastfetch al abrir una terminal interactiva --------
# No se repite dentro de tmux, yazi ni neovim.
if command -v fastfetch >/dev/null 2>&1 \
   && [ -z "$INK_NO_FASTFETCH" ] && [ -z "$TMUX" ] \
   && [ -z "$YAZI_LEVEL" ] && [ -z "$NVIM" ]; then
    fastfetch
fi
