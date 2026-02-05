# ~/.dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- Secrets managed with [1Password CLI](https://developer.1password.com/docs/cli/) (API tokens, SSH signing key, credentials)
- Modern shell with [Oh-My-Zsh](https://ohmyz.sh/), [Spaceship](https://spaceship-prompt.sh/) prompt, autosuggestions & syntax highlighting
- Declarative package management via [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- Node.js version management with [NVM](https://github.com/nvm-sh/nvm) and auto-installed global packages
- Per-project environment with [direnv](https://direnv.net/) and [pyenv](https://github.com/pyenv/pyenv)
- Git commit signing with 1Password SSH keys

## Quick Start

On a fresh macOS, run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/skauffmann/dotfiles/main/init-macos.sh)
```

This will set the machine name, install Xcode CLI tools, Homebrew, 1Password CLI, chezmoi, clone this repo, and apply all dotfiles.

### Manual Setup

### 1. Install prerequisites

```bash
# Command Line Developer Tools
/usr/bin/xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# chezmoi
brew install chezmoi
```

### 2. Setup 1Password CLI

```bash
brew install --cask 1password-cli
op account add
eval $(op signin)
```

### 3. Install dotfiles

```bash
chezmoi init --apply skauffmann
```

Or, if cloning manually:

```bash
git clone git@github.com:skauffmann/dotfiles.git ~/workspace/dotfiles
ln -s ~/workspace/dotfiles/ ~/.local/share/chezmoi
chezmoi apply
```

### 4. Change default shell to zsh

```bash
which zsh | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

## Repository Structure

```
.
├── .chezmoiroot                   # Sets home/ as chezmoi source directory
└── home/                          # Chezmoi source directory
    ├── .chezmoidata/
    │   ├── packages.toml          # Homebrew taps, brews, casks & MAS apps
    │   └── nvm.toml               # Node.js versions to install
    ├── .chezmoiscripts/
    │   ├── run_onchange_01-…      # Auto-install packages when data changes
    │   └── run_onchange_02-…      # Auto-install Node versions when data changes
    ├── dot_config/
    │   ├── direnv/direnvrc        # Direnv + NVM integration
    │   ├── gh/                    # GitHub CLI config
    │   ├── private_dot_jira/      # JIRA CLI config (1Password secrets)
    │   └── zsh/
    │       ├── alias              # Shell aliases
    │       ├── functions          # Shell functions
    │       └── private_exports    # Sensitive env vars (1Password)
    ├── dot_gitignore              # Global gitignore
    ├── dot_nvm/
    │   └── default-packages.tmpl  # NPM packages auto-installed per Node version
    ├── dot_npmrc.tmpl             # NPM config (1Password auth token)
    ├── dot_okta_aws_login_config.tmpl  # Okta AWS profiles
    ├── dot_worktree.json          # Worktree tool config
    ├── dot_zshrc.tmpl             # Main zsh entrypoint
    └── private_dot_gitconfig      # Git config (SSH signing, delta, diff-so-fancy)
```

### Naming Conventions

| Prefix          | Description                                    |
| --------------- | ---------------------------------------------- |
| `dot_`          | Maps to `.filename` in home directory          |
| `private_`      | File with 600 permissions                      |
| `.tmpl`         | Go template, rendered by chezmoi at apply time |
| `run_onchange_` | Script runs when its watched content changes   |

## What's Included

### Packages

Defined in [`home/.chezmoidata/packages.toml`](home/.chezmoidata/packages.toml) and auto-installed via `brew bundle`:

| Type  | Count | Examples                                                     |
| ----- | ----- | ------------------------------------------------------------ |
| Taps  | 1     | hashicorp/tap                                                |
| Brews | 63    | git, nvm, pyenv, fzf, jq, terraform, awscli, ffmpeg, direnv |
| Casks | 14    | 1password-cli, ghostty, visual-studio-code, orbstack, slack  |
| MAS   | 12    | 1Password, Xcode, Pixelmator, iMovie, WhatsApp              |

### NPM Global Packages

Defined in the same file and auto-installed with each Node version via NVM:

`typescript`, `vercel`, `netlify-cli`, `create-next-app`, `create-vite`, `create-astro`, `create-hono`, `expo-cli`, `eas-cli`, `@shopify/create-app`, `@skauffmann/worktree`, and more.

### Node.js Versions

Defined in [`home/.chezmoidata/nvm.toml`](home/.chezmoidata/nvm.toml):

- Node 22 (default)
- Node 24

### Zsh

- Oh-My-Zsh with plugins: git, zsh-autosuggestions, zsh-syntax-highlighting, macos, vscode, npm, yarn, pj, cmdtime
- Spaceship prompt theme
- Modular config sourced from `~/.config/zsh/` (aliases, functions, exports)
- Direnv and pyenv integration

### Git

- SSH commit signing via 1Password
- Diff pager: diff-so-fancy
- Interactive rebase filter: delta
- Merge conflict style: diff3
- Default branch: main

### AWS / Okta

- 6 AWS profiles (dev/stg/prd for two orgs) via Okta SSO
- Credentials injected from 1Password at apply time

## Templates & Secrets

Template files (`.tmpl`) use Go template syntax with 1Password integration:

```
{{ onepasswordRead "op://Vault/Item/Field" }}
```

Secrets (API tokens, SSH keys, credentials) are **never stored in the repo** — they are read from 1Password at `chezmoi apply` time.

Files using 1Password secrets:
- `dot_zshrc.tmpl`
- `dot_npmrc.tmpl`
- `dot_okta_aws_login_config.tmpl`
- `dot_config/private_dot_jira/dot_config.yml.tmpl`
- `dot_config/zsh/private_exports`

## Development Workflow

Symlink chezmoi's source directory to your working copy:

```bash
ln -s ~/workspace/dotfiles/ ~/.local/share/chezmoi
```

Then iterate locally:

```bash
chezmoi diff           # Preview changes
chezmoi apply          # Apply changes to ~/
chezmoi apply --dry-run # Dry run without applying
```

### Updating

Pull and apply latest changes from remote:

```bash
chezmoi update
```

## License

MIT
