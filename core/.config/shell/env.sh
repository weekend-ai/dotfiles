# env.sh — Cross-platform environment variables
# Sourced by both zsh and bash

# Platform detection
case "$(uname -s)" in
    Darwin) export DOTFILES_OS="darwin" ;;
    Linux)  export DOTFILES_OS="linux" ;;
    *)      export DOTFILES_OS="unknown" ;;
esac

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Editor
if command -v nvim &>/dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# PATH construction (prepend, deduplicate)
_prepend_path() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}

# Homebrew (macOS)
if [ "$DOTFILES_OS" = "darwin" ]; then
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Common paths
_prepend_path "$HOME/.local/bin"

# Go
if [ -d "$HOME/go/bin" ]; then
    export GOPATH="${GOPATH:-$HOME/go}"
    _prepend_path "$GOPATH/bin"
fi

# Rust
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# pnpm
if [ -d "$HOME/.local/share/pnpm" ]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    _prepend_path "$PNPM_HOME"
fi

# gawk (macOS homebrew)
if [ -d "/opt/homebrew/opt/gawk/libexec/gnubin" ]; then
    _prepend_path "/opt/homebrew/opt/gawk/libexec/gnubin"
fi

# asdf shims
if [ -d "$HOME/.asdf/shims" ]; then
    _prepend_path "$HOME/.asdf/shims"
fi

unset -f _prepend_path

# Local overrides (not tracked by git)
_env_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[ -f "$_env_dir/local.sh" ] && . "$_env_dir/local.sh"
unset _env_dir
