#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$REPO_DIR/configs/claude"

MARKETPLACES=(
  "mattpocock/skills"
  "jmeridth/skills"
  "ayghri/i-have-adhd"
  "anthropics/claude-plugins-community"
)

PLUGINS=(
  "gopls-lsp@claude-plugins-official"
  "superpowers@claude-plugins-official"
  "claude-code-setup@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "frontend-design@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "github@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "mcp-server-dev@claude-plugins-official"
  "slack@claude-plugins-official"
  "mattpocock-skills@mattpocock"
  "jmeridth-skills@jmeridth"
  "i-have-adhd@i-have-adhd"
  "eli5@claude-community"
)

add_marketplace() {
  local repo="$1"
  local out
  if out=$(claude plugin marketplace add "$repo" 2>&1); then
    echo "  marketplace ok:      $repo"
  else
    echo "  marketplace skipped: $repo ($(echo "$out" | head -1))"
  fi
}

install_plugin() {
  local plugin="$1"
  local out
  if out=$(claude plugin install "$plugin" 2>&1); then
    echo "  plugin ok:           $plugin"
  else
    echo "  plugin skipped:      $plugin ($(echo "$out" | head -1))"
  fi
}

echo "Configuring Claude Code plugins ..."

if ! command -v claude >/dev/null 2>&1; then
  echo "  claude CLI not found, skipping plugin setup"
  exit 0
fi

if command -v codex >/dev/null 2>&1; then
  echo "  codex CLI found (no plugin system, nothing to install for it)"
fi

# Seed the live settings.json from the tracked template on fresh machines.
# The live file is intentionally untracked: Claude Code writes plugin and
# marketplace state into it at runtime, and private marketplace refs must
# never land in this public repo.
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  echo "  seeding settings.json from settings.json.example"
  cp "$CLAUDE_DIR/settings.json.example" "$CLAUDE_DIR/settings.json"
fi

for repo in "${MARKETPLACES[@]}"; do
  add_marketplace "$repo"
done

for plugin in "${PLUGINS[@]}"; do
  install_plugin "$plugin"
done

# Private marketplaces and plugins stay out of this repo. Put them in
# ~/.claude-plugins.local, which may call add_marketplace / install_plugin:
#   add_marketplace "some-org/private-marketplace"
#   install_plugin  "some-plugin@some-marketplace"
LOCAL_PLUGINS="$HOME/.claude-plugins.local"
if [ -f "$LOCAL_PLUGINS" ]; then
  echo "  applying local overrides from $LOCAL_PLUGINS"
  # shellcheck source=/dev/null
  source "$LOCAL_PLUGINS"
fi
