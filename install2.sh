#!/bin/bash

set -xe


PYTHON_VERSION=3.10.12

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# List all versions
#pyenv install -l

pyenv install $PYTHON_VERSION
pyenv virtualenv $PYTHON_VERSION py$PYTHON_VERSION
pyenv rehash
pyenv activate py$PYTHON_VERSION
pip3 install --no-input --upgrade pip==24.2 setuptools==73.0.0
pip3 install --no-input cython wheel numpy==1.23.0
#python -m pip install --upgrade pip



printf "=============================================================\nNow run :- \npyenv activate py$PYTHON_VERSION\n\n"

#pyenv activate py3.10.18