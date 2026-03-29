# dotfiles

Stow-based, cross-platform (macOS/Linux) dotfiles with unified shell experience.

## Quick Start

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./bootstrap.sh
```

Restart your shell or run `exec $SHELL -l`.

## Structure

```
dotfiles/
├── core/       # Cross-shell: env, aliases, fzf workflows, tool init
├── zsh/        # Zsh entry point (.zshrc)
├── bash/       # Bash entry point (.bashrc)
├── git/        # Git config + global ignore
├── starship/   # Unified prompt (starship.toml)
├── tmux/       # Tmux config
├── nvim/       # Neovim (LazyVim)
├── Brewfile    # macOS Homebrew dependencies
└── bootstrap.sh
```

Each directory is a [GNU Stow](https://www.gnu.org/software/stow/) package — `stow <pkg>` symlinks its contents into `$HOME`.

## Architecture

**Core + Shell Adapter pattern**: all behavior logic lives in `core/.config/shell/`, shells (zsh/bash) are thin entry points that source it.

- `env.sh` — XDG dirs, PATH, platform detection, tool paths
- `aliases.sh` — transparent tool upgrades (eza/bat/fd/rg) with fallbacks
- `init.sh` — tool initialization (zoxide, fzf, starship, asdf)
- `fzf-workflows.sh` — interactive functions: `ff`, `fcd`, `fs`, `fbr`, `flog`, `fkill`

## Key Tools

| Tool | Replaces | Purpose |
|------|----------|---------|
| [eza](https://github.com/eza-community/eza) | ls | File listing with git status |
| [bat](https://github.com/sharkdp/bat) | cat | Syntax-highlighted file viewer |
| [fd](https://github.com/sharkdp/fd) | find | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | grep | Fast content search |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | cd | Smart directory jumper |
| [fzf](https://github.com/junegunn/fzf) | — | Fuzzy finder / interaction engine |
| [delta](https://github.com/dandavtom/delta) | diff | Better git diffs |
| [starship](https://starship.rs) | PS1 | Unified cross-shell prompt |

## FZF Workflows

| Command | Description |
|---------|-------------|
| `ff` | Find file → open in `$EDITOR` (with bat preview) |
| `fcd` | Find directory → cd |
| `fs [query]` | Full-text search (rg + fzf) → open at line |
| `fbr` | Git branch picker → checkout |
| `flog` | Git log picker → show commit |
| `fkill` | Process picker → kill |

## Local Overrides

Create `~/.config/shell/local.sh` for machine-specific config (gitignored). See `core/.config/shell/local.sh.example` for reference.

## Adding a New Package

1. Create a directory: `mkdir -p newpkg/.config/newpkg`
2. Add config files mirroring the home directory structure
3. Add `stow -v -d "$DOTFILES_DIR" -t "$HOME" newpkg` to `bootstrap.sh`
