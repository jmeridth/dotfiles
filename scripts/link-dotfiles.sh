#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CONFIGS_DIR="$REPO_DIR/configs"

link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  already linked: $dest"
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "  backing up:     $dest -> ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -sf "$src" "$dest"
  echo "  linked:         $dest -> $src"
}

echo "Linking dotfiles ..."

link_file "$CONFIGS_DIR/zshrc"             "$HOME/.zshrc"
link_file "$CONFIGS_DIR/bash_profile"      "$HOME/.bash_profile"
link_file "$CONFIGS_DIR/zprofile"          "$HOME/.zprofile"
link_file "$CONFIGS_DIR/aliases"           "$HOME/.aliases"
link_file "$CONFIGS_DIR/gitconfig"         "$HOME/.gitconfig"
link_file "$CONFIGS_DIR/gitignore"         "$HOME/.gitignore"
link_file "$CONFIGS_DIR/vimrc"             "$HOME/.vimrc"
link_file "$CONFIGS_DIR/editorconfig"      "$HOME/.editorconfig"
link_file "$CONFIGS_DIR/curlrc"            "$HOME/.curlrc"
link_file "$CONFIGS_DIR/gemrc"             "$HOME/.gemrc"
link_file "$CONFIGS_DIR/tmux.conf"         "$HOME/.tmux.conf"
link_file "$CONFIGS_DIR/tmuxline_snapshot" "$HOME/.tmuxline_snapshot"

echo "Linking claude config ..."

# Link the entire claude directory
link_file "$CONFIGS_DIR/claude" "$HOME/.claude"
