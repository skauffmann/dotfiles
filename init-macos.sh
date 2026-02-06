#!/bin/bash
set -e

# -----------------------------------
# macOS Initial Setup
# -----------------------------------

# Machine name
read -rp "Enter machine name: " NAME
if [[ -z "$NAME" ]]; then
  echo "Error: machine name cannot be empty."
  exit 1
fi

echo "Setting machine name to '${NAME}'..."
sudo scutil --set ComputerName "${NAME}"
sudo scutil --set LocalHostName "${NAME}"
sudo scutil --set HostName "${NAME}"

# Command Line Developer Tools
echo "Installing Xcode Command Line Tools..."
/usr/bin/xcode-select --install 2>/dev/null || echo "Already installed."
echo "Press Enter once the installation is complete."
read -r

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

# chezmoi
echo "Installing chezmoi..."
brew install chezmoi

# 1Password CLI
echo "Installing 1Password CLI..."
brew install --cask 1password-cli
op account add
eval "$(op signin)"

# Set Zsh as default shell
echo "Setting Zsh as default shell..."
which zsh | sudo tee -a /etc/shells
chsh -s "$(which zsh)"

# Clone dotfiles if needed
if [[ ! -d ~/workspace/dotfiles ]]; then
  echo "Cloning dotfiles..."
  mkdir -p ~/workspace
  git clone https://github.com/skauffmann/dotfiles.git ~/workspace/dotfiles
fi

# chezmoi init & apply
echo "Applying dotfiles with chezmoi..."
ln -sf ~/workspace/dotfiles ~/.local/share/chezmoi
chezmoi apply

echo "Done! You may want to restart your terminal."
