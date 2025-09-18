#!/bin/bash

set -xe


cd /opt/ti
git clone --depth 1 https://github.com/TexasInstruments/edgeai-tensorlab.git
cd /opt/ti/edgeai-tensorlab/edgeai-modelmaker


sed -i 's/USE_INTERNAL_REPO=1/USE_INTERNAL_REPO=0/g'  /opt/ti/edgeai-tensorlab/edgeai-modelmaker/setup_cpu.sh
./setup_cpu.sh

######################################################################################
# Temp Workaround, from the TI Support

# Reese Grimsley  replied to  AM62A7: edgeai-tidl-tools -> setup instructions fail, file tidl_tools.tar.gz unavailable for download .
#
# Hi Philip, 
#
# This is a result of AM62A not having an 11.0 SDK release. AM62A has an 11.1 release, but the corresponding edgeai-tidl-tools release is held until several other TI devices have their 11.1 software release. 
#
# The 10.1 is the latest edgeai-tidl-tools version with public release for AM62A.
#
# I'll also throw a tidl_tools.tar.gz tarball that I've been using in the interim for 11.1. You can use the 11_0 branch and point to these tools with TIDL_TOOLS_PATH and LD_LIBRARY_PATH. This is not an official release, but it is compatible with the 11.1 SDK for AM62A that is out today. The other python packages should be compatible with these tools 
#
# e2e.ti.com/.../tidl_5F00_tools.tar.gz
#
# BR,
# Reese
#######################################################################################
cd /opt/ti/edgeai-tensorlab/edgeai-benchmark/tools/tidl_tools_package/AM62A
cp /workspaces/TI_EdgeAI/tidl_tools.tar.gz /opt/ti/edgeai-tensorlab/edgeai-benchmark/tools/tidl_tools_package/AM62A
tar xzvf tidl_tools.tar.gz





printf "==================================================\nRun an example\n./run_modelmaker.sh AM62A config_detection.yaml\n\n"