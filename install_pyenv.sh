git clone https://github.com/pyenv/pyenv.git ~/.pyenv
exec $SHELL
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
exec $SHELL

pyenv install 2.7.14
pyenv install 3.6.2

pyenv virtualenv 2.7.11 neovim2
pyenv virtualenv 3.4.4 neovim3

pyenv activate neovim2
pip install neovim
pyenv deactivate neovim2

pyenv activate neovim3
pip install neovim
pyenv deactivate neovim3
