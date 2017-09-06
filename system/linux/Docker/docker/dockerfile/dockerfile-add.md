

* [docker学习笔记16：Dockerfile 指令 ADD 和 COPY介绍 - 51kata - 博客园 ](http://www.cnblogs.com/51kata/p/5264894.html)

docker学习笔记16：Dockerfile 指令 ADD 和 COPY介绍

一、ADD指令

ADD指令的功能是将主机构建环境（上下文）目录中的文件和目录、以及一个URL标记的文件 拷贝到镜像中。

其格式是： ADD  源路径  目标路径

如：

```dockerfile
#test
FROM ubuntu
MAINTAINER hello
ADD test1.txt test1.txt
ADD test1.txt test1.txt.bak
ADD test1.txt /mydir/
ADD data1  data1
ADD data2  data2
ADD zip.tar /myzip
```
有如下注意事项：

1、如果源路径是个文件，且目标路径是以 / 结尾， 则docker会把目标路径当作一个目录，会把源文件拷贝到该目录下。

如果目标路径不存在，则会自动创建目标路径。

2、如果源路径是个文件，且目标路径是不是以 / 结尾，则docker会把目标路径当作一个文件。

如果目标路径不存在，会以目标路径为名创建一个文件，内容同源文件；

如果目标文件是个**存在的文件，会用源文件覆盖它**，当然只是内容覆盖，文件名还是目标文件名。

如果目标文件实际是个存在的目录，则会源文件拷贝到该目录下。 注意，这种情况下，最好显示的以 / 结尾，以避免混淆。

3、如果源路径是个目录，且目标路径不存在，则docker会自动以目标路径创建一个目录，把源路径目录下的文件拷贝进来。

如果目标路径是个已经存在的目录，则docker会把源路径目录下的文件拷贝到该目录下。

4、如果源文件是个归档文件（压缩文件），则docker会自动帮解压。

 

二、COPY指令

COPY指令和ADD指令功能和使用方式类似。只是COPY指令不会做自动解压工作。