#!/bin/bash
set -e
cd /workspaces/TI_EdgeAI
SOC=am62a
TIDL_TOOLS_PATH=/opt/ti/edgeai-tidl-tools/tools/AM62A
LD_LIBRARY_PATH=:/opt/ti/edgeai-tidl-tools/tools/AM62A:/opt/ti/edgeai-tidl-tools/tools/osrt_deps:/opt/ti/edgeai-tidl-tools/tools/osrt_deps/opencv_4.2.0_x86_u22/opencv/
CGT7X_ROOT=/opt/ti/edgeai-tidl-tools/tools/ti-cgt-c7000_5.0.0.LTS
ARM64_GCC_PATH=/opt/ti/edgeai-tidl-tools/tools/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu



ONNX_MODEL=/workspaces/TI_EdgeAI/resnet18_opset9.onnx
#ONNX_MODEL=/workspaces/TI_EdgeAI/insightface_w600k_mbf_1.onnx

cd /workspaces/TI_EdgeAI
wget -N https://akm-img-a-in.tosshub.com/indiatoday/images/story/201804/jet.jpeg
wget -N https://git.ti.com/cgit/jacinto-ai/jacinto-ai-modelzoo/plain/models/vision/classification/imagenet1k/torchvision/resnet18_opset9.onnx

rm -rf /content/*

sudo mkdir -p /content/resnet18/
sudo chmod 777 /content/resnet18/
sudo chmod 777 /content

cp jet.jpeg /content/resnet18/
cp resnet18_opset9.onnx /content

echo "perfSimConfig = $TIDL_TOOLS_PATH/device_config.cfg" >> /content/resnet18/config
echo "/content/resnet18/jet.jpeg 895" >> /content/resnet18/in_data_list.txt


#--modelType 2 == onnx

$TIDL_TOOLS_PATH/tidl_model_import.out /content/resnet18/config --modelType 2 \
--inputNetFile $ONNX_MODEL --outputNetFile /content/resnet18/tidl_net.bin \
--outputParamsFile /content/resnet18/tidl_io_buff  --inDataNorm 1 \
--inMean 123.675 116.28 103.53  --inScale 0.017125 0.017507 0.017429 \
--inData /content/resnet18/in_data_list.txt --inFileFormat 2 \
--tidlStatsTool $TIDL_TOOLS_PATH/PC_dsp_test_dl_algo.out \
--perfSimTool $TIDL_TOOLS_PATH/ti_cnnperfsim.out \
--graphVizTool $TIDL_TOOLS_PATH/tidl_graphVisualiser.out \
--inHeight 224 --inWidth 224 --inNumChannels 3 --numFrames 1 \
--debugTraceLevel 2
echo "================= RUN COMPILED LOCALLY ========================"

$TIDL_TOOLS_PATH/PC_dsp_test_dl_algo.out s:/content/resnet18/config \
--netBinFile /content/resnet18/tidl_net.bin \
--ioConfigFile /content/resnet18/tidl_io_buff1.bin \
--inData /content/resnet18/in_data_list.txt --inFileFormat 2 \
--outData /content/resnet18/jet_tidl_out.bin --postProcType 1


echo ""
echo "============ DONE ============="

