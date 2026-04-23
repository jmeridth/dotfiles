#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/detect-os.sh"

# Configures different things for a fresh Ubuntu setup

if [[ "$IS_UBUNTU" != true ]]; then
  echo "Skipping setup (not Ubuntu)"
  exit 0
fi

echo "Setting up..."

echo "map caps lock to escape"
setxkbmap -option caps:swapescape

echo "set ctrl+tab to allow switch between terminal tabs"
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Tab'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control><Shift>Tab'

check_for_nerd_fonts=$(fc-list | grep "Ubuntu Nerd Font >&/dev/null")
if [ "$check_for_nerd_fonts" -eq 1 ]; then
  echo "set up nerd fonts"
  latest_nerd_fonts_version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.tag_name')
  wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/"$latest_nerd_fonts_version"/Ubuntu.zip \
  && cd ~/.local/share/fonts \
  && unzip Ubuntu.zip \
  && rm Ubuntu.zip \
  && fc-cache -fv
fi

echo "Configuring git for Linux SSH signing ..."
git config --file "$HOME/.gitconfig.local" gpg.ssh.program ssh-keygen
git config --file "$HOME/.gitconfig.local" user.signingkey ~/.ssh/id_ed25519_sign

echo "Done..."
