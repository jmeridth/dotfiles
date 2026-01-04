#!/bin/bash
set -e

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

exec $SHELL
