# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi**-managed dotfiles repository for macOS. Chezmoi handles templating, secret injection (via 1Password), and declarative package management.

## Key Commands

```bash
chezmoi apply          # Apply all dotfiles to ~/
chezmoi apply --dry-run # Preview changes without applying
chezmoi diff           # Show diff of what would change
chezmoi status         # Show which files differ from target
chezmoi edit <file>    # Edit a source file (opens from source dir)
chezmoi add <file>     # Add a new file from ~/ into the source dir
```

After cloning, the repo must be symlinked:
```bash
ln -s ~/workspace/dotfiles/ ~/.local/share/chezmoi
```

## Architecture

### Source Directory

The `.chezmoiroot` file sets `home/` as the chezmoi source directory. All managed files live under `home/`.

### Chezmoi Naming Conventions

- `dot_` prefix → `.` in target (e.g., `dot_zshrc.tmpl` → `~/.zshrc`)
- `private_` prefix → file permissions 0600, hidden from diff output
- `.tmpl` suffix → Go template, rendered before applying
- `run_onchange_` prefix → script that runs when its content (or watched data) changes

### Templates & Secrets

Template files use Go template syntax with 1Password integration:
```
{{ onepasswordRead "op://Vault/Item/Field" }}
```
Secrets (API tokens, credentials) are never stored in the repo — they are read from 1Password at apply time.

### Package Management

Packages are defined in `home/.chezmoidata/packages.toml` with four sections:
- `taps` — Homebrew taps
- `brews` — Homebrew formulae
- `casks` — Homebrew casks (GUI apps)
- `mas` — Mac App Store apps (by ID)

The script `home/.chezmoiscripts/run_onchange_darwin-install-packages.sh.tmpl` auto-runs `brew bundle` when `packages.toml` changes during `chezmoi apply`.

### Zsh Configuration

`dot_zshrc.tmpl` is the entrypoint. It sources modular config from `~/.config/zsh/`:
- `alias` — shell aliases
- `functions` — shell functions (port management, cleanup utilities)
- `private_exports` — sensitive environment variables

Uses Oh-My-Zsh with plugins for git, autosuggestions, syntax highlighting, npm, yarn, and project jump.

### Worktree Configuration

`dot_worktree.json` defines project defaults and post-clone scripts (direnv allow, claude trust) for the `worktree` tool.
