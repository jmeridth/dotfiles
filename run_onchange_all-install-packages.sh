#!/bin/bash
set -e

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh ..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if which code >/dev/null 2>&1; then
  echo "Updating vscode to allow for holding down keys in vscode for vim ..."
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
fi
