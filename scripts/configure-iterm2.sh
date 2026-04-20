#!/bin/bash
set -e

# Configures iTerm2 settings programmatically.
# iTerm2 must be closed for changes to take effect, or restart it after running.

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Skipping iTerm2 configuration (not macOS)"
  exit 0
fi

echo "Configuring iTerm2..."

# Point iTerm2 at a custom preferences folder so we control the config
PREFS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/configs/iterm2"
mkdir -p "$PREFS_DIR"

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$PREFS_DIR"

if [[ -f "$PREFS_DIR/com.googlecode.iterm2.plist" ]]; then
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
else
  echo "No plist found in $PREFS_DIR — skipping LoadPrefsFromCustomFolder."
  echo "To enable: copy ~/Library/Preferences/com.googlecode.iterm2.plist into $PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool false
fi

# Set Nerd Font in the default profile via python (handles plist array structure)
python3 - <<EOF
import subprocess, plistlib, os, sys

plist_path = os.path.expanduser("~/Library/Preferences/com.googlecode.iterm2.plist")

# Read current prefs
result = subprocess.run(
    ["plutil", "-convert", "xml1", "-o", "-", plist_path],
    capture_output=True
)
prefs = plistlib.loads(result.stdout)

profiles = prefs.get("New Bookmarks", [])
for profile in profiles:
    if profile.get("Name") == "Default":
        profile["Normal Font"] = "JetBrainsMono-Regular 13"
        profile["Non Ascii Font"] = "JetBrainsMono-Regular 13"
        profile["Use Non-ASCII Font"] = True
        profile["Unlimited Scrollback"] = True
        print("Updated Default profile font to JetBrainsMono Nerd Font")
        print("Enabled unlimited scrollback")
        break
else:
    print("Default profile not found, skipping font update")

with open(plist_path, "wb") as f:
    plistlib.dump(prefs, f, fmt=plistlib.FMT_XML)
EOF

echo "Done. Restart iTerm2 for changes to take effect."
