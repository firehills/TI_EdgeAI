#!/bin/bash

set -xe

cd /opt/ti/edgeai-tensorlab/edgeai-modelmaker


sed -i 's/USE_INTERNAL_REPO=1/USE_INTERNAL_REPO=0/g'  /opt/ti/edgeai-tensorlab/edgeai-modelmaker/setup_cpu.sh
./setup_cpu.sh

