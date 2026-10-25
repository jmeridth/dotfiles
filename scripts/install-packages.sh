#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/detect-os.sh"

if [[ "$OS_TYPE" == "Darwin" ]]; then
  # Install Xcode command line tools if needed
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing xcode command line tools ..."
    xcode-select --install
  fi

  # Install Homebrew if needed
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Build combined Brewfile based on hostname
  TMPFILE="$(mktemp)"
  cat "$REPO_DIR/Brewfile" > "$TMPFILE"

  if [[ "$HOSTNAME_TYPE" == "work" ]]; then
    echo "" >> "$TMPFILE"
    cat "$REPO_DIR/Brewfile.work" >> "$TMPFILE"
  fi

  if [[ "$HOSTNAME_TYPE" == "personal" ]]; then
    echo "" >> "$TMPFILE"
    cat "$REPO_DIR/Brewfile.personal" >> "$TMPFILE"
  fi

  echo "Installing Homebrew taps, packages, and casks ..."
  brew bundle --upgrade --file="$TMPFILE"
  rm -f "$TMPFILE"

elif [[ "$IS_DEBIAN" == true ]]; then
  # Install Homebrew if needed
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew ..."
    # Ignore global/system git config so GitHub https settings don't break the installer's clones
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # A fresh Linux Homebrew install isn't on PATH yet
  if ! command -v brew >/dev/null 2>&1 && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # Add the 1Password apt repository if needed (1password-cli isn't in Ubuntu's repos)
  if [ ! -f /etc/apt/sources.list.d/1password.list ]; then
    echo "Adding 1Password apt repository ..."
    ARCH="$(dpkg --print-architecture)"
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
      sudo gpg --dearmor --batch --yes --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$ARCH stable main" |
      sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
      sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
      sudo gpg --dearmor --batch --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  fi

  echo "Updating apt ..."
  sudo apt update -y

  echo "Installing Linux packages ..."
  sudo apt install -y \
    1password-cli \
    build-essential \
    cmake \
    curl \
    gcc \
    gh \
    jq \
    neovim \
    python-dev-is-python3 \
    shellcheck \
    tmux \
    yq \
    zsh

  brew bundle --upgrade --file="$REPO_DIR/Brewfile.linux"

else
  echo "Unsupported OS. Skipping package installation."
fi
