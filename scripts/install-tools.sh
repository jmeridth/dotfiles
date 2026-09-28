#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM (Tmux Plugin Manager) ..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh ..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Claude Code via the native installer if not present
CLAUDE_BIN="$HOME/.local/bin/claude"
if [ ! -x "$CLAUDE_BIN" ]; then
  echo "Installing Claude Code ..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

echo "Updating Claude Code ..."
"$CLAUDE_BIN" update

# Install latest Terraform via tfenv if no versions are installed
if command -v tfenv >/dev/null 2>&1 && ! tfenv list >/dev/null 2>&1; then
  echo "Installing Terraform via tfenv ..."
  tfenv install latest
  tfenv use latest
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
