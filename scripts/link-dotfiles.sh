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

echo "Linking hostname-specific Claude skills ..."

# shellcheck source=scripts/detect-os.sh
source "$SCRIPT_DIR/detect-os.sh"

SHARED_SKILLS_DIR="$CONFIGS_DIR/claude/skills"
HOSTNAME_SKILLS_DIR="$CONFIGS_DIR/$HOSTNAME_TYPE/claude/skills"

# Remove stale symlinks pointing into any hostname-specific skills dir
# (handles switching machines or skills moving to shared)
for link_path in "$SHARED_SKILLS_DIR"/*/; do
  link_path="${link_path%/}"
  [[ -L "$link_path" ]] || continue
  target="$(readlink "$link_path")"
  if [[ "$target" != *"/personal/claude/skills/"* ]] && [[ "$target" != *"/work/claude/skills/"* ]]; then
    continue
  fi
  skill="$(basename "$link_path")"
  if [[ ! -d "$HOSTNAME_SKILLS_DIR/$skill" ]]; then
    echo "  removing stale skill symlink: $skill"
    rm "$link_path"
  fi
done

# Link skills for the current hostname
if [[ -d "$HOSTNAME_SKILLS_DIR" ]]; then
  for skill_dir in "$HOSTNAME_SKILLS_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill="$(basename "${skill_dir%/}")"
    link_file "$skill_dir" "$SHARED_SKILLS_DIR/$skill"
  done
fi
