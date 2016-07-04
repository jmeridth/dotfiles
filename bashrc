export EDITOR=vim

# ALIASES
if [[ -a $HOME/.aliases ]] ; then source $HOME/.aliases ; fi
if [[ -a $HOME/.privatealiases ]] ; then source $HOME/.privatealiases ; fi
if [[ -a $HOME/.rax ]] ; then source $HOME/.rax ; fi

# HISTORY
export HISTTIMEFORMAT="%m/%d/%y %T "

# GIT
if [[ -a $HOME/.git-completion.bash ]] ; then source $HOME/.git-completion.bash ; fi
if [[ -a $HOME/.git-prompt.sh ]] ; then source $HOME/.git-prompt.sh ; fi
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWCOLORHINTS=true

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

# HOMEBREW
if which brew > /dev/null; then export PATH=$(brew --prefix)/lib:$PATH; fi

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
export PYTHON_CONFIGURE_OPTS="--enable-framework"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# PYENV-VIRTUALENV
export PYENV_VIRTUALENV_VERBOSE_ACTIVE=1
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# RVM
if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
export PATH="$PATH:$HOME/.rvm/bin"

# GO
export GOPATH=$HOME/golang
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# GCLOUD
if [[ -a /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]] ; then source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'; fi
if [[ -a /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]] ; then source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'; fi

function http(){
  curl http://httpcode.info/$1;
}
