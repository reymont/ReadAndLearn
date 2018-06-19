

sed命令详解 - 为爱奋斗不息 - 博客园 
https://www.cnblogs.com/ctaixw/p/5860221.html

sed：Stream Editor文本流编辑，sed是一个“非交互式的”面向字符流的编辑器。能同时处理多个文件多行的内容，可以不对原文件改动，把整个文件输入到屏幕,可以把只匹配到模式的内容输入到屏幕上。还可以对原文件改动，但是不会再屏幕上返回结果。

sed命令的语法格式：
sed的命令格式： sed [option] 'sed command'filename
sed的脚本格式：sed [option] -f 'sed script'filename

sed命令的选项(option)：

-n ：只打印模式匹配的行
-e ：直接在命令行模式上进行sed动作编辑，此为默认选项
-f ：将sed的动作写在一个文件内，用–f filename 执行filename内的sed动作
-r ：支持扩展表达式
-i ：直接修改文件内容

sed在文件中查询文本的方式：

1)使用行号，可以是一个简单数字，或是一个行号范围

x
x为行号
x,y
表示行号从x到y
/pattern
查询包含模式的行

/pattern /pattern

查询包含两个模式的行

pattern/,x

在给定行号上查询包含模式的行

x,/pattern/

通过行号和模式查询匹配的行

x,y!

查询不包含指定行号x和y的行


2)使用正则表达式、扩展正则表达式(必须结合-r选项)

```sh
^       锚点行首的符合条件的内容，用法格式"^pattern"
$       锚点行首的符合条件的内容，用法格式"pattern$"
^$      空白行
.       匹配任意单个字符
*       匹配紧挨在前面的字符任意次(0,1,多次)
.*

匹配任意长度的任意字符

\？

匹配紧挨在前面的字符0次或1次

\{m,n\}

匹配其前面的字符至少m次，至多n次

\{m,\}

匹配其前面的字符至少m次

\{m\}

精确匹配前面的m次\{0,n\}:0到n次

\<

锚点词首----相当于 \b，用法格式：\<pattern

\>

锚点词尾，用法格式:\>pattern

\<pattern\>

单词锚点

 	
分组，用法格式：pattern，引用\1,\2

[]

匹配指定范围内的任意单个字符

[^]

匹配指定范围外的任意单个字符

[:digit:]

所有数字, 相当于0-9， [0-9]---> [[:digit:]]

[:lower:]

所有的小写字母

[:upper:]

所有的大写字母

[:alpha:]

所有的字母

[:alnum:]

相当于0-9a-zA-Z

[:space:]

空白字符

[:punct:]

所有标点符号

```

[java] view plain copy
 
#######sed的匹配模式支持正则表达式#####################  
sed'5 q'/etc/passwd#打印前5行  
sed-n '/r*t/p'/etc/passwd#打印匹配r有0个或者多个，后接一个t字符的行  
sed-n '/.r.*/p'/etc/passwd#打印匹配有r的行并且r后面跟任意字符  
sed-n '/o*/p'/etc/passwd#打印o字符重复任意次  
sed-n '/o\{1,\}/p'/etc/passwd#打印o字重复出现一次以上  
sed-n '/o\{1,3\}/p'/etc/passwd#打印o字重复出现一次到三次之间以上  
sed的编辑命令(sed command)：

p

打印匹配行（和-n选项一起合用）

=

显示文件行号

a\

在定位行号后附加新文本信息

i\

在定位行号后插入新文本信息

d

删除定位行

c\

用新文本替换定位文本

w filename

写文本到一个文件，类似输出重定向 >

r filename

从另一个文件中读文本，类似输入重定向 <

s

使用替换模式替换相应模式

q

第一个模式匹配完成后退出或立即退出

l

显示与八进制ACSII代码等价的控制符

{}

在定位行执行的命令组，用分号隔开

n

从另一个文件中读文本下一行，并从下一条命令而不是第一条命令开始对其的处理

N

在数据流中添加下一行以创建用于处理的多行组

g

将模式2粘贴到/pattern n/

y

传送字符，替换单个字符

对文件的操作无非就是”增删改查“，怎样用sed命令实现对文件的”增删改查“，玩转sed是写自动化脚本必须的基础之一。

sed命令打印文件信息(查询)：

[java] view plain copy
 
####用sed打印文件的信息的例子的命令######  
sed -n '/^#/!p'  /etc/vsftpd/vsftpd.conf         
sed -n '/^#/!{/^$/!p}'  /etc/vsftpd/vsftpd.conf  
sed -e '/^#/d' -e '/^$/d'  /etc/vsftpd/vsftpd.conf  
sed -n '1,/adm/p' /etc/passwd  
sed -n '/adm/,6p' /etc/passwd  
sed -n '/adm/,4p' /etc/passwd  
sed -n '/adm/,2p' /etc/passwd  
###以下图片是对这些sed命令例子的解释和显示结果  








sed命令实现对文件内容的添加：(对源文件添加的话就用-i参数):

[java] view plain copy
 
####sed命令可以实现的添加######  
#1）匹配行的行首添加，添加在同行  
#2）匹配行的行中的某个字符后添加  
#3）匹配行的行尾添加字符  
#4）匹配行的行前面行添加  
#5）匹配行的行后面行添加  
#6）文件的行首添加一行  
  [root@jie1 ~]# sed -i '1 i\sed command start' myfile  
#7）文件的行尾追加一行  
  [root@jie1 ~]# sed -i '$a \sed command end' myfile  


 

sed命令实现对文件内容的删除：(对源文件直接删除用-i参数):

sed的删除操作是针对文件的行，如果想删除行中的某个字符，那就用替换(别急，替换稍后就讲，而且替换是sed最常用的)


重点：sed命令实现对文件内容的替换（替换是在shell自动化脚本中用到最多的操作）

[java] view plain copy
 
#================源文件里面的内容===============================  
[root@jie1 ~]# cat test  
anonymous_enable=YES  
write_enable=YES  
local_umask=022  
xferlog_enable=YES  
connect_from_port_20=YES  
root:x:0:0:root:/root:/bin/bash  
bin:x:1:1:bin:/bin:/sbin/nologin  
daemon:x:2:2:daemon:/sbin:/sbin/nologin  
adm:x:3:4:adm:/var/adm:/sbin/nologin  
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin  
DEVICE="eth0"  
BOOTPROTO="static"  
HWADDR="00:0C:29:90:79:78"  
ONBOOT="yes"  
IPADDR=172.16.22.1  
NETMASK=255.255.0.0  
#======================================================================  
[root@jie1 ~]# sed -i '/DEVICE/c\Ethernet' test   
        #匹配DEVICE的行，替换成Ethernet这行  
[root@jie1 ~]# sed -i 's/static/dhcp/' test       
        #把static替换成dhcp(/,@,#都是前面所说的地址定界符)  
[root@jie1 ~]# sed -i '/IPADDR/s@22\.1@10.12@' test  
        #匹配IPADDR的行，把22.1替换成10.12由于.号有特殊意义所有需要转义  
[root@jie1 ~]# sed -i '/connect/s#YES#NO#' test   
        #匹配connect的行，把YES替换成NO  
[root@jie1 ~]# sed -i 's/bin/tom/2g' test         
        #把所有匹配到bin的行中第二次及第二次之后出现bin替换成tom  
[root@jie1 ~]# sed -i 's/daemon/jerry/2p' test    
        #把所有匹配到bin的行中第二次出现的daemon替换成jerry，并在生产与匹配行同样的行  
[root@jie1 ~]# sed -i 's/adm/boss/2' test         
        #把所有匹配到adm的行中仅仅只是第二次出现的adm替换成boss  
[root@jie1 ~]# sed -i '/root/{s/bash/nologin/;s/0/1/g}' test  
        #匹配root的行，把bash替换成nologin，且把0替换成1  
[root@jie1 ~]# sed -i 's/root/(&)/g' test                   
        #把root用括号括起来，&表示引用前面匹配的字符  
[root@jie1 ~]# sed -i 's/BOOTPROTO/#BOOTPROTO/' test        
        #匹配BOOTPROTO替换成#BOOTPROTO，在配置文件中一般用于注释某行  
[root@jie1 ~]# sed -i 's/ONBOOT/#&/' test                   
        #匹配ONBOOT的行的前面添加#号，在配置文件中也表示注释某行  
[root@jie1 ~]# sed -i '/ONBOOT/s/#//' test                  
        #匹配ONBOOT的行，把#替换成空，即去掉#号，也一般用作去掉#注释  
#================执行以上sed命令之后文件显示的内容====================  
[root@jie1 ~]# cat test  
anonymous_enable=YES  
write_enable=YES  
local_umask=022  
xferlog_enable=YES  
connect_from_port_20=NO  
(root):x:1:1:(root):/(root):/bin/nologin  
bin:x:1:1:tom:/tom:/stom/nologin  
daemon:x:2:2:jerry:/sbin:/stom/nologin  
daemon:x:2:2:jerry:/sbin:/stom/nologin  
adm:x:3:4:boss:/var/adm:/sbin/nologin  
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin  
Ethernet  
#BOOTPROTO="dhcp"  
HWADDR="00:0C:29:90:79:78"  
ONBOOT="yes"  
IPADDR=172.16.10.12  
NETMASK=255.255.0.0  
sed引用变量：（在自动化shell脚本 中也经常会使用到变量）

第一种当sed命令里面没有默认的变量时可以把单引号改成双引号；

第二种当sed命令里面有默认的变量时，那自己定义的变量需要加单引号，且sed里面的语句必须用单引

[java] view plain copy
 
[root@jie1 ~]# cat >> myfile << EOF  
> hello world  
> i am jie  
> how are you  
> EOF   #先生成一个文件  
[root@jie1 ~]# cat myfile  
hello world  
i am jie  
how are you  
[root@jie1 ~]# name=li  
         #定义一个变量，且给变量赋值  
[root@jie1 ~]# sed -i "s/jie/$name/" myfile  
         #把匹配jie的字符替换成变量的值  
[root@jie1 ~]# cat myfile  
hello world  
i am li  
how are you  
[root@jie1 ~]# sed -i "$a $name" myfile  
          #当sed命令也有默认变量时，在去引用自己定义的变量会出现语法错误  
sed: -e expression #1, char 3: extra characters after command  
[root@jie1 ~]# sed -i '$a '$name'' myfile  
          #在引用自定义的变量时，sed语句必须用单引引住，然后把自定义的变量也用单引号引住  
[root@jie1 ~]# cat myfile  
hello world  
i am li  
how are you  
li  
[root@jie1 ~]#  
sed的其它高级使用：

1）把正在用sed操作的文件的内容写到例外一个文件中

[java] view plain copy
 
[root@jie1 ~]# cat test   #sed操作的文件中的内容  
Ethernet  
#BOOTPROTO="dhcp"  
HWADDR="00:0C:29:90:79:78"  
ONBOOT="yes"  
IPADDR=172.16.10.12  
NETMASK=255.255.0.0  
[root@jie1 ~]# sed -i 's/IPADDR/ip/w ip.txt' test  
       #把sed操作的文件内容保存到另外一个文件中，w表示保存，ip.txt文件名  
[root@jie1 ~]# cat ip.txt  #查看新文件的内容  
ip=172.16.10.12  
[root@jie1 ~]#  
2）读取一个文件到正在用sed操作的文件中

[java] view plain copy
 
[root@jie1 ~]# cat myfile   #文件内容  
hello world  
i am li  
how are you  
li  
[root@jie1 ~]# cat test  #将用sed操作的文件的内容  
Ethernet  
#BOOTPROTO="dhcp"  
HWADDR="00:0C:29:90:79:78"  
ONBOOT="yes"  
IPADDR=172.16.10.12  
NETMASK=255.255.0.0  
[root@jie1 ~]# sed  -i '/Ethernet/r myfile' test  
      #在匹配Ethernet的行，读进来另一个文件的内容，读进来的文件的内容会插入到匹配Ethernet的行后  
[root@jie1 ~]# cat test  #再次查看用sed命令操作的行  
Ethernet  
hello world  
i am li  
how are you  
li  
#BOOTPROTO="dhcp"  
HWADDR="00:0C:29:90:79:78"  
ONBOOT="yes"  
IPADDR=172.16.10.12  
NETMASK=255.255.0.0  