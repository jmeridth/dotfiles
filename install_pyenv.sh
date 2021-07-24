if ! which pyenv > /dev/null; then
    git -C ~/.pyenv pull > /dev/null 2>&1 || git clone https://github.com/pyenv/pyenv.git ~/.pyenv > /dev/null 2>&1
fi
