
linux查看目录的四种方法(ls只显示目录) - CSDN博客 
http://blog.csdn.net/zwj1030711290/article/details/72566861


# 1.ls -d *
复制代码代码如下:

amosli@amosli-pc:~$ ls -d *
%APPDATA%     develop           many                    sorted.txt  workspace
bank          Documents         Music                   space       下载


# 2. find . -type d -maxdepth 1
如果不加-maxdepth 参数的话那么将会有无穷多目录被列出来。
复制代码代码如下:

amosli@amosli-pc:~$ find . -type d -maxdepth 1
./Videos
./Public
./%APPDATA%
./.kde
./.gnome2
./Music
# 3.ls -F | grep '/$'
使用linux管道命令，grep查找 '/$' 以/结尾的，也即是目录

amosli@amosli-pc:~$ ls -F | grep '/$'
%APPDATA%/
bank/
Desktop/
develop/
Documents/

# 4.ls -l | grep '^d'
复制代码代码如下:

amosli@amosli-pc:~$ ls -l | grep '^d'
drwxr-xr-x  3 amosli amosli   4096  6月 22  2013 %APPDATA%
drwxr-xr-x 36 amosli amosli   4096 12月 20 17:44 bank
drwxr-xr-x  4 amosli amosli   4096 12月 28 00:33 Desktop
drwxrwxr-x 13 amosli amosli   4096 12月 21 19:11 develop
drwxr-xr-x  3 amosli amosli   4096  7月  9 00:58 Documents