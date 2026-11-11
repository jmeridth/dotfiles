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

  # zshrc sets HOMEBREW_NO_AUTO_UPDATE, so refresh the index explicitly.
  echo "Updating Homebrew ..."
  brew update

  echo "Installing Homebrew taps, packages, and casks ..."
  brew bundle --upgrade --file="$TMPFILE"
  rm -f "$TMPFILE"

elif [[ "$IS_DEBIAN" == true ]]; then
  # Install Homebrew if needed
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Docker Engine from Docker's apt repo. Ubuntu derivatives set UBUNTU_CODENAME.
  DOCKER_DISTRO=""
  DOCKER_SUITE=""
  if [[ -n "${UBUNTU_CODENAME:-}" ]]; then
    DOCKER_DISTRO="ubuntu"
    DOCKER_SUITE="$UBUNTU_CODENAME"
  elif [[ "$DISTRO_ID" == "debian" ]]; then
    DOCKER_DISTRO="debian"
    DOCKER_SUITE="$VERSION_CODENAME"
  fi

  DOCKER_PACKAGES=()
  if [[ -n "$DOCKER_DISTRO" ]]; then
    echo "Adding Docker apt repository ..."
    DOCKER_KEY_FPR="9DC858229FC7DD38854AE2D88D81803C0EBFCD88"
    DOCKER_KEY_TMP="$(mktemp)"
    sudo apt install -y ca-certificates curl gnupg
    curl -fsSL "https://download.docker.com/linux/$DOCKER_DISTRO/gpg" -o "$DOCKER_KEY_TMP"
    if ! gpg --show-keys --with-colons "$DOCKER_KEY_TMP" | grep -q "^fpr:::::::::$DOCKER_KEY_FPR:"; then
      echo "Docker apt key fingerprint mismatch. Aborting." >&2
      rm -f "$DOCKER_KEY_TMP"
      exit 1
    fi
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo install -m 0644 "$DOCKER_KEY_TMP" /etc/apt/keyrings/docker.asc
    rm -f "$DOCKER_KEY_TMP"
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DOCKER_DISTRO
Suites: $DOCKER_SUITE
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    DOCKER_PACKAGES=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
  else
    echo "No Docker apt repository for $DISTRO_ID. Skipping Docker."
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
    "${DOCKER_PACKAGES[@]}"

  # The docker group grants root-equivalent access. Takes effect on next login.
  if [[ ${#DOCKER_PACKAGES[@]} -gt 0 ]] && ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    echo "Added $USER to the docker group. Log out and back in to use docker without sudo."
  fi

  echo "Updating Homebrew ..."
  brew update

  brew bundle --upgrade --file="Brewfile.linux"

else
  echo "Unsupported OS. Skipping package installation."
fi
