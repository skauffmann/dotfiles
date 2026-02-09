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
- `run_once_` prefix → script that runs only once per machine

### Templates & Secrets

Template files use Go template syntax with 1Password integration:
```
{{ onepasswordRead "op://Vault/Item/Field" }}
```
Secrets (API tokens, credentials) are never stored in the repo — they are read from 1Password at apply time.

### Package Management

Packages are defined in `home/.chezmoidata/packages.toml` with five sections:
- `taps` — Homebrew taps
- `brews` — Homebrew formulae
- `casks` — Homebrew casks (GUI apps)
- `mas` — Mac App Store apps (by ID)
- `npms` — NPM global packages (auto-installed per Node version via NVM)

Packages are split into **common** (installed on all machines) and **role-specific** (installed based on the host's assigned roles). See Roles below.

The script `home/.chezmoiscripts/run_onchange_01-darwin-install-packages.sh.tmpl` auto-runs `brew bundle` when `packages.toml` or `hosts.toml` changes during `chezmoi apply`.

### Roles & Conditional Config

Host-to-role mapping is defined in `home/.chezmoidata/hosts.toml`. Each hostname maps to a list of roles and optional package excludes.

Five roles exist: `dev`, `dev-xcode`, `eurosport`, `office`, `personal`. Role-specific packages are defined under `[packages.darwin.roles.<role>]` in `packages.toml`.

`home/.chezmoiignore` conditionally excludes files based on roles (e.g., Jira/Okta configs are only deployed when the `eurosport` role is present). Templates like `private_exports.tmpl` also conditionally inject secrets based on roles.

### Zsh Configuration

`dot_zshrc.tmpl` is the entrypoint. It sources modular config from `~/.config/zsh/`:
- `alias` — shell aliases
- `functions` — shell functions (port management, cleanup utilities)
- `private_exports.tmpl` — sensitive environment variables (role-conditional, 1Password)

Uses Oh-My-Zsh with plugins for git, autosuggestions, syntax highlighting, npm, yarn, and project jump.

### App Data Backup/Restore

`home/.chezmoiscripts/run_once_03-darwin-restore-app-data.sh.tmpl` restores MongoDB Compass connections and TablePlus data from 1Password on first run. The `backup-apps` shell function (in `dot_config/zsh/functions`) backs up these same apps to 1Password.

### AWS Config

`home/dot_aws/private_config.tmpl` — AWS CLI config with credentials injected from 1Password.

### Worktree Configuration

`dot_worktree.json` defines project defaults and post-clone scripts (direnv allow, claude trust) for the `worktree` tool.
