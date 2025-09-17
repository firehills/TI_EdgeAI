#!/bin/bash

set -xe

sudo apt-get install -y libyaml-cpp-dev libglib2.0-dev wget python3 python3-pip cmake
sudo mkdir -p /opt/ti
sudo chmod 777 /opt/ti
cd /opt/ti
git clone https://github.com/TexasInstruments/edgeai-tidl-tools.git
export SOC=am62a


mkdir -p /opt/ti/edgeai-tidl-tools/tools/AM62A/
cd /opt/ti/edgeai-tidl-tools/tools/AM62A/
cp /workspaces/TI_EdgeAI/tidl_tools.tar.gz .
tar xzvf tidl_tools.tar.gz
tar xzvf tidl_tools.tar.gz  --strip-components=1

sed -i 's!wget --quiet   https://software-dl.ti.com/jacinto7/esd/tidl-tools/$REL/TIDL_TOOLS/${SOC^^}/tidl_tools.tar.gz!printf "=================================\nRemoved wget tidl_tools for AM62A \n================================\n!g'  /opt/ti/edgeai-tidl-tools/setup.sh


cd /opt/ti/edgeai-tidl-tools
source ./setup.sh


# fails on 
# wget  https://software-dl.ti.com/jacinto7/esd/tidl-tools/11_00_06_00/TIDL_TOOLS/AM62A/tidl_tools.tar.gz
# Ticket raised on TI 
# https://e2e.ti.com/support/processors-group/processors/f/processors-forum/1566728/am62a7-edgeai-tidl-tools---setup-instructions-fail-file-tidl_tools-tar-gz-unavailable-for-download?tisearch=e2e-sitesearch&keymatch=tidl_tools.tar.gz#
