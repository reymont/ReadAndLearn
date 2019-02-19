

* [Jps介绍以及解决jps无法查看某个已经启动的java进程问题 - CSDN博客 ](http://blog.csdn.net/javastart/article/details/50730357)

java程序启动后，默认（请注意是默认）会在/tmp/hsperfdata_userName目录下以该进程的id为文件名新建文件，并在该文件中存储jvm运行的相关信息，其中的userName为当前的用户名，/tmp/hsperfdata_userName目录会存放该用户所有已经启动的java进程信息。对于windows机器/tmp用Windows存放临时文件目录代替。

/tmp/hsperfdata_root