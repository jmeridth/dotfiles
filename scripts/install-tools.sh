#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

UBUNTU_NO_KEY_UPDATE=false
for arg in "$@"; do
  case "$arg" in
    ubuntu-no-key-update) UBUNTU_NO_KEY_UPDATE=true ;;
  esac
done

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

# Point the Docker CLI at Homebrew's plugin dir so buildx and compose load
DOCKER_PLUGIN_DIR="/opt/homebrew/lib/docker/cli-plugins"
DOCKER_CONFIG_FILE="$HOME/.docker/config.json"
if [[ "$OS_TYPE" == "Darwin" ]] && command -v jq >/dev/null 2>&1; then
  mkdir -p "$HOME/.docker"
  [ -s "$DOCKER_CONFIG_FILE" ] || echo '{}' > "$DOCKER_CONFIG_FILE"
  if ! jq -e --arg d "$DOCKER_PLUGIN_DIR" '(.cliPluginsExtraDirs // []) | index($d)' "$DOCKER_CONFIG_FILE" >/dev/null; then
    echo "Adding Homebrew Docker CLI plugin dir to $DOCKER_CONFIG_FILE ..."
    DOCKER_CONFIG_TMP="$(mktemp)"
    jq --arg d "$DOCKER_PLUGIN_DIR" '.cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) + [$d])' "$DOCKER_CONFIG_FILE" > "$DOCKER_CONFIG_TMP"
    cat "$DOCKER_CONFIG_TMP" > "$DOCKER_CONFIG_FILE"
    rm -f "$DOCKER_CONFIG_TMP"
  fi
fi

# Install latest Terraform via tfenv if no versions are installed
if command -v tfenv >/dev/null 2>&1 && ! tfenv list >/dev/null 2>&1; then
  echo "Installing Terraform via tfenv ..."
  tfenv install latest
  tfenv use latest
fi

# map caps lock to esc in Ubuntu (skipped with ubuntu-no-key-update)
if [[ "$IS_DEBIAN" == true && "$UBUNTU_NO_KEY_UPDATE" == true ]]; then
  echo "Skipping Ubuntu key mapping updates (ubuntu-no-key-update) ..."
elif [[ "$IS_DEBIAN" == true && "$UBUNTU_NO_KEY_UPDATE" == false ]]; then
  echo "Mapping caps lock to escape on Linux ..."
  setxkbmap -option caps:escape
  setxkbmap -option caps:swapescape

  echo "Set ctrl+tab to alternate tabs in terminal ..."
  gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Tab'
  gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control><Shift>Tab'
fi
