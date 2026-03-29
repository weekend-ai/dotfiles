# .zshrc — zsh entry point
# Sources core configs + zsh-specific settings

SHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

# ── Core (shared with bash) ──
[ -f "$SHELL_CONFIG_DIR/env.sh" ]     && source "$SHELL_CONFIG_DIR/env.sh"
[ -f "$SHELL_CONFIG_DIR/aliases.sh" ] && source "$SHELL_CONFIG_DIR/aliases.sh"

# ── zsh: History ──
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[ -d "$(dirname "$HISTFILE")" ] || mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ── zsh: Completion ──
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── zsh: Key bindings ──
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ── zsh: External completions ──
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"

# ── Tool init (must be last — starship overrides prompt) ──
[ -f "$SHELL_CONFIG_DIR/init.sh" ] && source "$SHELL_CONFIG_DIR/init.sh"
