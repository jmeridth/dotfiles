DOTFILES=$(pwd)
DEV_DIR=~/code

# CMAKE
if [[ "$OSTYPE" == "linux"* ]]; then
  ln -sf $DOTFILES/local/aliases.linux $HOME/.aliases.linux
  if [ -f /etc/redhat-release ]; then
    yum install -y cmake python-devel
  fi
  if [ -f /etc/lsb-release ]; then
    sudo apt-get install -y cmake python-dev
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $DOTFILES/local/aliases.osx $HOME/.aliases.osx
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

# rbenv_gemsets setup
#cd $DOTFILES
#./install_rbenv_gemsets.sh

# VIM
ln -sf $DOTFILES/.vimrc $HOME/.vimrc

# ZSHRC
ln -sf $DOTFILES/.zshrc $HOME/.zshrc

# EDITORCONFIG
ln -sf $DOTFILES/.editorconfig $HOME/.editorconfig

# ALIASES
ln -sf $DOTFILES/local/aliases $HOME/.aliases

# GIT
ln -sf $DOTFILES/.gitignore $HOME/.gitignore
ln -sf $DOTFILES/.gitconfig $HOME/.gitconfig

# CURL
ln -sf $DOTFILES/local/curlrc $HOME/.curlrc

# RUBY
ln -sf $DOTFILES/.gemrc $HOME/.gemrc
ln -sf $DOTFILES/.pryrc $HOME/.pryrc

# PYTHON
ln -sf $DOTFILES/.pylintrc $HOME/.pylintrc

exec $SHELL
