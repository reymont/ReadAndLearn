

* [Nginx --sendfile配置 - CSDN博客 ](http://blog.csdn.net/u011363729/article/details/70808585)

* sendfile
  * 设置为on表示启动高效传输文件的模式
  * sendfile可以让Nginx在传输文件时直接在磁盘和tcp socket之间传输数据。
  * 如果这个参数不开启
    * 会先在用户空间（Nginx进程空间）申请一个buffer
    * 用read函数把数据从磁盘读到cache
    * 再从cache读取到用户空间的buffer
    * 再用write函数把数据从用户空间的buffer写入到内核的buffer，最后到tcp socket。
  * 开启这个参数后可以让数据不用经过用户buffer。