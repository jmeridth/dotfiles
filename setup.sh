DOTFILES=$(pwd)/dotfiles

# VIM PLUG INSTALL
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# BASHRC
ln -sf $DOTFILES/bashrc $HOME/.bashrc

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

# VIM
ln -sf $DOTFILES/vimrc $HOME/.vimrc
