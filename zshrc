export EDITOR=vim

# ALIASES
if [[ -a $HOME/.aliases ]] ; then source $HOME/.aliases ; fi
if [[ -a $HOME/.privatealiases ]] ; then source $HOME/.privatealiases ; fi

# HISTORY
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
HISTTIMEFORMAT="%m/%d/%y %T "
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# PYENV
if [[ -d $HOME/.pyenv ]] ; then
  export PYENV_ROOT=$HOME/.pyenv
  export PATH=$PYENV_ROOT/bin:$PATH
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# GO
if which go > /dev/null; then
  if [ ! -d "$HOME/code/golang" ]; then mkdir -p $HOME/code/golang ; fi
  export GOPATH=$HOME/code/golang
  export PATH=$PATH:$GOPATH/bin
fi

# GPG
GPG_TTY=$(tty)
export GPG_TTY

export POWERLINE_CONFIG_COMMAND=$HOME/code/powerline/scripts/powerline-config

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '
#RPROMPT='%*'
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b) %r%f %*'
zstyle ':vcs_info:*' enable git
