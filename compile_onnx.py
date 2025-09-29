import sys
import os
import glob
import argparse
sys.path.append(".")
import os
import tqdm # show progress
import cv2
import numpy as np
import onnxruntime as rt
import onnx
import tflite_runtime.interpreter as tflite
import shutil
import matplotlib.pyplot as plt
from pathlib import Path
import time
from onnx.version_converter import convert_version




def preprocess(image_path: str):
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


    startx = new_width//2 - (224//2)
    starty = new_height//2 - (224//2)
    img = img[starty:starty+224, startx:startx+224]
    
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




def ClearDir(folder: str) -> None :
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))



def CompileOnnx() -> None:
   
    print("============================ START ==================================")
    output_dir: str = args.out
    onnx_model_path: str = args.onnx
 
    print(f"Using model {onnx_model_path}")
    print(f'Output Dir = {output_dir}')
    print(f"TIDL_TOOLS_PATH={os.environ['TIDL_TOOLS_PATH']}")
    print(f"SOC={os.environ['SOC']}")

    # remove all "old" files in output dir
    ClearDir(output_dir)

    print("============================ Load + Check Model ==================================")
    onnx_model: ModelProto = onnx.load(onnx_model_path)
    print(onnx.checker.check_model(onnx_model, full_check=True))

    #opset_version = onnx_model.opset_import[0].version if len(onnx_model.opset_import) > 0 else None
    #onnx_model = convert_version(onnx_model, 18)
    
    #print("============================ Dump ONNX ==================================")
    #print(onnx.printer.to_text(onnx_model))
    #print(onnx.shape_inference.infer_shapes_path(onnx_model_path, onnx_model_path))


    # debug level -- use 1 or 2 for increased verbosity in the error messages. See log files to view all printed messages
    debug_level=args.debug

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
    # See https://github.com/TexasInstruments/edgeai-tidl-tools/tree/master/examples/osrt_python#user-options-for-tflite-and-onnx-runtime
    compile_options = {
        'tidl_tools_path' : os.environ['TIDL_TOOLS_PATH'],
        'artifacts_folder' : output_dir,
        'tensor_bits' : num_bits,
        'accuracy_level' : accuracy,
        'debug_level' : debug_level,
        'advanced_options:calibration_frames' : len(calib_images), 
        'advanced_options:calibration_iterations' : 3, # used if accuracy_level = 1
        'advanced_options:add_data_convert_ops' : 1,
        'model_type' : "", # Only neeed to set this if its ObjectDetection in which case it = "OD"
        #'object_detection:meta_arch_type' : -1,
        #'deny_list' : "MaxPool" #Comma separated string of operator types as defined by ONNX runtime, ex "MaxPool, Concat"
    }

   

    print("============================ RUN COMPILE ==================================")
    so = rt.SessionOptions()
    so.log_severity_level = 0 # = Verbose
    EP_list = ['TIDLCompilationProvider','CPUExecutionProvider']
    #EP_list = ['TIDLCompilationProvider']

    # Create the model's InferenceSession targeting the TIDL Compilation Provider, and pass all compile options to this provider
    # When this call runs, compilation will begin but not complete because it is waiting for calibration data
    sess = rt.InferenceSession(onnx_model_path, providers=EP_list, provider_options=[compile_options, {}], sess_options=so)
    #rt.InferenceSession(onnx_model_path, providers=['CPUExecutionProvider'])

    sess_prov = sess.get_providers()
    sess_prov_opt = sess.get_provider_options()
    sess_opt = sess.get_session_options()

    input_details = sess.get_inputs()
    print(input_details)
    print("============================ CALIB ==================================")
    for num in tqdm.trange(len(calib_images)):


        if not input_details[0].type == 'tensor(float)':
            print("DO processed_image = np.uint8(processed_image) ")
        
        processed_image = preprocess(calib_images[num])
        output: list = list(sess.run(None, {input_details[0].name : preprocess(calib_images[num])}))[0]
        #print(f'IMAGE {num} -> output = {output}')


    #subgraph_link =get_svg_path(output_dir) 
    #for sg in subgraph_link:
    #    hl_text = os.path.join(*Path(sg).parts[4:])
    #    sg_rel = os.path.join('../', sg)
    #    display(md("[{}]({})".format(hl_text,sg_rel)))

    print("============================ THE END ==================================")



    print("============================ Inference =====================")
    EP_list = ['TIDLExecutionProvider','CPUExecutionProvider']
    sess = rt.InferenceSession(onnx_model_path ,providers=EP_list, provider_options=[compile_options, {}], sess_options=so)
    input_details = sess.get_inputs()
    output = list(sess.run(None, {input_details[0].name : processed_image}))[0]
    # https://software-dl.ti.com/jacinto7/esd/tidl-tools/$REL/TIDL_TOOLS/$1/tidl_tools.tar.gz





if __name__ == '__main__':

    # Capture CMD Line args for model, output dir and debug level
    parser = argparse.ArgumentParser(prog="OnnxCompiler",
                                    add_help=True, 
                                    description="Convert ML Onnx file to format suitable to use with Texas Instruments AM62x SoC",
                                    epilog="")
    
    parser.add_argument("-onnx", 
                    default="/workspaces/TI_EdgeAI/models/resnet18_opset9.onnx", 
                    required=False, 
                    type=str,
                    help="Path to the input onnx file")
    parser.add_argument("-out", 
                    default="/workspaces/TI_EdgeAI/out", 
                    required=False, 
                    type=str,
                    help="Path to the output dir")
    parser.add_argument("-debug", 
                    default=0, 
                    required=False, 
                    type=int,
                    help="Debug Level [0..2]")
      
    try:
        args = parser.parse_args()
    except argparse.ArgumentError:
        # problem with args, argparse will flag the error -> just quit
        sys.exit(-1)

    # and run the converter...
    sys.exit(CompileOnnx()) 





    ########################################################################
    # See Also 
    #
    # https://netron.app/ = Visalise onnx model online