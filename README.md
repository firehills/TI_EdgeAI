# TI EdgeAI Environment



## Run Examples - Common Setup

Setup must be run once :-

```bash
cd /workspaces/TI_EdgeAI

# crete download dir in opt and install pyenv
./install.sh

# install python 
./install2.sh

# and activate 
pyenv activate py31018

```

## TIDL Tools

see https://github.com/TexasInstruments/edgeai-tidl-tools.git

Run the common setup above, then 
```bash
cd /workspaces/TI_EdgeAI

# get the repo, setup tidl_tools.tar.gz for AM62A
./install_tidl.sh

# setup the examples
export TIDL_TOOLS_PATH=/opt/ti/edgeai-tidl-tools/tools/AM62A 
cd /opt/ti/edgeai-tidl-tools
source ./setup.sh

# Run the examples
/workspaces/TI_EdgeAI/run_tidl.sh
```

## Tensorlab modelmaker

see https://github.com/TexasInstruments/edgeai-tensorlab.git

Run the common setup above, then 
```bash
cd /workspaces/TI_EdgeAI

# tools checkout and setup
./install3.sh

# run the examples
./run_modelmaker.sh AM62A config_detection.yaml
```
