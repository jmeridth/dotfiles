#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh ..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Configure VSCode vim key repeat on macOS
if [[ "$OS_TYPE" == "Darwin" ]]; then
  if command -v code >/dev/null 2>&1; then
    echo "Updating vscode to allow for holding down keys in vscode for vim ..."
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  fi
fi

# map caps lock to esc in Ubuntu
if [[ "$IS_DEBIAN" == true ]]; then
  echo "Mapping caps lock to escape on Linux ..."
  setxkbmap -option caps:escape
  setxkbmap -option caps:swapescape

  echo "Set ctrl+tab to alternate tabs in terminal ..."
  gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Tab'
  gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control><Shift>Tab'
fi
