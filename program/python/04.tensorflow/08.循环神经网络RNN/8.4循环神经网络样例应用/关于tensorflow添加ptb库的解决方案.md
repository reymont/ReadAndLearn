关于tensorflow添加ptb库的解决方案 - 简书 https://www.jianshu.com/p/65490010a485

ptb数据集是语言模型学习中应用最广泛的数据集，常用该数据集训练RNN神经网络作为语言预测，tensorflow对于ptb数据集的读取也定义了自己的函数库用于读取，在python 1.0定义了models文件用于导入ptb库函数，然而当python升级后，导入models文件时就会出现：ModuleNotFountError错误，这时需要靠自己下载导入，github上有人共享了models文件，但是不清楚如何安装，网上教程很多，但是安装了还有很多的错误，本人捣鼓了一天算将其成功导入，因此写成教程，可以不用下载低版本tensorflow，注意：该教程适用于linux系统下tensorflow。


步骤1：在低版本tensorflow中，导入ptb库的语句为“from tensorflow.models.rnn.ptb import reader”，其形式与导入mnist库一样，因此我们需要查找安装models库的位置，在命令行中输入: locate tensorflow/examples/tutorials此时将会显示出有上面路径的文件，找到路径*/tensorflow/examples/tutorials/mnist，此时路径*/tensorflow就是我们安装models的路径，用cd命令进入该文件。

步骤2：进入上面tensorflow文件后，用git下载models文件夹，在命令行中输入命令：
`git clone –recurse-submodules https://github.com/tensorflow/models`

### 3. 复制到tensorflow的文件夹下

如果不知道tensorflow的文件夹在哪里，可以通过以下方式查询

rin@ubuntu:~$ python
Python 3.5.2 (default, Nov 23 2017, 16:37:01) 
[GCC 5.4.0 20160609] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
>>> tf.__path__
['/usr/local/lib/python3.5/dist-packages/tensorflow']
注意path前后各有两条下划线.

如果没有安装git，请自行百度如何安装git

步骤3：此时运行含有语句“from tensorflow.models.rnn.ptb import reader”还是会出错，主要是因为下载的文件内容与低版本的库有一定区别，可以逐步进入路径“*/tensorflow/models”发现，没有文件rnn，rnn文件存在与路径“*/tensorflow/models/tutorials/”文件下，因此我们需要将该语句改成“from tensorflow.models.tutorials.rnn.ptb import reader”

步骤4：此时还会出错，提示ModuleNotFoundError:No module name ‘reader’，此时我们需要对ptb中的__init__.py文件进行修改，将该文件中的“import reader”修改成“from tensorflow.models.tutorials.rnn.ptb import reader”，还有将“import util”修改成“from tensorflow.models.tutorials.rnn.ptb import util”此时再次运行程序，将成功导入ptb

## 参考

1. https://www.jianshu.com/p/65490010a485
2. https://blog.csdn.net/RineZ/article/details/81671382
