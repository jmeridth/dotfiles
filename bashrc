export EDITOR=vim

# ALIASES
if [[ -a $HOME/.jmaliases ]] ; then source $HOME/.jmaliases ; fi
if [[ -a $HOME/.jmprivatealiases ]] ; then source $HOME/.jmprivatealiases ; fi
if [[ -a $HOME/.jmrax ]] ; then source $HOME/.jmrax ; fi


# GIT
if [[ -a $HOME/.git-completion.bash ]] ; then source $HOME/.git-completion.bash ; fi
if [[ -a $HOME/.git-prompt.sh ]] ; then source $HOME/.git-prompt.sh ; fi
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWCOLORHINTS=true

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

export PS1="$WHITE[\h]${CYAN}[\w]\n\$(__git_ps1 '[%s]')${YELLOW}->\$ ${RESET_COLOR}"

# HOMEBREW
export PATH=$(brew --prefix)/lib:$PATH

# OPENCAFE

if [[ -a $HOME/.cafe-completion ]] ; then source $HOME/.cafe-completion ; fi

# ANSIBLE
export ANSIBLE_HOSTS=~/ansible_hosts

# TMUX/TMUXINATOR
if [[ -a $HOME/.tmuxinator.bash ]] ; then source $HOME/.tmuxinator.bash ; fi
export DISABLE_AUTO_TITLE=true

# AUTOENV
if [[ -a /usr/local/opt/autoenv/activate.sh ]] ; then source /usr/local/opt/autoenv/activate.sh ; fi

# VIRTUALENVWRAPPER
if [[ -a /usr/local/bin/virtualenvwrapper.sh ]] ; then source /usr/local/bin/virtualenvwrapper.sh ; fi
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev

# PYENV
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
if which pyenv > /dev/null; then pyenv virtualenvwrapper; fi

# RVM
if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
export PATH="$PATH:$HOME/.rvm/bin"
