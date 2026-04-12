#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$1"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$1"; exit 1; }

# ── Platform: install dependencies ──

install_deps_mac() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    info "Installing packages via Homebrew..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    ok "Homebrew packages installed"
}

install_deps_linux() {
    info "Installing packages for Linux..."

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq stow ripgrep bat fd-find tmux curl git
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y stow ripgrep bat fd-find tmux curl git
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm stow zoxide ripgrep bat fd tmux git-delta curl git
    else
        warn "Unknown package manager — install stow, fzf, zoxide, ripgrep, bat, fd manually"
    fi

    # fzf: install from git for latest version (distro repos are often outdated)
    if [ ! -d "$HOME/.fzf" ]; then
        info "Installing fzf (latest) from git..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-zsh
    fi

    # neovim: install from GitHub release (distro repos are often outdated)
    if ! command -v nvim &>/dev/null; then
        info "Installing Neovim..."
        local nvim_version="0.10.4"
        curl -sSfLO "https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.tar.gz"
        sudo tar xzf nvim-linux-x86_64.tar.gz -C /opt
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        rm -f nvim-linux-x86_64.tar.gz
    fi

    # zoxide: not in older distro repos, install via official script
    if ! command -v zoxide &>/dev/null; then
        info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # delta: not in most distro repos, install from GitHub release
    if ! command -v delta &>/dev/null; then
        info "Installing git-delta..."
        local delta_version="0.18.2"
        local delta_arch
        delta_arch="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
        local delta_deb="git-delta_${delta_version}_${delta_arch}.deb"
        curl -sSfLO "https://github.com/dandavison/delta/releases/download/${delta_version}/${delta_deb}"
        sudo dpkg -i "$delta_deb"
        rm -f "$delta_deb"
    fi

    # eza: not in most distro repos, install from GitHub release
    if ! command -v eza &>/dev/null; then
        info "Installing eza..."
        local eza_version="0.20.14"
        local eza_arch
        case "$(uname -m)" in
            x86_64)  eza_arch="x86_64-unknown-linux-gnu" ;;
            aarch64) eza_arch="aarch64-unknown-linux-gnu" ;;
            *)       warn "Unsupported arch for eza: $(uname -m)"; eza_arch="" ;;
        esac
        if [ -n "$eza_arch" ]; then
            curl -sSfLO "https://github.com/eza-community/eza/releases/download/v${eza_version}/eza_${eza_arch}.tar.gz"
            tar xzf "eza_${eza_arch}.tar.gz"
            install -m 755 eza "$HOME/.local/bin/eza"
            rm -f "eza_${eza_arch}.tar.gz" eza
        fi
    fi

    # starship: official install script
    if ! command -v starship &>/dev/null; then
        info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # asdf: version manager
    if [ ! -d "$HOME/.asdf" ]; then
        info "Installing asdf..."
        git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.15.0
    fi

    ok "Linux packages installed"
}

# ── Backup conflicting files before stow ──

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

backup_if_exists() {
    local file="$1"
    local target="$HOME/$file"
    # Skip if it's already a symlink (previous stow run) or doesn't exist
    [ -L "$target" ] && return 0
    [ ! -e "$target" ] && return 0
    # Skip if the file resolves to inside the dotfiles repo (stow source)
    local real_path
    real_path="$(greadlink -f "$target" 2>/dev/null || readlink -f "$target")"
    [[ "$real_path" == "$DOTFILES_DIR"/* ]] && return 0
    mkdir -p "$BACKUP_DIR"
    warn "Backing up existing ~/$file → $BACKUP_DIR/$file"
    mkdir -p "$BACKUP_DIR/$(dirname "$file")"
    mv "$target" "$BACKUP_DIR/$file"
}

# ── Stow: create symlinks ──

stow_packages() {
    info "Linking dotfiles with stow..."

    local shell_name
    shell_name="$(basename "$SHELL")"

    # Backup existing configs that would conflict
    backup_if_exists ".zshrc"
    backup_if_exists ".bashrc"
    backup_if_exists ".config/starship.toml"
    backup_if_exists ".config/shell/env.sh"
    backup_if_exists ".config/shell/aliases.sh"
    backup_if_exists ".config/shell/init.sh"
    backup_if_exists ".config/shell/fzf-workflows.sh"
    backup_if_exists ".config/git/config"
    backup_if_exists ".config/git/ignore"
    backup_if_exists ".config/tmux/tmux.conf"
    backup_if_exists ".tmux.conf"
    backup_if_exists ".config/nvim"
    backup_if_exists ".tool-versions"

    # Always stow core, starship, git, tmux, nvim, asdf
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" core
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" starship
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" git
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" tmux
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" nvim
    stow -v -R -d "$DOTFILES_DIR" -t "$HOME" asdf

    # Stow the appropriate shell config
    case "$shell_name" in
        zsh)
            stow -v -R -d "$DOTFILES_DIR" -t "$HOME" zsh
            ok "Linked: core, starship, zsh"
            ;;
        bash)
            stow -v -R -d "$DOTFILES_DIR" -t "$HOME" bash
            ok "Linked: core, starship, bash"
            ;;
        *)
            stow -v -R -d "$DOTFILES_DIR" -t "$HOME" zsh
            stow -v -R -d "$DOTFILES_DIR" -t "$HOME" bash
            ok "Linked: core, starship, zsh, bash"
            ;;
    esac

    if [ -d "$BACKUP_DIR" ]; then
        warn "Your original configs were backed up to: $BACKUP_DIR"
    fi
}

# ── asdf: install plugins and versions from .tool-versions ──

setup_asdf() {
    if [ ! -d "$HOME/.asdf" ]; then
        warn "asdf not installed, skipping version setup"
        return
    fi

    # shellcheck disable=SC1091
    . "$HOME/.asdf/asdf.sh"

    local tool_versions="$HOME/.tool-versions"
    [ -f "$tool_versions" ] || return 0

    info "Installing asdf plugins and tool versions..."
    while IFS=' ' read -r plugin _version; do
        [ -z "$plugin" ] && continue
        [[ "$plugin" == \#* ]] && continue
        if ! asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
            asdf plugin add "$plugin"
        fi
    done < "$tool_versions"

    # Snap-installed aria2c is sandboxed and breaks node-build downloads;
    # hide it so node-build falls back to curl/wget
    local install_path="$PATH"
    if snap list aria2 &>/dev/null 2>&1; then
        install_path=$(echo "$PATH" | tr ':' '\n' | grep -v snap | tr '\n' ':' | sed 's/:$//')
    fi
    PATH="$install_path" asdf install
    ok "asdf tools installed"
}

# ── Create required directories ──

setup_dirs() {
    mkdir -p "$HOME/.local/bin"
    mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
    mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/bash"
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
}

# ── Main ──

main() {
    info "Bootstrapping dotfiles ($OS)..."

    case "$OS" in
        Darwin) install_deps_mac ;;
        Linux)  install_deps_linux ;;
        *)      error "Unsupported OS: $OS" ;;
    esac

    setup_dirs
    stow_packages
    setup_asdf

    echo ""
    ok "Done! Restart your shell or run: exec \$SHELL -l"
}

main "$@"
