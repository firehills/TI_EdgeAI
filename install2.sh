#!/bin/bash

set -xe

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

pyenv install 3.10.0
pyenv virtualenv 3.10.0 py3100
pyenv rehash
pyenv activate py3100
pip3 install --no-input --upgrade pip==24.2 setuptools==73.0.0
pip3 install --no-input cython wheel numpy==1.23.0
#python -m pip install --upgrade pip