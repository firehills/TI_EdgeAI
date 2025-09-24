import sys
sys.path.append(".")
import os
import tqdm # show progress
import cv2
import numpy as np
import onnxruntime as rt
import onnx
import shutil
import matplotlib.pyplot as plt
from pathlib import Path





def preprocess(image_path):
    # read the image using openCV
    img = cv2.imread(image_path)
    
    # convert to RGB
    img = img[:,:,::-1]
    
    # Most of the onnx models are trained using
    # 224x224 images. The general rule of thumb
    # is to scale the input image while preserving
    # the original aspect ratio so that the
    # short edge is 256 pixels, and then
    # center-crop the scaled image to 224x224
    orig_height, orig_width, _ = img.shape
    short_edge = min(img.shape[:2])
    new_height = (orig_height * 256) // short_edge
    new_width = (orig_width * 256) // short_edge
    img = cv2.resize(img, (new_width, new_height), interpolation=cv2.INTER_CUBIC)


    startx = new_width//2 - (112//2)
    starty = new_height//2 - (112//2)
    img = img[starty:starty+112, startx:startx+112]
    
    # apply scaling and mean subtraction.
    # if your model is built with an input
    # normalization layer, then you might
    # need to skip this
    img = img.astype(np.float32)
    #img = img.astype(uint8)
    #img = img.astype(np.float) #np.uint8
    # mean and scale are dependent on training. The same values used to preprocess while training must be used here
    for mean, scale, ch in zip([128, 128, 128], [0.0078125, 0.0078125, 0.0078125], range(img.shape[2])):
            img[:,:,ch] = ((img.astype(np.float32)[:,:,ch] - mean) * scale)
    img = np.expand_dims(img,axis=0)
    img = np.transpose(img, (0, 3, 1, 2))
    
    return img













# import functions from local scripts
#from scripts.utils import imagenet_class_to_name, download_model
#from scripts.utils import loggerWriter
#from scripts.utils import get_svg_path

print("============================ START ==================================")
output_dir = '/workspaces/TI_EdgeAI/out'
onnx_model_path = '/workspaces/TI_EdgeAI/models/insightface_w600k_mbf_1.onnx'
#onnx_model_path = '/workspaces/TI_EdgeAI/edgeai-tidl-tools/model-artifacts/cl-6360_onnxrt_imagenet1k_fbr-pycls_regnetx-200mf_onnx/model/regnetx-200mf.onnx'

print(f"Using model {onnx_model_path}")

print("============================ Load.Check Model ==================================")
onnx_model = onnx.load(onnx_model_path)
print(onnx.checker.check_model(onnx_model, full_check=True))

print("============================ Dump ONNX ==================================")
print(onnx.printer.to_text(onnx_model))

#print(onnx.shape_inference.infer_shapes_path(onnx_model_path, onnx_model_path))




log_dir = Path("logs").mkdir(parents=True, exist_ok=True)

# debug level -- use 1 or 2 for increased verbosity in the error messages. See log files to view all printed messages
debug_level=2

#compilation options - knobs to tweak 
num_bits =8
accuracy =1

#calib_images = []

calib_images = [
'/opt/ti/edgeai-tidl-tools/examples/jupyter_notebooks/sample-images/elephant.bmp',
'/opt/ti/edgeai-tidl-tools/examples/jupyter_notebooks/sample-images/bus.bmp',
'/opt/ti/edgeai-tidl-tools/examples/jupyter_notebooks/sample-images/bicycle.bmp',
'/opt/ti/edgeai-tidl-tools/examples/jupyter_notebooks/sample-images/zebra.bmp',
]

# model compilation options
compile_options = {
    'tidl_tools_path' : os.environ['TIDL_TOOLS_PATH'],
    'artifacts_folder' : output_dir,
    'tensor_bits' : num_bits,
    'accuracy_level' : accuracy,
    'debug_level' : debug_level,
    'advanced_options:calibration_frames' : len(calib_images), 
    'advanced_options:calibration_iterations' : 3, # used if accuracy_level = 1
    'advanced_options:add_data_convert_ops' : 1,
    #'deny_list' : "MaxPool" #Comma separated string of operator types as defined by ONNX runtime, ex "MaxPool, Concat"
}






print("============================ RUN COMPILE ==================================")
so = rt.SessionOptions()
EP_list = ['TIDLCompilationProvider','CPUExecutionProvider']
# Create the model's InferenceSession targeting the TIDL Compilation Provider, and pass all compile options to this provider
# When this call runs, compilation will begin but not complete because it is waiting for calibration data
sess = rt.InferenceSession(onnx_model_path ,providers=EP_list, provider_options=[compile_options, {}], sess_options=so)

input_details = sess.get_inputs()

for num in tqdm.trange(len(calib_images)):
    output = list(sess.run(None, {input_details[0].name : preprocess(calib_images[num])}))[0]

#subgraph_link =get_svg_path(output_dir) 
#for sg in subgraph_link:
#    hl_text = os.path.join(*Path(sg).parts[4:])
#    sg_rel = os.path.join('../', sg)
#    display(md("[{}]({})".format(hl_text,sg_rel)))

print("============================ THE END ==================================")
