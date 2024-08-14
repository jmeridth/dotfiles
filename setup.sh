#!/usr/bin/env bash

DOTFILES=$(pwd)

ln -sf $DOTFILES/.editorconfig $HOME/.editorconfig
ln -sf $DOTFILES/.gemrc $HOME/.gemrc
ln -sf $DOTFILES/.gitconfig $HOME/.gitconfig
ln -sf $DOTFILES/.pryrc $HOME/.pryrc
ln -sf $DOTFILES/.pylintrc $HOME/.pylintrc
ln -sf $DOTFILES/.vimrc $HOME/.vimrc
ln -sf $DOTFILES/.zshrc $HOME/.zshrc

# GitHub codespaces only allows signing with gpg, not ssh
git config --global --unset gpg.format
git config --global --unset gpg.ssh.program
