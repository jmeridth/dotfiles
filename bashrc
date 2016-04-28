EDITOR=vim

if [[ -a ~/.jmaliases ]]
then
  source ~/.jmaliases
fi

if [[ -a ~/.jmprivatealiases ]]
then
  source ~/.jmprivatealiases
fi

if [[ -a ~/.jmrax ]]
then
  source ~/.jmrax
fi

if [[ -a ~/.git-completion.bash ]]
then
  source ~/.git-completion.bash
fi

if [[ -a ~/.git-prompt.sh ]]
then
  source ~/.git-prompt.sh
fi

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

if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
source /usr/local/opt/autoenv/activate.sh
