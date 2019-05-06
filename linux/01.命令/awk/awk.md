
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [linux awk命令详解](#linux-awk命令详解)
	* [简介](#简介)
	* [使用方法](#使用方法)
	* [调用awk](#调用awk)
	* [入门实例](#入门实例)
	* [awk内置变量](#awk内置变量)
	* [print和printf](#print和printf)
	* [awk编程](#awk编程)
		* [变量和赋值](#变量和赋值)
		* [条件语句](#条件语句)
		* [循环语句](#循环语句)
		* [数组](#数组)

<!-- /code_chunk_output -->

---

# linux awk命令详解

* [linux awk命令详解 - ggjucheng - 博客园 ](http://www.cnblogs.com/ggjucheng/archive/2013/01/13/2858470.html)

## 简介
awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

awk有3个不同版本: awk、nawk和gawk，未作特别说明，一般指gawk，gawk 是 AWK 的 GNU 版本。

awk其名称得自于它的创始人 Alfred Aho 、Peter Weinberger 和 Brian Kernighan 姓氏的首个字母。实际上 AWK 的确拥有自己的语言： AWK 程序设计语言 ， 三位创建者已将它正式定义为“样式扫描和处理语言”。它允许您创建简短的程序，这些程序读取输入文件、为数据排序、处理数据、对输入执行计算以及生成报表，还有无数其他的功能。

## 使用方法
awk '{pattern + action}' {filenames}
尽管操作可能会很复杂，但语法总是这样，其中 pattern 表示 AWK 在数据中查找的内容，而 action 是在找到匹配内容时所执行的一系列命令。花括号（{}）不需要在程序中始终出现，但它们用于根据特定的模式对一系列指令进行分组。 pattern就是要表示的正则表达式，用斜杠括起来。

awk语言的最基本功能是在文件或者字符串中基于指定规则浏览和抽取信息，awk抽取信息后，才能进行其他文本操作。完整的awk脚本通常用来格式化文本文件中的信息。

通常，awk是以文件的一行为处理单位的。awk每接收文件的一行，然后执行相应的命令，来处理文本。


 本章重点介绍命令行方式。

## 入门实例
假设last -n 5的输出如下

```sh
[root@www ~]# last -n 5 <==仅取出前五行
root     pts/1   192.168.1.100  Tue Feb 10 11:21   still logged in
root     pts/1   192.168.1.100  Tue Feb 10 00:46 - 02:28  (01:41)
root     pts/1   192.168.1.100  Mon Feb  9 11:41 - 18:30  (06:48)
dmtsai   pts/1   192.168.1.100  Mon Feb  9 11:41 - 11:41  (00:00)
root     tty1                   Fri Sep  5 14:09 - 14:10  (00:01)
如果只是显示最近登录的5个帐号

#last -n 5 | awk  '{print $1}'
root
root
root
dmtsai
root
```
awk工作流程是这样的：读入有'\n'换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，$0则表示所有域,$1表示第一个域,$n表示第n个域。默认域分隔符是"空白键" 或 "[tab]键",所以$1表示登录用户，$3表示登录用户ip,以此类推。

 

如果只是显示/etc/passwd的账户

```sh
#cat /etc/passwd |awk  -F ':'  '{print $1}'  
root
daemon
bin
sys
```
这种是awk+action的示例，每行都会执行action{print $1}。

-F指定域分隔符为':'。

如果只是显示/etc/passwd的账户和账户对应的shell,而账户与shell之间以tab键分割

```sh
#cat /etc/passwd |awk  -F ':'  '{print $1"\t"$7}'
root    /bin/bash
daemon  /bin/sh
bin     /bin/sh
sys     /bin/sh
```

如果只是显示/etc/passwd的账户和账户对应的shell,而账户与shell之间以逗号分割,而且在所有行添加列名name,shell,在最后一行添加"blue,/bin/nosh"。

```sh
cat /etc/passwd |awk  -F ':'  'BEGIN {print "name,shell"}  {print $1","$7} END {print "blue,/bin/nosh"}'
name,shell
root,/bin/bash
daemon,/bin/sh
bin,/bin/sh
sys,/bin/sh
....
blue,/bin/nosh
```
awk工作流程是这样的：先执行BEGING，然后读取文件，读入有/n换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，\$0则表示所有域,\$1表示第一个域,$n表示第n个域,随后开始执行模式所对应的动作action。接着开始读入第二条记录······直到所有的记录都读完，最后执行END操作。

搜索/etc/passwd有root关键字的所有行

```sh
#awk -F: '/root/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
```
这种是pattern的使用示例，匹配了pattern(这里是root)的行才会执行action(没有指定action，默认输出每行的内容)。
搜索支持正则，例如找root开头的: awk -F: '/^root/' /etc/passwd
搜索/etc/passwd有root关键字的所有行，并显示对应的shell

```sh
# awk -F: '/root/{print $7}' /etc/passwd             
/bin/bash
 这里指定了action{print $7}
```
> docker images | awk 'BEGIN{FS=" "}{printf("%s ",$3)}'

## print和printf
awk中同时提供了print和printf两种打印输出的函数。

其中print函数的参数可以是变量、数值或者字符串。字符串必须用双引号引用，参数用逗号分隔。如果没有逗号，参数就串联在一起而无法区分。这里，逗号的作用与输出文件的分隔符的作用是一样的，只是后者是空格而已。

printf函数，其用法和c语言中printf基本相似,可以格式化字符串,输出复杂时，printf更加好用，代码更易懂。



 

awk编程的内容极多，这里只罗列简单常用的用法，更多请参考 http://www.gnu.org/software/gawk/manual/gawk.html

分类: Linux/Unix