#!/bin/bash

set -xe

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

pyenv install 3.10.18
pyenv virtualenv 3.10.18 py310
pyenv rehash
pyenv activate py310
pip3 install --no-input --upgrade pip==25.2 setuptools==73.0.0

python -m pip install --upgrade pip