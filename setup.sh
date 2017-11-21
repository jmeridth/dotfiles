DOTFILES=$(pwd)
DEV_DIR=~/code

./update_scripts.sh

# CMAKE
if [[ "$OSTYPE" == "linux"* ]]; then
  if [ -f /etc/redhat-release ]; then
    yum install -y cmake python-devel
  fi
  if [ -f /etc/lsb-release ]; then
    sudo apt-get install -y cmake python-dev neovim
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install cmake
  brew install coreutils
fi

# powerline fonts
rm -rf $DEV_DIR/fonts
git clone https://github.com/powerline/fonts.git $DEV_DIR/fonts
cd $DEV_DIR/fonts
./install.sh

cd $DOTFILES

# VIM
ln -sf $DOTFILES/vimrc $HOME/.vimrc
ln -sf $HOME/.vimrc $HOME/.config/nvim/init.vim

# VIM-PLUG INSTALL
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +q +q!

# BASH_PROFILE
ln -sf $DOTFILES/bash_profile $HOME/.bash_profile

# BASHRC
ln -sf $DOTFILES/bashrc $HOME/.bashrc
ln -sf $DOTFILES/bashrc.osx $HOME/.bashrc.osx
ln -sf $DOTFILES/bashrc.linux $HOME/.bashrc.linux

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
