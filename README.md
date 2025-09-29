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
pyenv activate py3.10.12

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

## Onnx Model Compilation (Open Neural Network Exchange)

ONNX is open-source format for representing machine learning models, allowing them to be trained in one framework (like PyTorch or TensorFlow) and then easily used in another framework or on different hardware for inference. It acts as an intermediary, or "common language," for AI models, providing interoperability by enabling seamless model portability across various tools

### Model Visualization with Neutron

https://netron.app/
https://github.com/lutzroeder/netron


### Compilation

Process onnx model into a form that the NPU can execute. In the case of TI, this generates a set of files that can be loaded on to the C7x256v Deap Learning Accelerator (DSP)


Complete example in 
```bash
cd /workspaces/TI_EdgeAI

./compile_onnx.sh
```




## See Also ...
https://github.com/TexasInstruments-Sandbox/edgeai-osrt-libs-build