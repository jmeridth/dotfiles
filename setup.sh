DOTFILES=$(pwd)

./update_scripts.sh

# CMAKE
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  sudo apt-get install cmake
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install cmake
  brew install coreutils
fi

# VIM
ln -sf $DOTFILES/vimrc $HOME/.vimrc

# VIM-PLUG INSTALL
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +q +q!

# BASHRC
ln -sf $DOTFILES/bashrc $HOME/.bashrc

# DOCKER
ln -sf $DOTFILES/docker-completion.sh $HOME/.docker-completion.sh

# EDITORCONFIG
ln -sf $DOTFILES/editorconfig $HOME/.editorconfig

# ALIASES
ln -sf $DOTFILES/aliases $HOME/.aliases

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

exec $SHELL
