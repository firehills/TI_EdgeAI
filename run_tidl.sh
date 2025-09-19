#!/bin/bash
cd /opt/ti/edgeai-tidl-tools/
mkdir build && cd build
cmake ../examples && make -j2 && cd ..
source ./scripts/run_python_examples.sh -o
python3 ./scripts/gen_test_report.py
