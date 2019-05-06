在终端设备上实现语音识别的TensorFlow预训练模型 - Python开发社区 | CTOLib码库 https://react.ctolib.com/ARM-software-ML-KWS-for-MCU.html

Keyword spotting for Microcontrollers
This repository consists of the tensorflow models and training scripts used in the paper: Hello Edge: Keyword spotting on Microcontrollers. The scripts are adapted from Tensorflow examples and some are repeated here for the sake of making these scripts self-contained.

To train a DNN with 3 fully-connected layers with 128 neurons in each layer, run:

python train.py --model_architecture dnn --model_size_info 128 128 128 
The command line argument --model_size_info is used to pass the neural network layer dimensions such as number of layers, convolution filter size/stride as a list to models.py, which builds the tensorflow graph based on the provided model architecture and layer dimensions. For more info on model_size_info for each network architecture see models.py. The training commands with all the hyperparameters to reproduce the models shown in the paper are given here.

To run inference on the trained model from a checkpoint on train/val/test set, run:

python test.py --model_architecture dnn --model_size_info 128 128 128 --checkpoint 
<checkpoint path>
To freeze the trained model checkpoint into a .pb file, run:

python freeze.py --model_architecture dnn --model_size_info 128 128 128 --checkpoint 
<checkpoint path> --output_file dnn.pb
Pretrained models
Trained models (.pb files) for different neural network architectures such as DNN, CNN, Basic LSTM, LSTM, GRU, CRNN and DS-CNN shown in this arXiv paper are added in Pretrained_models. Accuracy of the models on validation set, their memory requirements and operations per inference are also summarized in the following table.



To run an audio file through the trained model (e.g. a DNN) and get top prediction, run:

python label_wav.py --wav <audio file> --graph Pretrained_models/DNN/DNN_S.pb 
--labels Pretrained_models/labels.txt --how_many_labels 1
Quantization Guide and Deployment on Microcontrollers
A quick guide on quantizing the KWS neural network models is here. The example code for running a DNN model on a Cortex-M development board is also provided here.