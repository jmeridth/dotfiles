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
  brew install cmake coreutils ctags autoenv direnv curl wget
fi

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# powerline fonts
rm -rf $DEV_DIR/fonts
git clone https://github.com/powerline/fonts.git $DEV_DIR/fonts
cd $DEV_DIR/fonts
./install.sh

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
ln -sf $DOTFILES/git-completion.bash $HOME/.git-completion.bash
ln -sf $DOTFILES/git-prompt.sh $HOME/.git-prompt.sh

# TMUX
ln -sf $DOTFILES/tmux.conf $HOME/.tmux.conf

# RUBY
ln -sf $DOTFILES/gemrc $HOME/.gemrc
ln -sf $DOTFILES/pryrc $HOME/.pryrc
ln -sf $DOTFILES/rubocop.sh $HOME/.rubocop.sh

# PYTHON
ln -sf $DOTFILES/pylintrc $HOME/.pylintrc

exec $SHELL
