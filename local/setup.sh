#!/bin/bash

DOTFILES=$(pwd)

if [[ "$OSTYPE" == "linux"* ]]; then
  ln -sf $DOTFILES/aliases.linux $HOME/.aliases.linux
  if [ -f /etc/redhat-release ]; then
    yum install -y cmake python-devel
  fi
  if [ -f /etc/lsb-release ]; then
    sudo apt-get install -y cmake python-dev
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $DOTFILES/aliases.osx $HOME/.aliases.osx
  xcode-select --install
  if ! which brew > /dev/null; then
    # install homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # install what is in the Brewfile
  brew bundle -v
  # allow for holding down keys in vscode for vim
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ln -sf $DOTFILES/local/aliases $HOME/.aliases
ln -sf $DOTFILES/local/curlrc $HOME/.curlrc
ln -sf $DOTFILES/../.editorconfig $HOME/.editorconfig
ln -sf $DOTFILES/../.gemrc $HOME/.gemrc
ln -sf $DOTFILES/../.gitconfig $HOME/.gitconfig
ln -sf $DOTFILES/../.pryrc $HOME/.pryrc
ln -sf $DOTFILES/../.pylintrc $HOME/.pylintrc
ln -sf $DOTFILES/../.vimrc $HOME/.vimrc
ln -sf $DOTFILES/../.zshrc $HOME/.zshrc

exec $SHELL
