解决numpy.core.multiarray failed to import问题 - Shaelyn_W - CSDN博客 https://blog.csdn.net/m0_37733057/article/details/88426147

在import tensorflow和import keras时出现这个问题

根本原因是numpy版本低

pip uninstall numpy
pip install -U numpy

或者在卸载numpy后，删掉anaconda3\lib\site-packages\numpy\core\multiarray.cp36-win_amd64.pyd文件，再pip install -U numpy

参考https://blog.csdn.net/llh_1178/article/details/81671348