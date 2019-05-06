

# http://www.cnblogs.com/itech/archive/2009/08/19/1549729.html

转自：http://blog.chinaunix.net/u3/100239/showart_1984963.html

首先介绍一下diff和patch。在这里不会把man在线文档上所有的选项都介绍一下，那样也没有必要。在99％的时间里，我们只会用到几个选项。所以必须学会这几个选项。
1、diff
    －－－－－－－－－－－－－－－－－－－－
    NAME
           diff - find differences between two files
    SYNOPSIS
           diff [options] from-file to-file
    －－－－－－－－－－－－－－－－－－－－

    简 单的说，diff的功能就是用来比较两个文件的不同，然后记录下来，也就是所谓的diff补丁。语法格式：diff 【选项】 源文件（夹） 目的文件（夹），就是要给源文件（夹）打个补丁，使之变成目的文件（夹），术语也就是“升级”。下面介绍三个最为常用选项：

    -r 是一个递归选项，设置了这个选项，diff会将两个不同版本源代码目录中的所有对应文件全部都进行一次比较，包括子目录文件。 
    -N 选项确保补丁文件将正确地处理已经创建或删除文件的情况。
    -u 选项以统一格式创建补丁文件，这种格式比缺省格式更紧凑些。

2、patch
    －－－－－－－－－－－－－－－－－－
    NAME
       patch - apply a diff file to an original
    SYNOPSIS
           patch [options] [originalfile [patchfile]]
           but usually just
           patch -pnum <patchfile>
    －－－－－－－－－－－－－－－－－－
    简单的说，patch就是利用diff制作的补丁来实现源文件（夹）和目的文件（夹）的转换。这样说就意味着你可以有源文件（夹）――>目的文件（夹），也可以目的文件（夹）――>源文件（夹）。下面介绍几个最常用选项：
    -p0 选项要从当前目录查找目的文件（夹）
    -p1 选项要忽略掉第一层目录，从当前目录开始查找。
************************************************************
在这里以实例说明：
--- old/modules/pcitable       Mon Sep 27 11:03:56 1999
+++ new/modules/pcitable       Tue Dec 19 20:05:41 2000
    如果使用参数-p0，那就表示从当前目录找一个叫做old的文件夹，在它下面寻找modules下的pcitable文件来执行patch操作。
    如果使用参数-p1， 那就表示忽略第一层目录（即不管old），从当前目录寻找modules的文件夹，在它下面找pcitable。这样的前提是当前目 录必须为modules所在的目录。而diff补丁文件则可以在任意位置，只要指明了diff补丁文件的路径就可以了。当然，可以用相对路径，也可以用绝 对路径。不过我一般习惯用相对路径。
************************************************************ 

-E 选项说明如果发现了空文件，那么就删除它
-R 选项说明在补丁文件中的“新”文件和“旧”文件现在要调换过来了（实际上就是给新版本打补丁，让它变成老版本）
下面结合具体实例来分析和解决，分为两种类型：为单个文件打补丁和为文件夹内的多个文件打补丁。
环境：在RedHat 9.0下面以armlinux用户登陆。
目录树如下：
    |-- bootloader
    |-- debug
    |-- images
    |-- kernel
    |-- program
    |-- rootfiles
    |-- software
    |-- source
    |-- sysapps
    |-- tmp
    |-- tools
下面在program文件夹下面建立patch文件夹作为实验用，然后进入patch文件夹。
一、为单个文件进行补丁操作
1、建立测试文件test0、test1
[armlinux@lqm patch]$ cat >>test0<<EOF
> 111111
> 111111
> 111111
> EOF
[armlinux@lqm patch]$ more test0
111111
111111
111111
[armlinux@lqm patch]$ cat >>test1<<EOF
> 222222
> 111111
> 222222
> 111111
> EOF
[armlinux@lqm patch]$ more test1
222222
111111
222222
111111
2、使用diff创建补丁test1.patch
[armlinux@lqm patch]$ diff -uN test0 test1 > test1.patch
【注：因为单个文件，所以不需要-r选项。选项顺序没有关系，即可以是-uN，也可以是-Nu。】
[armlinux@lqm patch]$ ls
test0 test1 test1.patch
[armlinux@lqm patch]$ more test1.patch
************************************************************
patch文件的结构
补丁头
补丁头是分别由---/+++开头的两行，用来表示要打补丁的文件。---开头表示旧文件，+++开头表示新文件。
一个补丁文件中的多个补丁
一个补丁文件中可能包含以---/+++开头的很多节，每一节用来打一个补丁。所以在一个补丁文件中可以包含好多个补丁。
块
块是补丁中要修改的地方。它通常由一部分不用修改的东西开始和结束。他们只是用来表示要修改的位置。他们通常以@@开始，结束于另一个块的开始或者一个新的补丁头。
块的缩进
块会缩进一列，而这一列是用来表示这一行是要增加还是要删除的。
块的第一列
+号表示这一行是要加上的。
-号表示这一行是要删除的。
没有加号也没有减号表示这里只是引用的而不需要修改。
************************************************************
***diff命令会在补丁文件中记录这两个文件的首次创建时间，如下***
--- test0       2006-08-18 09:12:01.000000000 +0800
+++ test1       2006-08-18 09:13:09.000000000 +0800
@@ -1,3 +1,4 @@
+222222
111111
-111111
+222222
111111
[armlinux@lqm patch]$ patch -p0 < test1.patch
patching file test0
[armlinux@lqm patch]$ ls
test0 test1 test1.patch
[armlinux@lqm patch]$ cat test0
222222
111111
222222
111111
3、可以去除补丁，恢复旧版本
[armlinux@lqm patch]$ patch -RE -p0 < test1.patch
patching file test0
[armlinux@lqm patch]$ ls
test0 test1 test1.patch
[armlinux@lqm patch]$ cat test0
111111
111111
111111
二、为多个文件进行补丁操作
1、创建测试文件夹
[armlinux@lqm patch]$ mkdir prj0
[armlinux@lqm patch]$ cp test0 prj0
[armlinux@lqm patch]$ ls
prj0 test0 test1 test1.patch
[armlinux@lqm patch]$ cd prj0/
[armlinux@lqm prj0]$ ls
test0
[armlinux@lqm prj0]$ cat >>prj0name<<EOF
> --------
> prj0/prj0name
> --------
> EOF
[armlinux@lqm prj0]$ ls
prj0name test0
[armlinux@lqm prj0]$ cat prj0name
--------
prj0/prj0name
--------
[armlinux@lqm prj0]$ cd ..
[armlinux@lqm patch]$ mkdir prj1
[armlinux@lqm patch]$ cp test1 prj1
[armlinux@lqm patch]$ cd prj1
[armlinux@lqm prj1]$ cat >>prj1name<<EOF
> ---------
> prj1/prj1name
> ---------
> EOF
[armlinux@lqm prj1]$ cat prj1name
---------
prj1/prj1name
---------
[armlinux@lqm prj1]$ cd ..

2、创建补丁
[armlinux@lqm patch]$ diff -uNr prj0 prj1 > prj1.patch
[armlinux@lqm patch]$ more prj1.patch
diff -uNr prj0/prj0name prj1/prj0name
--- prj0/prj0name       2006-08-18 09:25:11.000000000 +0800
+++ prj1/prj0name       1970-01-01 08:00:00.000000000 +0800
@@ -1,3 +0,0 @@
---------
-prj0/prj0name
---------
diff -uNr prj0/prj1name prj1/prj1name
--- prj0/prj1name       1970-01-01 08:00:00.000000000 +0800
+++ prj1/prj1name       2006-08-18 09:26:36.000000000 +0800
@@ -0,0 +1,3 @@
+---------
+prj1/prj1name
+---------
diff -uNr prj0/test0 prj1/test0
--- prj0/test0 2006-08-18 09:23:53.000000000 +0800
+++ prj1/test0 1970-01-01 08:00:00.000000000 +0800
@@ -1,3 +0,0 @@
-111111
-111111
-111111
diff -uNr prj0/test1 prj1/test1
--- prj0/test1 1970-01-01 08:00:00.000000000 +0800
+++ prj1/test1 2006-08-18 09:26:00.000000000 +0800
@@ -0,0 +1,4 @@
+222222
+111111
+222222
+111111
[armlinux@lqm patch]$ ls
prj0 prj1 prj1.patch test0 test1 test1.patch
[armlinux@lqm patch]$ cp prj1.patch ./prj0
[armlinux@lqm patch]$ cd prj0
[armlinux@lqm prj0]$ patch -p1 < prj1.patch 
patching file prj0name
patching file prj1name
patching file test0
patching file test1
[armlinux@lqm prj0]$ ls
prj1name prj1.patch test1
[armlinux@lqm prj0]$ patch -R -p1 < prj1.patch 
patching file prj0name
patching file prj1name
patching file test0
patching file test1
[armlinux@lqm prj0]$ ls
prj0name prj1.patch test0
-------------------------------------------------
总结一下：
单个文件
diff –uN from-file to-file >to-file.patch
patch –p0 < to-file.patch
patch –RE –p0 < to-file.patch

多个文件
diff –uNr from-docu to-docu >to-docu.patch
patch –p1 < to-docu.patch
patch –R –p1 <to-docu.patch