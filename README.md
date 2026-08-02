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
- Symlink shared agent instructions and Claude config to your home directory
- Install packages via Homebrew (macOS) or apt (Debian)
- Install oh-my-zsh

## Claude Code skills

My Claude Code skills no longer live here. They moved to their own marketplace
repo, [jmeridth/skills](https://github.com/jmeridth/skills), and install as a
plugin so they work in every repo without symlinking.

```bash
claude plugins marketplace add jmeridth/skills
claude plugins install jmeridth-skills@jmeridth
```

Update later with:

```bash
claude plugins marketplace update jmeridth
```

## Structure

```text
setup                     # Entry point
scripts/
  detect-os.sh            # OS and hostname detection
  install-packages.sh     # Brew/apt package installation
  install-tools.sh        # oh-my-zsh
  link-dotfiles.sh        # Symlink configs to ~/
configs/                  # Dotfiles and tool configs
  AGENTS.md               # Shared global agent instructions
Brewfile                  # Common Homebrew packages
Brewfile.work             # Work-specific packages
Brewfile.personal         # Personal-specific packages
```

Cheers,
JM
