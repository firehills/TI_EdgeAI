#!/bin/bash

###############################################################################
#
# Script to take custom onnx file, compile with TI tooling for use on 
# AM62A Machine Leaning CoProcessor.
# 
# Compiled Files are then used processed on host to check inferance is functional
#
###############################################################################

# Quit on any error
set -e


cd /workspaces/TI_EdgeAI

# Assuming script is run in context of devcontiner, so paths should be known and
# consistant

# These usually setup by TI tooling
SOC=am62a
TIDL_TOOLS_PATH=/opt/ti/edgeai-tidl-tools/tools/AM62A/tidl_tools
LD_LIBRARY_PATH=:/opt/ti/edgeai-tidl-tools/tools/AM62A/tidl_tools:/opt/ti/edgeai-tidl-tools/tools/osrt_deps:/opt/ti/edgeai-tidl-tools/tools/osrt_deps/opencv_4.2.0_x86_u22/opencv/
CGT7X_ROOT=/opt/ti/edgeai-tidl-tools/tools/ti-cgt-c7000_5.0.0.LTS
ARM64_GCC_PATH=/opt/ti/edgeai-tidl-tools/tools/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu

# where to put generated artifacts - this is deleted on a re-run
OUT_DIR=/content/resnet18

# Model to use 
ONNX_MODEL=/workspaces/TI_EdgeAI/resnet18_opset9.onnx
#ONNX_MODEL=/workspaces/TI_EdgeAI/insightface_w600k_mbf_1.onnx


# Get the model and test images
wget -N https://akm-img-a-in.tosshub.com/indiatoday/images/story/201804/jet.jpeg
wget -N https://git.ti.com/cgit/jacinto-ai/jacinto-ai-modelzoo/plain/models/vision/classification/imagenet1k/torchvision/resnet18_opset9.onnx
wget -N https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/960px-Cat_November_2010-1a.jpg  -O cat.jpeg
wget -N https://upload.wikimedia.org/wikipedia/commons/4/4d/Cheeseburger.jpg -O cheeseburger.jpg

# Clean/Setup output dir
rm -rf $OUT_DIR/*
sudo mkdir -p $OUT_DIR
sudo chmod 777 $OUT_DIR
sudo chmod 777 $OUT_DIR

# Copy images 
cp jet.jpeg $OUT_DIR
cp jet.bmp $OUT_DIR
cp cat.jpeg $OUT_DIR
cp cheeseburger.jpg $OUT_DIR

# copy model
cp resnet18_opset9.onnx $OUT_DIR

# config file setup - tell the compiler the params we wish to use
echo "perfSimConfig = $TIDL_TOOLS_PATH/device_config.cfg" >> $OUT_DIR/config

# Calibration/test - setup image.
#see https://gist.github.com/yrevar/942d3a0ac09ec9e5eb3a to referance the category number to description, eg -> 895: 'warplane, military plane', 933 cheeseburger, 281 tabbycat
echo "$OUT_DIR/jet.jpeg 895" >> $OUT_DIR/in_data_list.txt

#echo "$OUT_DIR/resnet18/cheeseburger.jpg 933" > $OUT_DIR/resnet18/in_data_list2.txt
#echo "$OUT_DIR/cat.jpeg 281 282"         > $OUT_DIR/in_data_list2.txt
#echo "$OUT_DIR/cheeseburger.jpg 933" >> $OUT_DIR/in_data_list2.txt
#Note -> --modelType 2 == onnx

# Run compilation step 
$TIDL_TOOLS_PATH/tidl_model_import.out $OUT_DIR/config --modelType 2 \
--inputNetFile $ONNX_MODEL --outputNetFile $OUT_DIR/tidl_net.bin \
--outputParamsFile $OUT_DIR/tidl_io_buff  --inDataNorm 1 \
--inMean 123.675 116.28 103.53  --inScale 0.017125 0.017507 0.017429 \
--inData $OUT_DIR/in_data_list.txt --inFileFormat 2 \
--tidlStatsTool $TIDL_TOOLS_PATH/PC_dsp_test_dl_algo.out \
--perfSimTool $TIDL_TOOLS_PATH/ti_cnnperfsim.out \
--graphVizTool $TIDL_TOOLS_PATH/tidl_graphVisualiser.out \
--inHeight 224 --inWidth 224 --inNumChannels 3 --numFrames 1 \
--debugTraceLevel 0

echo -n "\n================= RUN COMPILED MODEL LOCALLY ========================\n"


# Run inferance step 
$TIDL_TOOLS_PATH/PC_dsp_test_dl_algo.out s:$OUT_DIR/config \
--netBinFile $OUT_DIR/tidl_net.bin \
--ioConfigFile $OUT_DIR/tidl_io_buff1.bin \
--inData $OUT_DIR/in_data_list.txt --inFileFormat 2 \
--outData $OUT_DIR/jet_tidl_out.bin --postProcType 1 --debug 0


# For resnet18_opset9.onnx and jet.jpeg, this is the expected output:-
#                               
# A :   895, 1.0000, 1.0000,   895 .... .....
#                               ^
#                               |
# This value is the classification - see https://gist.github.com/yrevar/942d3a0ac09ec9e5eb3a



echo -e "\n\n============ DONE =============\n"




#######################################################

# setup to run on target

#TARGET_IP=10.190.5.71
#scp -r /content/resnet18/ root@$TARGET_IP:/opt
#scp   /content/resnet18/ root@$TARGET_IP:/opt

# edit in_data_list.txt to point to image

#/opt/tidl_test/TI_DEVICE_armv8_test_dl_algo_host_rt.out s:/opt/resnet18/config \
#--netBinFile /opt/resnet18/tidl_net.bin --ioConfigFile /opt/resnet18/tidl_io_buff1.bin \
#--inData /opt/resnet18/in_data_list.txt --inFileFormat 2 \
#--outData /opt/resnet18/jet_tidl_out.bin --postProcType 1 --debug 0

