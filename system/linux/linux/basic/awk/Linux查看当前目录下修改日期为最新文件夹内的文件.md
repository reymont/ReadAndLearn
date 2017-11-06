

Linux查看当前目录下修改日期为最新文件夹内的文件_花家七童_新浪博客 
http://blog.sina.com.cn/s/blog_50d43ad50101g3p2.html

示例：
root@alex:/tmp# ll
    drwxr-xr-x 2 sun sun 4096 08-08 00:57 20130807
    drwxr-xr-x 2 sun sun 4096 08-07 00:57 20130806
    drwxr-xr-x 2 sun sun 4096 08-06 00:57 20130805
root@alex:/tmp# cd 20130807
root@alex:/tmp# ls 
    20130807_add.tar.z

`ls -t |awk '{if(NR==1)print $1}'`

命令：
cd /tmp;ml=$(ls -t |awk '{if(NR==1)print $1}';);cd $ml;ls;

## awk内置变量
awk有许多内置变量用来设置环境信息，这些变量可以被改变，下面给出了最常用的一些变量。

```sh
ARGC               命令行参数个数
ARGV               命令行参数排列
ENVIRON            支持队列中系统环境变量的使用
FILENAME           awk浏览的文件名
FNR                浏览文件的记录数
FS                 设置输入域分隔符，等价于命令行 -F选项
NF                 浏览记录的域的个数
NR                 已读的记录数
OFS                输出域分隔符
ORS                输出记录分隔符
RS                 控制记录分隔符
```