
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Linux Shell笔记之sed](#linux-shell笔记之sed)
	* [一、sed基础](#一-sed基础)
		* [1.定义编辑器](#1定义编辑器)
		* [2.同时使用多个编辑器](#2同时使用多个编辑器)
		* [3.从文件中读取编辑器命令](#3从文件中读取编辑器命令)
		* [4.sed替换选项](#4sed替换选项)
		* [5.sed使用地址](#5sed使用地址)
		* [6.删除行](#6删除行)
		* [7.插入与附加文本](#7插入与附加文本)
		* [8.修改行，机制同插入与附加](#8修改行机制同插入与附加)
		* [9.转换命令](#9转换命令)
		* [10.打印](#10打印)
		* [11.sed处理文件](#11sed处理文件)
	* [二、sed进阶](#二-sed进阶)
		* [2.多行删除命令](#2多行删除命令)
		* [3.多行打印命令](#3多行打印命令)
		* [4.保持空间](#4保持空间)
		* [5.排除命令](#5排除命令)
		* [6.改变流](#6改变流)
		* [7.模式替换](#7模式替换)
		* [8.在脚本中使用sed](#8在脚本中使用sed)
	* [三.sed实用工具](#三sed实用工具)

<!-- /code_chunk_output -->
---

* [linux sed命令详解 - ggjucheng - 博客园 ](http://www.cnblogs.com/ggjucheng/archive/2013/01/13/2856901.html)
* [shell脚本抽取文本文件中指定字符串的方法：sed+grep方法、awk+grep方法（必要时可以联合sed以及grep）、grep+cut方法 - menlinshuangxi的专栏 - CSDN博客 ](http://blog.csdn.net/menlinshuangxi/article/details/7979504)

# Linux Shell笔记之sed

* [Linux Shell笔记之sed - hunterno4的专栏 - CSDN博客 ](http://blog.csdn.net/hunterno4/article/details/17101021)


sed:流编辑器，stream editor
sed编辑器本身**不会修改文本文件的数据**，只会将修改后的数据发送到STDOUT
命令格式：sed options script file

## 一、sed基础

### 1.定义编辑器
```sh
# echo "this is a test" | sed 's/test/sed test/'           //将test替换为sed test
this is a sed test
```

### 2.同时使用多个编辑器
```sh
# echo "this is a test" | sed -e 's/test/sed test/;s/this/it/'
it is a sed test
```
执行多个命令，使用-e选项，命令间用分号隔开

### 3.从文件中读取编辑器命令
```sh
# cat sedtest1 
s/this/it/
s/test/sed test/
# cat data1 
this is a test
# sed -f sedtest1 data1            //使用-f选项指定文件
it is a sed test
```

### 4.sed替换选项
s/pattern/replacement/flags
```sh
1)数字替换标记
# cat cat
it is cat cat
it is cat cat
# sed 's/cat/dog/2' cat             //替换行中第二次出现的匹配模式
it is cat dog
it is cat dog

2）g,全局替换标记
# sed 's/cat/dog/g' cat             //全部替换
it is dog dog
it is dog dog

3）p,原来的行要打印出来
# sed -n 's/cat/dog/p' cat          //-n禁止sed编辑器输出，p只输出修改过的行，两者配合则只输出修改过的行
it is dog cat
it is dog cat

4）w,替换的结果保存到文件
# sed 's/cat/dog/w test' cat
it is dog cat
it is dog cat

5）替换字符
# sed 's!/bin/bash!/bin/csh!' passwd      //使用!号来当作字符串分隔符，使得路径名更容易读取与理解
root:x:0:0:root:/root:/bin/csh
```

### 5.sed使用地址
sed编辑器默认会作用于文本数据的所有行，若要指定某行或某些行，需要使用行寻址
```sh
# cat cat
it is cat cat
it is cat cat
it is cat 3
it is cat 4

1）数字方式的行寻址
# sed '2s/cat/dog/' cat                   //替换第二行中的匹配模式
it is cat cat
it is dog cat
# sed '2,3s/cat/dog/' cat                 //替换第二、三行的
it is cat cat
it is dog cat
it is dog 3
# sed '2,$s/cat/dog/' cat                 //$符号代码末尾，替换二至末尾的
it is cat cat
it is dog cat
it is dog 3
it is dog 4

2）文本模式过滤器
# sed '/3/s/cat/dog/' cat                  //使用正则表达式方式，只修改含有“3”的行
it is cat cat
it is cat cat
it is dog 3
```

### 6.删除行

```sh
# sed 'd' cat                               //不做任何匹配的话，d将删除所有
# sed '3d' cat                              //删除第三行
it is cat cat
it is cat cat
it is cat 4

# sed '/4/d' cat                            //删除含有“4”的行
it is cat cat
it is cat cat
it is cat 3
```

### 7.插入与附加文本

```sh
1）命令i在指定行前增加一个新行，命令a在指定行后附加一个新行
# echo "it is line 2"| sed 'i\it is line 1'       //i之后为右\符号
it is line 1
it is line 2

# echo "it is line 2"| sed 'a\it is line 1'
it is line 2
it is line 1

2）对指定行前插入或附加多行
# cat dataline 
line 1
line 2
line 3
# sed '1i\                                         //i前加数字，指定第几行
> it is line 1\                                    //插入多行每行的开头需加反斜线
> it is line 2' dataline
it is line 1
it is line 2
line 1
line 2
line 3

# sed '1a\
> it is line one\
> it is line two' dataline
line 1
it is line one
it is line two
line 2
line 3
```

### 8.修改行，机制同插入与附加

```sh
# sed '1c\it is line one' dataline
it is line one
line 2
line 3
```

### 9.转换命令
```sh
# sed 'y/123/789/' dataline                         //y命令转换，将123依次转换为789，长度需一致
line 7
line 8
line 9
```

### 10.打印

```sh
1）打印行
# sed -n '2,3p' dataline
line 2
line 3

2）打印行号
# sed '=' dataline                                   //=号命令打印行号
1
line 1
2
line 2
3
line 3

3)列出行
# cat datatab 
this    line    contains        tabs
# sed -n 'l' datatab                                  //l命令（list）可以显示制表符等特殊字符
this\tline\tcontains\ttabs$
```


### 11.sed处理文件

```sh
1）向文件写入，格式：[address]w filename
]# sed '1,2w test' dataline                           //w命令向文件写入数据，加-n可以不向控制台输出信息
line 1
line 2
line 3
# cat test 
line 1
line 2

2）从文件读取数据
# cat dataadd 
it is added line one
it is added line two
# sed '3r dataadd' dataline                            //r命令可以将一个文件中的数据插入到数据流中
line 1
line 2
line 3
it is added line one
it is added line two
```

## 二、sed进阶
模式空间（pattern space）：是一块活动缓存区，在sed编辑器执行命令时它会保存sed编辑器要检验的文本
保持空间（hold space）：另一块缓冲区域，可以在处理模式空间中其他行时用保持空间来临时保存一些行
sed编辑器会从脚本的顶部开始执行命令并一直处理到脚本的结尾（D命令例外）
1.next命令

```sh
1）单行next命令
# cat dataheader 
this is the header line

this is the first data line
this is the second data line

this is the last line
# sed '/header/{n;d}' dataheader                      //n命令使sed编辑器移动到数据流的下一文本行
this is the header line                               //找到header行，移到下一行，删除之
this is the first data line
this is the second data line

this is the last line

2）合并文本行
# sed '/first/{N;s/\n/ /}' dataheader                  //N命令将下一文本行加到已经在模式空间中的文本上
this is the header line

this is the first data line this is the second data line

this is the last line
```

### 2.多行删除命令

```sh
# cat dataheader 

this is the header line

this is the first data line
this is the second data line
# sed '/^$/{N;/header/D}' dataheader                    //D命令只删除模式空间中的第一行
this is the header line                                 //找到空白行，移到下一行，若匹配header，则用D命令删除第一行

this is the first data line
this is the second data line
```


### 3.多行打印命令

```sh
# cat dataroot 
the first meeting of the root
user group will be held on Tuesday.
All root user should attend this meeting
# sed -n 'N;/root\nuser/P' dataroot                     //P命令只会打印模式空间中的第一行
the first meeting of the root
```

### 4.保持空间
h            将模式空间复制到保持空间
H            将模式空间附加到保持空间
g            将保持空间复制到模式空间
G            将保持空间附加到模式空间
x            交换模式空间和保持空间的内容
```sh
# cat dataheader 
this is the header line
this is the first data line
this is the second data line
# sed -n '/first/{
> h                                  //将第一行复制到保持空间
> n                                  //读取下一行，并放到模式空间
> p                                  //打印模式空间的数据，即第二行
> g                                  //将保持空间复制到模式空间
> p                                  //打印模式空间的数据，即第一行
> }' dataheader
this is the second data line
this is the first data line
```

### 5.排除命令
!感叹号命令用来排除命令，即让原本会起作用的命令不起作用
```sh
# sed -n '/header/!p' dataheader             //除了header行，其它都不打印了
this is the first data line
this is the second data line

# sed -n '1!G;h;$p' dataheader              //反转数据，1!G，第一行时，不进行将保持空间附加到模式空间
this is the last line

this is the second data line
this is the first data line
this is the header line

# tac dataheader                             //tac命令执行cat命令的反向功能
this is the last line

this is the second data line
this is the first data line
this is the header line
```

### 6.改变流

```sh
1）.跳转（branch）
格式：[address]b [label]                    //如果没有label，默认跳转到脚本的结尾
# sed '{/first/b jump1;s/this is the/no jump on/
> :jump1
> s/this is the/jump here on/}' dataheader
no jump on header line
jump here on first data line
no jump on second data line

no jump on last line

2）测试命令（test）
如果替换命令成功匹配了，测试命令会跳转到指定的标签
# sed '{
> s/first/matched/
> t                                          //如果第一个替换命令匹配成功，则替换，并跳过后面的命令
> s/this is the/no match on /                //如果第一个替换命令不匹配，则第二个命令会被执行
> }' dataheader
no match on  header line
this is the matched data line
no match on  second data line

no match on  last line

# echo "this, is, a, test, to, remove, commas"|sed -n '{
> :start                                           //标签以:号开头
> s/,//1p
> t start
> }'
this is, a, test, to, remove, commas
this is a, test, to, remove, commas
this is a test, to, remove, commas
this is a test to, remove, commas
this is a test to remove, commas
this is a test to remove commas
```


### 7.模式替换

```sh
1）and符号
# echo "the cat sleeps in the hat"|sed 's/.at/".at"/g'
the ".at" sleeps in the ".at"
# echo "the cat sleeps in the hat"|sed 's/.at/"&"/g'       //&符号用来代表替换命令中的匹配模式
the "cat" sleeps in the "hat"

2）替换单独的单词
# echo "the furry cat is pretty"|sed 's/furry \(.at\)/\1/'    //用圆括号来定义替换模式的子字符串，圆括号需转义
the cat is pretty                                             //\1代表第一个模块，\2代表第二个模块
```

### 8.在脚本中使用sed

```sh
1）使用包装脚本
# vi reverse
#!/bin/bash

sed -n '{
1!G
h
$p
}' $1                                           //使用第一个参数
# ./reverse dataheader 
this is the last line

this is the second data line
this is the first data line
this is the header line
```

## 三.sed实用工具
1.删除HTML标签
```sh
# cat index.html 
<html><body><h1>welcome to hunter's computer!</h1></body></html>
# sed 's/<[^>]*>//g;/^$/d' index.html            //s/<[^>]*>//g删除标签，/^$/d删除空白行
welcome to hunter's computer!
```