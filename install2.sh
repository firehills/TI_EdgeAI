#!/bin/bash

set -e

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

pyenv install 3.10.18
pyenv virtualenv 3.10.18 py31018
pyenv rehash
pyenv activate py31018
pip3 install --no-input --upgrade pip==24.2 setuptools==73.0.0
pip3 install --no-input cython wheel numpy==1.23.0
#python -m pip install --upgrade pip



printf "=============================================================\nNow run :- \npyenv activate py31018\n\n"