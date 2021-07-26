DOTFILES=$(pwd)
DEV_DIR=~/code


# CMAKE
if [[ "$OSTYPE" == "linux"* ]]; then
  if [ -f /etc/redhat-release ]; then
    yum install -y cmake python-devel
  fi
  if [ -f /etc/lsb-release ]; then
    sudo apt-get install -y cmake python-dev
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  xcode-select --install
  if ! which brew > /dev/null; then
    # install homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # install what is in the Brewfile
    brew bundle -v
  fi
  # allow for holding down keys in vscode for vim
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# pyenv setup
cd $DOTFILES
./install_rvm.sh

# pyenv setup
cd $DOTFILES
./install_pyenv.sh

# VIM
ln -sf $DOTFILES/vimrc $HOME/.vimrc

# ZSHRC
ln -sf $DOTFILES/zshrc $HOME/.zshrc

# EDITORCONFIG
ln -sf $DOTFILES/editorconfig $HOME/.editorconfig

# ALIASES
ln -sf $DOTFILES/aliases $HOME/.aliases
ln -sf $DOTFILES/aliases.osx $HOME/.aliases.osx
ln -sf $DOTFILES/aliases.linux $HOME/.aliases.linux

# GIT
ln -sf $DOTFILES/gitconfig $HOME/.gitconfig

# TMUX
ln -sf $DOTFILES/tmux.conf $HOME/.tmux.conf

# CURL
ln -sf $DOTFILES/curlrc $HOME/.curlrc

# RUBY
ln -sf $DOTFILES/gemrc $HOME/.gemrc
ln -sf $DOTFILES/pryrc $HOME/.pryrc
ln -sf $DOTFILES/rubocop.sh $HOME/.rubocop.sh

# PYTHON
ln -sf $DOTFILES/pylintrc $HOME/.pylintrc

exec $SHELL
