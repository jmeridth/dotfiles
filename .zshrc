# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(autoenv asdf git docker docker-compose vscode)

# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

RPROMPT='%*'

# Enable vi mode
source $ZSH/oh-my-zsh.sh

export GOPATH=$HOME/go
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# OTHER DOTFILES
if [[ -a $HOME/.aliases ]] ; then source $HOME/.aliases ; fi
if [[ -a $HOME/.privatealiases ]] ; then source $HOME/.privatealiases ; fi
if [[ -a $HOME/.local ]] ; then source $HOME/.local ; fi

export PATH="/Users/jmeridth/.privateer/bin:$PATH"
