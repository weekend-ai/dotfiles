# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A stow-based, cross-platform (macOS/Linux) dotfiles system designed as a unified development runtime layer. Not a collection of configs — an engineered system with a 5-layer architecture.

## Architecture

**Core + Adapter pattern**: all behavior logic lives in `core/.config/shell/`, shells (zsh/bash) are thin entry points that source it.

``` shell
Layer 5: Bootstrap    → bootstrap.sh (install deps, stow symlinks, asdf setup)
Layer 4: Platform     → OS detection in env.sh ($DOTFILES_OS = darwin|linux)
Layer 3: Tool         → git, tmux, fzf, starship, nvim, asdf
Layer 2: Shell        → zsh/.zshrc and bash/.bashrc (adapters only)
Layer 1: Core         → core/.config/shell/{env,aliases,init,fzf-workflows}.sh
```

**Source order** (both shells): `env.sh` → `aliases.sh` → shell-specific config → `init.sh` (which loads `fzf-workflows.sh`)

## Key Design Patterns

- **Transparent tool upgrade with fallback**: aliases like `ls→eza`, `cat→bat`, `vim→nvim` degrade gracefully if tools are missing (`command -v` guards)
- **FZF as interaction engine**: `ff`, `fcd`, `fs`, `fbr`, `flog`, `fkill` — universal search-driven operations
- **Local overrides**: `~/.config/shell/local.sh` (gitignored) for machine-specific config; see `local.sh.example`
- **XDG compliance**: all state/cache goes to `$XDG_STATE_HOME`/`$XDG_CACHE_HOME`, not dotfiles in `$HOME`

## Critical Warning

**All files in this repo are symlinked into `$HOME` via GNU Stow.** Editing files here directly modifies the user's live environment. Changes to `core/.config/shell/aliases.sh` immediately affect every new shell. Changes to `nvim/.config/nvim/lua/plugins/example.lua` immediately affect Neovim. Never overwrite or revert these files without explicit user consent.

## Stow Package Structure

Each top-level directory is a stow package. Internal paths mirror `$HOME`:

- `core/.config/shell/env.sh` → `~/.config/shell/env.sh`
- `git/.config/git/config` → `~/.config/git/config`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `asdf/.tool-versions` → `~/.tool-versions`

## Bootstrap

```bash
./bootstrap.sh   # detects OS, installs deps (brew/apt/dnf/pacman), stows all packages, sets up asdf
```

Bootstrap is idempotent: uses `stow --adopt --restow` + `git checkout -- .` to handle conflicts. Existing configs are backed up to `~/.dotfiles_backup/`.

## Adding a New Package

1. `mkdir -p newpkg/.config/newpkg`
2. Add config files mirroring home directory structure
3. Add `stow "${stow_flags[@]}" newpkg` to `bootstrap.sh`
4. Add `backup_if_exists` entries for files that might conflict

## Neovim

Built on LazyVim. Plugin configs go in `nvim/.config/nvim/lua/plugins/`. Base config in `lua/config/{options,keymaps,autocmds,lazy}.lua`. Plugin versions locked in `lazy-lock.json`.
