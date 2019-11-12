git -C ~/.pyenv pull > /dev/null 2>&1 || git clone https://github.com/pyenv/pyenv.git ~/.pyenv > /dev/null 2>&1
exec "$SHELL"
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
exec "$SHELL"
git -C $(pyenv root)/plugins/pyenv-virtualenv pull > /dev/null 2>&1 || git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
exec "$SHELL"