

1. https://github.com/tensorflow/models.git
    1. https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/installation.md
    2. https://github.com/tensorflow/models/blob/master/research/object_detection/object_detection_tutorial.ipynb
    3. ImportError: No module named utils https://github.com/tensorflow/models/issues/1747

pip install pillow  jupyter  matplotlib  lxml

2. protobuf
    1. https://github.com/google/protobuf/releases?after=v3.4.1
    2. https://github.com/protocolbuffers/protobuf/releases/download/v3.4.0/protoc-3.4.0-win32.zip

protoc object_detection/protos/*.proto --python_out=.

新建文件C:\Python36\Lib\site-packages\tensorflow_path.pth

C:\Python36\Lib\site-packages\tensorflow\models\research
C:\Python36\Lib\site-packages\tensorflow\models\research\slim

验证
python object_detection/builders/model_builder_test.py

use "object_detection.utils" instase of "utils"

```py
import object_detection.utils as vis_util
```

3. No module named 'cv2'
pip install opencv-python


4. imageio
https://imageio.readthedocs.io/en/latest/examples.html

pip install imageio -U
pip install imageio-ffmpeg
