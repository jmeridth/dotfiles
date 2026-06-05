# My dotfiles

Used with my local dev environment.

## Setup

```bash
git clone git@github.com:jmeridth/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup
```

This will:

- Symlink config files to your home directory
- Symlink shared agent instructions to Codex and Claude locations
- Install packages via Homebrew (macOS) or apt (Debian)
- Install oh-my-zsh
- Configure VSCode vim key repeat (macOS)

## Structure

```text
setup                     # Entry point
scripts/
  detect-os.sh            # OS and hostname detection
  install-packages.sh     # Brew/apt package installation
  install-tools.sh        # oh-my-zsh, vscode config
  link-dotfiles.sh        # Symlink configs to ~/
configs/                  # Dotfiles and tool configs
  AGENTS.md               # Shared global agent instructions
  agents/skills/          # Shared user-level agent skills
Brewfile                  # Common Homebrew packages
Brewfile.work             # Work-specific packages
Brewfile.personal         # Personal-specific packages
```

Cheers,
JM
