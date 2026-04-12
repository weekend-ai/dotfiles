# init.sh — Tool initialization (must run after env.sh)
# Sourced by both zsh and bash

# Detect current shell for tool init commands
CURRENT_SHELL=$(basename "$SHELL")

# ── zoxide ──
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init "$CURRENT_SHELL")"
fi

# ── fzf ──
if command -v fzf &>/dev/null; then
    # fzf 0.48+ supports `fzf --bash`/`fzf --zsh`; older versions need sourced scripts
    if fzf --"$CURRENT_SHELL" &>/dev/null 2>&1; then
        eval "$(fzf --"$CURRENT_SHELL")"
    else
        # Fallback: source distro-provided key-bindings
        for _fzf_script in \
            "/usr/share/fzf/key-bindings.${CURRENT_SHELL}" \
            "/usr/share/doc/fzf/examples/key-bindings.${CURRENT_SHELL}" \
            "/usr/share/fzf/shell/key-bindings.${CURRENT_SHELL}"; do
            [ -f "$_fzf_script" ] && . "$_fzf_script" && break
        done
        for _fzf_script in \
            "/usr/share/fzf/completion.${CURRENT_SHELL}" \
            "/usr/share/doc/fzf/examples/completion.${CURRENT_SHELL}" \
            "/usr/share/fzf/shell/completion.${CURRENT_SHELL}"; do
            [ -f "$_fzf_script" ] && . "$_fzf_script" && break
        done
        unset _fzf_script
    fi

    # Default options
    export FZF_DEFAULT_OPTS="\
        --height=40% \
        --layout=reverse \
        --border \
        --info=inline"

    # Use fd if available
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    fi

    # Preview with bat if available
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:200 {}'"
    elif command -v batcat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --line-range=:200 {}'"
    fi
fi

# ── starship ──
if command -v starship &>/dev/null; then
    eval "$(starship init "$CURRENT_SHELL")"
fi

# ── asdf ──
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
fi

# ── fzf workflows ──
SHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[ -f "$SHELL_CONFIG_DIR/fzf-workflows.sh" ] && . "$SHELL_CONFIG_DIR/fzf-workflows.sh"
unset SHELL_CONFIG_DIR

# ── vertex (Claude Code) ──
if [ -f "$HOME/.vertex/env" ]; then
    . "$HOME/.vertex/env"
fi

unset CURRENT_SHELL
