# fzf-workflows.sh — fzf as interaction engine
# Requires: fzf, and optionally bat, rg, fd

# Guard: skip if fzf not available
command -v fzf &>/dev/null || return 0

# ── ff: file finder → open in $EDITOR ──
ff() {
    local file
    if command -v bat &>/dev/null; then
        file=$(fzf --preview 'bat --color=always --line-range=:200 {}')
    elif command -v batcat &>/dev/null; then
        file=$(fzf --preview 'batcat --color=always --line-range=:200 {}')
    else
        file=$(fzf --preview 'head -200 {}')
    fi
    [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# ── fcd: directory finder → cd ──
# Named fcd to avoid conflict with fd (the find replacement)
fcd() {
    local dir
    if command -v fd &>/dev/null; then
        dir=$(fd --type d --hidden --follow --exclude .git | fzf)
    elif command -v fdfind &>/dev/null; then
        dir=$(fdfind --type d --hidden --follow --exclude .git | fzf)
    else
        dir=$(find . -type d -not -path '*/.git/*' 2>/dev/null | fzf)
    fi
    [ -n "$dir" ] && cd "$dir"
}

# ── fs: content search → open at line ──
fs() {
    local query="${1:-}"
    local selection

    if ! command -v rg &>/dev/null; then
        echo "fs requires ripgrep (rg)" >&2
        return 1
    fi

    selection=$(
        rg --color=always --line-number --no-heading ${query:+-- "$query"} |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null || batcat --color=always --highlight-line {2} {1} 2>/dev/null || head -200 {1}' \
            --preview-window '+{2}-10'
    )

    if [ -n "$selection" ]; then
        local file line
        file=$(echo "$selection" | cut -d: -f1)
        line=$(echo "$selection" | cut -d: -f2)
        ${EDITOR:-vim} "+$line" "$file"
    fi
}

# ── fbr: git branch picker → checkout ──
fbr() {
    local branch
    branch=$(
        git branch --all --sort=-committerdate |
        sed 's/^[* ]*//' |
        sed 's|^remotes/origin/||' |
        sort -u |
        fzf --preview 'git log --oneline --graph --color=always {} -- 2>/dev/null | head -20'
    )
    [ -n "$branch" ] && git checkout "$branch"
}

# ── flog: git log picker → show commit ──
flog() {
    local commit
    commit=$(
        git log --oneline --graph --color=always --decorate --all |
        fzf --ansi --no-sort |
        grep -oE '[a-f0-9]{7,}' |
        head -1
    )
    [ -n "$commit" ] && git show "$commit"
}

# ── fkill: process picker → kill ──
fkill() {
    local pid
    pid=$(
        ps -ef |
        sed 1d |
        fzf --multi |
        awk '{print $2}'
    )
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}
