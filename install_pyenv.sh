git -C ~/.pyenv pull > /dev/null 2>&1 || git clone https://github.com/pyenv/pyenv.git ~/.pyenv > /dev/null 2>&1
exec "$SHELL"
git -C $(pyenv root)/plugins/pyenv-virtualenv pull > /dev/null 2>&1 || git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
exec "$SHELL"

pyenv install -s 2.7.14
pyenv install -s 3.6.2

pyenv virtualenv -f 2.7.11 neovim2
pyenv virtualenv -f 3.4.4 neovim3

pyenv activate neovim2
pip install neovim
pyenv deactivate neovim2

pyenv activate neovim3
pip install neovim
pyenv deactivate neovim3
