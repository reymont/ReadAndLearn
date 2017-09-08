

# docker save命令-打包image

* [docker save命令-打包image | 简果网 ](http://www.simapple.com/343.html)

docker save命令-打包image
Posted by simapple on Sunday, 10 August 2014
save 将image打包保存
Usage: docker save IMAGE

Save an image to a tar archive (streamed to STDOUT bydefault)-o,--output=""Write to an file, instead of STDOUT
Produces a tarred repository to the standard output stream. Contains all parent layers, and all tags + versions, or specified repo:tag.

打包的可以使用 docker load

```sh
$ sudo docker save busybox > busybox.tar
$ ls -sh busybox.tar
2.7M busybox.tar
$ sudo docker save --output busybox.tar busybox
$ ls -sh busybox.tar
2.7M busybox.tar
$ sudo docker save -o fedora-all.tar fedora
$ sudo docker save -o fedora-latest.tar fedora:latest
```
转载请注明来自：简果网

# Docker images导出和导入

* [Docker images导出和导入 - 简书](http://www.jianshu.com/p/8408e06b7273)

之前已配置好基础镜像，其他地方也需要用到这些镜像时怎么办呢？
答案：镜像的导入和导出功能。

## 镜像的保存
```
[root@wxtest1607 ~]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tomcat8                   3.0                 90457edaf6ff        6 hours ago         1.036 GB
[root@wxtest1607 lixr]# docker save 9045 > tomcat8-apr.tar
[root@wxtest1607 lixr]# ls -lh
总用量 1.2G
-rw-r--r--  1 root root  1005M 8月  24 17:42 tomcat8-apr.tar
```


## 镜像的导入
当前缺一台CentOS7服务器，实践方式变成，先删除image，然后再导入，折腾呀！
```sh
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tomcat8                   3.0                 90457edaf6ff        7 hours ago         1.036 GB
[root@wxtest1607 lixr]# docker rmi 9045
Untagged: tomcat8:3.0
Deleted: sha256:90457edaf6ff4ce328dd8a3131789c66e6bd89e1ce40096b89dd49d6e9d62bc8
Deleted: sha256:00df1d61992f2d87e7149dffa7afa5907df3296f5775c53e3ee731972e253600
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
[root@wxtest1607 lixr]# docker load < tomcat8-apr.tar
60685807648a: Loading layer [==================================================>] 442.7 MB/442.7 MB
[root@wxtest1607 lixr]# yer [>                                                  ] 527.7 kB/442.7 MB
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
<none>                    <none>              90457edaf6ff        7 hours ago         1.036 GB
[root@wxtest1607 lixr]# docker tag 9045 tomcat8-apr:3.0
[root@wxtest1607 lixr]# 
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tomcat8-apr               3.0                 90457edaf6ff        7 hours ago         1.036 GB
```

## 容器的导出
```sh
[root@wxtest1607 lixr]# docker ps 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                               NAMES
b91d9ad83efa        9045                "/bin/bash"         18 seconds ago      Up 15 seconds                                           trusting_colden
f680b58163ab        aa79                "/bin/bash"         8 hours ago         Up 8 hours                                              stupefied_mayer
4db6aa9b8278        4052                "mysqld_safe"       21 hours ago        Up 21 hours         8080/tcp, 0.0.0.0:53307->3306/tcp   nostalgic_leavitt
7bcfe52af7a0        599d                "mysqld_safe"       21 hours ago        Up 21 hours         8080/tcp, 0.0.0.0:53306->3306/tcp   sleepy_hodgkin
[root@wxtest1607 lixr]# 
[root@wxtest1607 lixr]# 
[root@wxtest1607 lixr]# docker export b91d9ad83efa > tomcat80824.tar
[root@wxtest1607 lixr]# ls -lh
总用量 2.1G
-rw-r--r--  1 root root   943M 8月  24 18:37 tomcat80824.tar
-rw-r--r--  1 root root  1005M 8月  24 17:42 tomcat8-apr.tar
```
b91d9ad83efa 是 镜像90457edaf6ff 启动后的容器。
镜像导出的文件比容器导出文件大哦。
## 容器的导入
```sh
[root@wxtest1607 lixr]# docker import tomcat80824.tar
sha256:880fc96a6bb6abdfa949a56d40ef76f32f086fa11024ddcfb4e4e8b22041d5f2
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
<none>                    <none>              880fc96a6bb6        6 seconds ago       971.9 MB
[root@wxtest1607 lixr]# docker tag 880f tomcat80824:1.0
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
tomcat80824               1.0                 880fc96a6bb6        About a minute ago   971.9 MB
tomcat8-apr               3.0                 90457edaf6ff        8 hours ago          1.036 GB
```

## 镜像和容器 导出和导入的区别
镜像导入和容器导入的区别：
1）容器导入 是将当前容器 变成一个新的镜像
2）镜像导入 是复制的过程
save 和 export区别：
1）save 保存镜像所有的信息-包含历史
2）export 只导出当前的信息
```sh
[root@wxtest1607 lixr]# docker history 880fc96a6bb6
IMAGE               CREATED             CREATED BY          SIZE                COMMENT
880fc96a6bb6        12 minutes ago                          971.9 MB            Imported from -
[root@wxtest1607 lixr]# docker history 90457edaf6ff
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
90457edaf6ff        8 hours ago         /bin/bash                                       434.4 MB            
<missing>           23 hours ago        /bin/bash                                       406.5 MB            
<missing>           7 weeks ago         /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
<missing>           7 weeks ago         /bin/sh -c #(nop) LABEL license=GPLv2           0 B                 
<missing>           7 weeks ago         /bin/sh -c #(nop) LABEL vendor=CentOS           0 B                 
<missing>           7 weeks ago         /bin/sh -c #(nop) LABEL name=CentOS Base Imag   0 B                 
<missing>           7 weeks ago         /bin/sh -c #(nop) ADD file:b3bdbca0669a03490e   194.6 MB            
<missing>           7 weeks ago         /bin/sh -c #(nop) MAINTAINER The CentOS Proje   0 B
```
 部署运维

作者：灼灼2015
链接：http://www.jianshu.com/p/8408e06b7273
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。