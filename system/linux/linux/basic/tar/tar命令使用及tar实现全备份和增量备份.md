

tar命令使用及tar实现全备份和增量备份 - CSDN博客 http://blog.csdn.net/justdb/article/details/10040973

首先弄清楚何为全备、增量备份、差异备份。简而言之，可以这样理解：
全备：对所有的文件做一次备份。
增量备份：本次和上一次的的差异。
差异备份：在全备的基础上做备份。

# 一 tar命令

```sh
[plain] view plain copy
#创建测试文件夹和文件  
[root@serv01 web]# cd /data  
[root@serv01 data]# ls  
[root@serv01 data]# mkdir /work  
[root@serv01 data]# mkdir /work/upload  
[root@serv01 data]# cd /work/upload/  
[root@serv01 upload]# touchaa0{1,2,3,4,5}.txt  
[root@serv01 upload]# ls  
aa01.txt aa02.txt  aa03.txt  aa04.txt aa05.txt  
   
#创建压缩包  
[root@serv01 data]# tar -cvf upload01.tar/work/upload/  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
#查看压缩包里面包含的文件  
[root@serv01 data]# tar -tf upload01.tar  
work/upload/  
work/upload/aa03.txt  
work/upload/aa01.txt  
work/upload/aa04.txt  
work/upload/aa05.txt  
work/upload/aa02.txt  
#删除掉数据，模拟数据丢失  
[root@serv01 data]# rm -rf /work  
#解压  
[root@serv01 data]# tar -xvf upload01.tar-C /  
work/upload/  
work/upload/aa03.txt  
work/upload/aa01.txt  
work/upload/aa04.txt  
work/upload/aa05.txt  
work/upload/aa02.txt  
[root@serv01 data]# ls /work  
upload  
[root@serv01 data]# ls  
upload01.tar  
#压缩时包含文件路径  
[root@serv01 data]# tar -cPvf upload02.tar/work/upload/  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
#解压时就不需要指定文件路径了  
[root@serv01 data]# tar -xPvf upload02.tar  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
[root@serv01 data]# ls /work/  
upload  
        
#不一定需要f参数，可以使用重定向解决  
[root@serv01 data]# tar -cv upload03.tar/work/upload/  
tar: upload03.tar: Cannot stat: No suchfile or directory  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
work/upload/00007550000000000000000000000000121766767060120445ustar  rootrootwork/upload/aa03.txt00006440000000000000000000000000121766767060133170ustar rootrootwork/upload/aa01.txt00006440000000000000000000000000121766767060133150ustar  rootrootwork/upload/aa04.txt00006440000000000000000000000000121766767060133200ustar  rootrootwork/upload/aa05.txt00006440000000000000000000000000121766767060133210ustar rootrootwork/upload/aa02.txt00006440000000000000000000000000121766767060133160ustar  rootroottar: Exiting with failurestatus due to previous errors  
#指定路径，重定向到upload03.tar  
[root@serv01 data]# tar -cv /work/upload/> upload03.tar  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
#删除目录  
[root@serv01 data]# rm -rf /work/  
#解压，指定输入源  
[root@serv01 data]# tar -xv -C / <upload03.tar  
work/upload/  
work/upload/aa03.txt  
work/upload/aa01.txt  
work/upload/aa04.txt  
work/upload/aa05.txt  
work/upload/aa02.txt  
#查看  
[root@serv01 data]# ls /work/  
upload  
[root@serv01 data]# tar -tf upload03.tar  
work/upload/  
work/upload/aa03.txt  
work/upload/aa01.txt  
work/upload/aa04.txt  
work/upload/aa05.txt  
work/upload/aa02.txt  
#测试路径加的不一样的效果  
   
[root@serv01 data]# cd /work/  
[root@serv01 work]# tar -cf upload04.tarupload/  
[root@serv01 work]# tar -tf upload04.tar  
upload/  
upload/aa03.txt  
upload/aa01.txt  
upload/aa04.txt  
upload/aa05.txt  
upload/aa02.txt  
   
#会解压到根下面的upload目录下  
[root@serv01 work]# tar -xv -C / <upload04.tar  
upload/  
upload/aa03.txt  
upload/aa01.txt  
upload/aa04.txt  
upload/aa05.txt  
upload/aa02.txt  
   
[root@serv01 work]# ls /upload/  
aa01.txt aa02.txt  aa03.txt  aa04.txt aa05.txt  
#创建aa06.txt文件  
[root@serv01 upload]# touch aa06.txt  
[root@serv01 upload]# cd /data  
[root@serv01 data]# tar -tf upload02.tar  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
#增加aa06.txt到upload02.tar中  
[root@serv01 data]# tar -Pvf upload02.tar-r /work/upload/aa06.txt  
/work/upload/aa06.txt  
[root@serv01 data]# tar -tf upload02.tar  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
/work/upload/aa06.txt  
   
#演示文件修改后，更新压缩包  
#编辑文件  
[root@serv01 data]# vim/work/upload/aa01.txt  
#更新  
[root@serv01 data]# tar -uPvf upload02.tar/work/upload/  
/work/upload/aa01.txt  
[root@serv01 data]# tar -tf upload02.tar  
tar: Removing leading `/' from member names  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
/work/upload/aa06.txt  
/work/upload/aa01.txt  
   
#删除文件，然后恢复  
[root@serv01 data]# rm -rf /work/  
[root@serv01 data]# ls /work/*  
ls: cannot access /work/*: No such file or directory  
[root@serv01 data]# tar -xPvf upload02.tar  
/work/upload/  
/work/upload/aa03.txt  
/work/upload/aa01.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa02.txt  
/work/upload/aa06.txt  
/work/upload/aa01.txt  
#查看刚才更新的文件，发现没任何问题  
[root@serv01 data]# cat/work/upload/aa01.txt  
this is aa01.txt  
   
#找到etc下面以conf结尾的文件，然后打包  
[root@serv01 data]# find /etc/ -name"*.conf" | xargs tar -Pcvf test01.tar  
#找到etc下面以conf结尾的文件，但不包含yum.conf，然后打包  
[root@serv01 data]# find /etc/ -name"*.conf" ! -name "yum.conf" | xargs tar -Pcvf test02.tar  
[root@serv01 data]# find /etc/ -name"*.conf" ! -name yum.conf | xargs tar -Pcvf test02.tar  
   
#指定文件，然后备份  
#将配置文件写到file1  
[root@serv01 data]# find /etc -name"*.conf" > file1  
#查看文件，可以看到所有的配置文件列表都已经存在了（注意是文件路径）  
[root@serv01 data]# vim file1  
#创建conf01.tar，然后T指定文件  
[root@serv01 data]# tar -cPvf conf01.tar -Tfile1  
[root@serv01 data]# tar -tf conf01.tar  
[root@serv01 data]# ls -h conf01.tar -l  
-rw-r--r—. 1 root root 250K Aug  2 18:18 conf01.tar  
```

# 二 tar命令实现——全备和增量备份

```sh
[plain] view plain copy
[root@serv01 data]# ls /work/upload/  
aa01.txt aa02.txt  aa03.txt  aa04.txt aa05.txt  aa06.txt  
[root@serv01 data]# rm -rf upload01.tar  
#这是全备，无法实现增量备份功能  
[root@serv01 data]# tar -cPvf upload01.tar/work/upload/  
#g指定标志文件  
[root@serv01 data]# tar -g flag -cPvfupload01.tar /work/upload/  
tar: /work/upload: Directory is new  
/work/upload/  
/work/upload/aa01.txt  
/work/upload/aa02.txt  
/work/upload/aa03.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa06.txt  
[root@serv01 data]# vim flag  
#新建文件  
[root@serv01 data]# touch /work/upload/aa07.txt  
#更改文件  
[root@serv01 data]# vim/work/upload/aa02.txt  
[root@serv01 data]# tar -g flag -cPvfupload02.tar /work/upload/  
/work/upload/  
/work/upload/aa02.txt  
/work/upload/aa07.txt  
[root@serv01 data]# tar -tPf upload02.tar  
/work/upload/  
/work/upload/aa02.txt  
/work/upload/aa07.txt  
   
[root@serv01 data]# touch/work/upload/aa08.txt  
[root@serv01 data]# rm -rf/work/upload/aa01.txt  
[root@serv01 data]# ls /work/upload/  
aa02.txt aa03.txt  aa04.txt  aa05.txt aa06.txt  aa07.txt  aa08.txt  
[root@serv01 data]# tar -g flag -cPvfupload03.tar /work/upload/  
/work/upload/  
/work/upload/aa08.txt  
   
#恢复全备，逐次恢复  
#数据丢失  
[root@serv01 data]# rm -rf /work/*  
[root@serv01 data]# ls /work/  
#先恢复全备  
[root@serv01 data]# tar -g flag -xPvfupload01.tar  
/work/upload/  
/work/upload/aa01.txt  
/work/upload/aa02.txt  
/work/upload/aa03.txt  
/work/upload/aa04.txt  
/work/upload/aa05.txt  
/work/upload/aa06.txt  
#可以看到数据回来了  
[root@serv01 data]# ls /work/upload/  
aa01.txt aa02.txt  aa03.txt  aa04.txt aa05.txt  aa06.txt  
#查看aa02.txt文件，发现内容没有  
[root@serv01 data]# cat/work/upload/aa02.txt  
#恢复文件，从增量备份upload02.tar文件中来  
[root@serv01 data]# tar -g flag -xPvfupload02.tar  
/work/upload/  
/work/upload/aa02.txt  
/work/upload/aa07.txt  
#查看aa02.txt文件，内容回来了  
[root@serv01 data]# cat/work/upload/aa02.txt  
hello world  
#恢复文件，从增量备份upload03.tar文件中来  
[root@serv01 data]# tar -g flag -xPvfupload03.tar  
/work/upload/  
tar: Deleting `/work/upload/aa01.txt'  
/work/upload/aa08.txt  
[root@serv01 data]# ls /work/upload/  
aa02.txt aa03.txt  aa04.txt  aa05.txt aa06.txt  aa07.txt  aa08.txt  
```

   我的邮箱：wgbno27@163.com
  新浪微博：@Wentasy27         
  微信公众平台：JustOracle（微信号：justoracle）
  数据库技术交流群：336882565（加群时验证 From CSDN XXX）
  Oracle交流讨论组：https://groups.google.com/d/forum/justoracle
  By Larry Wen