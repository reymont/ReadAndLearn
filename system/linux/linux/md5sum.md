

* [linux命令详解：md5sum命令 - boshuzhang的专栏 - CSDN博客 ](http://blog.csdn.net/boshuzhang/article/details/52795946)


生成文件md5值
```sh
#md5sum file
[root@master lianxi]# md5sum data 
#0a6de444981b68d6a049053296491e49  data
#使用通配对多个文件进行md5
[root@master lianxi]# md5sum *
#0a6de444981b68d6a049053296491e49  data
#13df384c47dd2638fd923f60c40224c6  data2
#md5sum校验的是文件内容，与文件名无关
```