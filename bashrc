export EDITOR=vim

# ALIASES
if [[ -a $HOME/.aliases ]] ; then source $HOME/.aliases ; fi
if [[ -a $HOME/.privatealiases ]] ; then source $HOME/.privatealiases ; fi
if [[ -a $HOME/.piston ]] ; then source $HOME/.piston ; fi

# HISTORY
export HISTTIMEFORMAT="%m/%d/%y %T "

# GIT
if [[ -a $HOME/.git-completion.bash ]] ; then source $HOME/.git-completion.bash ; fi
if [[ -a $HOME/.git-prompt.sh ]] ; then source $HOME/.git-prompt.sh ; fi
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWCOLORHINTS=true


# HOMEBREW
if [[ "$OSTYPE" == "darwin"* ]]; then
  if which brew > /dev/null; then
    export PATH=$(brew --prefix)/lib:$PATH
  fi
fi

# ANSIBLE
if [[ -a $HOME/ansible_hosts ]] ; then
  export ANSIBLE_HOSTS=~/ansible_hosts
fi

# TMUX/TMUXINATOR
if [[ -a $HOME/.tmuxinator.bash ]] ; then source $HOME/.tmuxinator.bash ; fi
if which mux > /dev/null; then
  export DISABLE_AUTO_TITLE=true
fi

# AUTOENV
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -a /usr/local/opt/autoenv/activate.sh ]] ; then source /usr/local/opt/autoenv/activate.sh ; fi
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  source $(brew --prefix autoenv)/activate.sh
fi

# PYENV
if [[ -d $HOME/.pyenv ]] ; then
  export PYENV_ROOT=$HOME/.pyenv
  export PATH=$PYENV_ROOT/bin:$PATH
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# RVM
if [[ -s $HOME/.rvm/scripts/rvm ]] ; then
  source $HOME/.rvm/scripts/rvm
  export PATH="$PATH:$HOME/.rvm/bin"
fi

# GO
if which go > /dev/null; then
  if [ ! -d "$HOME/golang" ]; then mkdir $HOME/golang ; fi
  export GOPATH=$HOME/golang
  export GOBIN=$GOPATH/bin
  export GOROOT=$(which go)
  export PATH=$PATH:$GOPATH/bin
  export PATH=$PATH:$GOROOT/bin
fi

# GCLOUD
if [[ "$OSTYPE" == "darwin"* ]]; then
  if which go > /dev/null; then
    if [[ -a /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]] ; then
      source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
    fi
    if [[ -a /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]] ; then
      source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'
    fi
  fi
fi

# DOCKER
if [[ -s $HOME/.docker-completion.sh ]] ; then
  source $HOME/.docker-completion.sh
fi

# KUBERNETES
if [[ -s $HOME/.kubectl-completion.sh ]] ; then
  source $HOME/.kubectl-completion.sh
fi

# BASH COMPLETION
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
  fi
fi


function http(){
  curl http://httpcode.info/$1;
}

function updatePrompt {
        BLACK="\[\e[0;30m\]"
        DGRAY="\[\e[1;30m\]"
        BLUE="\[\e[0;34m\]"
        LBLUE="\[\e[1;34m\]"
        GREEN="\[\e[0;32m\]"
        LGREEN="\[\e[1;32m\]"
        CYAN="\[\e[0;36m\]"
        LCYAN="\[\e[1;36m\]"
        RED="\[\e[0;31m\]"
        LRED="\[\e[1;31m\]"
        PURPLE="\[\e[0;35m\]"
        LPURPLE="\[\e[1;35m\]"
        BROWN="\[\e[0;33m\]"
        YELLOW="\[\e[1;33m\]"
        LGRAY="\[\e[0;37m\]"
        WHITE="\[\e[1;37m\]"
        RESET_COLOR="\[\e[0m\]"

        PROMPT="$WHITE[\h]${CYAN}[\w]\n"

        if [[ -a .ruby-gemset ]] ; then
                PROMPT="$PROMPT${LCYAN}($(rvm-prompt i v p g))${RESET_COLOR}"
        fi

        if [[ $VIRTUAL_ENV != "" ]]; then
                PROMPT="$PROMPT${LCYAN}($(basename ${VIRTUAL_ENV}))${RESET_COLOR}"
        fi

        if type "__git_ps1" > /dev/null 2>&1; then
                PROMPT="$PROMPT\$(__git_ps1 '[%s]')${YELLOW}->"
        fi

        PS1="$PROMPT\$ ${RESET_COLOR}"
}
export -f updatePrompt
export PROMPT_COMMAND='updatePrompt'
