# aliases.sh — Unified alias system with fallback
# Sourced by both zsh and bash

# ── Tool replacements (transparent upgrade with fallback) ──

if command -v eza &>/dev/null; then
    alias ls='eza -a'
    alias ll='eza -l --git --icons'
    alias la='eza -la --git --icons'
    alias tree='eza --tree --icons'
else
    alias ll='ls -lh'
    alias la='ls -lAh'
fi

if command -v nvim &>/dev/null; then
    alias vim='nvim'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'
elif command -v batcat &>/dev/null; then
    # Debian/Ubuntu installs bat as batcat
    alias cat='batcat --paging=never'
    alias catp='batcat'
fi

if command -v fd &>/dev/null; then
    alias find='fd'
elif command -v fdfind &>/dev/null; then
    alias find='fdfind'
fi

if command -v rg &>/dev/null; then
    alias grep='rg'
fi

# ── Navigation shortcuts ──

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ── Common shortcuts ──

alias c='clear'
alias e='$EDITOR'
alias reload='exec $SHELL -l'

# ── Git shortcuts ──

alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gl='git lg'
alias gp='git push'
alias gpu='git pull'
alias ga='git add'
alias gcm='git commit -m'

# ── SSH shortcuts ──

alias buildssh='ssh -i ~/.ssh/id_rsa_vm dfoadmin@172.18.10.8'
alias devssh='ssh -i ~/.ssh/id_rsa_vm zinuo@172.18.10.4'

# ── Platform-specific ──

if [ "$DOTFILES_OS" = "darwin" ]; then
    alias flush-dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
fi
