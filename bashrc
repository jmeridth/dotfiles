export EDITOR=vim

if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
if [[ -a $HOME/.jmaliases ]] ; then source $HOME/.jmaliases ; fi
if [[ -a $HOME/.jmprivatealiases ]] ; then source $HOME/.jmprivatealiases ; fi
if [[ -a $HOME/.jmrax ]] ; then source $HOME/.jmrax ; fi
if [[ -a $HOME/.git-completion.bash ]] ; then source $HOME/.git-completion.bash ; fi
if [[ -a $HOME/.git-prompt.sh ]] ; then source $HOME/.git-prompt.sh ; fi
if [[ -a $HOME/.cafe-completion ]] ; then source $HOME/.cafe-completion ; fi
if [[ -a $HOME/.tmuxinator.bash ]] ; then source $HOME/.tmuxinator.bash ; fi
if [[ -a /usr/local/bin/virtualenvwrapper.sh ]] ; then source /usr/local/bin/virtualenvwrapper.sh ; fi
if [[ -a /usr/local/opt/autoenv/activate.sh ]] ; then source /usr/local/opt/autoenv/activate.sh ; fi

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
export ANSIBLE_HOSTS=~/ansible_hosts
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
export DISABLE_AUTO_TITLE=true
