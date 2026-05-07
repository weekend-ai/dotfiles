# .bashrc — bash entry point
# Sources core configs + bash minimal settings

# Non-interactive shell → exit early
[[ $- != *i* ]] && return

SHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

# ── Core (shared with zsh) ──
[ -f "$SHELL_CONFIG_DIR/env.sh" ]     && source "$SHELL_CONFIG_DIR/env.sh"
[ -f "$SHELL_CONFIG_DIR/aliases.sh" ] && source "$SHELL_CONFIG_DIR/aliases.sh"

# ── bash: History ──
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
[ -d "$(dirname "$HISTFILE")" ] || mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# ── bash: Misc ──
shopt -s checkwinsize
shopt -s cdspell

# ── Tool init (must be last — starship overrides prompt) ──
[ -f "$SHELL_CONFIG_DIR/init.sh" ] && source "$SHELL_CONFIG_DIR/init.sh"

# Fallback prompt if starship is not available
if ! command -v starship &>/dev/null; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
fi

. "$HOME/.local/share/../bin/env"
