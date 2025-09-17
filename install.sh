#!/bin/bash

set -xe
sudo mkdir -p /opt/ti
sudo chmod 777 /opt/ti
cd /opt/ti


git clone --depth 1 https://github.com/TexasInstruments/edgeai-tensorlab.git


cd /opt/ti/edgeai-tensorlab/edgeai-modelmaker
#curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

#echo '# pyenv settings ' >> ${HOME}/.bashrc
#echo 'command -v pyenv >/dev/null || export PATH=":${HOME}/.pyenv/bin:$PATH"' >> ${HOME}/.bashrc
#echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc
#echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.bashrc
#echo '' >> ${HOME}/.bashrc




echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ${HOME}/.bashrc


curl -fsSL https://pyenv.run | bash

exec ${SHELL}

