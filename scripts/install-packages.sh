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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
    yq

  brew bundle --upgrade --file="Brewfile.linux"

else
  echo "Unsupported OS. Skipping package installation."
fi
