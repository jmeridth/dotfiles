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
- Install Claude Code marketplaces and plugins (skipped if `claude` is not installed)

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

## Claude Code settings and plugins

`configs/claude/settings.json` is intentionally untracked. Claude Code writes
plugin and marketplace state into it at runtime, so tracking it risks leaking
private marketplace refs into this public repo. Instead:

- `configs/claude/settings.json.example` (tracked) holds the public-safe
  baseline. `scripts/install-claude-plugins.sh` copies it to `settings.json`
  on fresh machines.
- Public marketplaces and plugins are listed in
  `scripts/install-claude-plugins.sh` and installed via the `claude` CLI.
- Private marketplaces and plugins go in `~/.claude-plugins.local` (never
  committed, lives in `$HOME` outside this repo). The install script sources
  it if present, so `add_marketplace` and `install_plugin` are available:

```bash
# ~/.claude-plugins.local
add_marketplace "some-org/private-marketplace"
install_plugin  "some-plugin@some-marketplace"
```

## Structure

```text
setup                       # Entry point
scripts/
  detect-os.sh              # OS and hostname detection
  install-packages.sh       # Brew/apt package installation
  install-tools.sh          # oh-my-zsh
  install-claude-plugins.sh # Claude Code marketplaces and plugins
  link-dotfiles.sh          # Symlink configs to ~/
configs/                    # Dotfiles and tool configs
  AGENTS.md                 # Shared global agent instructions
Brewfile                    # Common Homebrew packages
Brewfile.work               # Work-specific packages
Brewfile.personal           # Personal-specific packages
```

Cheers,
JM
