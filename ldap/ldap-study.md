


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [LDAP总结](#ldap总结)
	* [前言](#前言)
	* [目录定义](#目录定义)
	* [安装](#安装)
		* [1.安装](#1安装)
		* [2.配置](#2配置)
			* [a.配置HOST](#a配置host)
			* [b.创建证书](#b创建证书)
			* [c.生成管理员密码](#c生成管理员密码)
			* [d.配置slapd.conf](#d配置slapdconf)
			* [e.BerkeleyDb配置](#eberkeleydb配置)
			* [f.配置ldap.conf](#f配置ldapconf)
			* [g.开启加密支持](#g开启加密支持)
	* [3.使用slapadd命令添加根节点 未启动前](#3使用slapadd命令添加根节点-未启动前)
	* [4.启动slapd](#4启动slapd)
	* [5.检测](#5检测)
	* [6.phpldapadmin客户端访问](#6phpldapadmin客户端访问)
	* [参考资料](#参考资料)
* [OpenLDAP学习笔记](#openldap学习笔记)
	* [LDAP协议](#ldap协议)
	* [搜索测试](#搜索测试)
	* [了解schema](#了解schema)
	* [向目录数据库中添加数据](#向目录数据库中添加数据)
		* [1．LDIF文本条目格式](#1ldif文本条目格式)
* [openldap基本配置和操作](#openldap基本配置和操作)
	* [一、配置](#一-配置)
		* [1.数据库的基本配置s](#1数据库的基本配置s)
		* [2.ACL  Access Control List](#2acl-access-control-list)
		* [3. sizelimit  num](#3-sizelimit-num)
	* [二、操作](#二-操作)
		* [1. 指定端口启动](#1-指定端口启动)
		* [2.Operation:](#2operation)
* [OpenLdap的安装及基本管理](#openldap的安装及基本管理)
	* [OpenLdap简介](#openldap简介)
	* [LDAP的主要名词解释](#ldap的主要名词解释)
	* [LDAP管理工具Apache Directory Studio](#ldap管理工具apache-directory-studio)
* [OpenLDAP 服务端安装与配置](#openldap-服务端安装与配置)
	* [查询](#查询)
	* [3、为ldap server添加数据](#3-为ldap-server添加数据)
		* [通过`ldapadd`导入数据](#通过ldapadd导入数据)
		* [通过user.ldif和group.ldif增加一个用户和一个组。](#通过userldif和groupldif增加一个用户和一个组)

<!-- /code_chunk_output -->


# LDAP总结

* [LDAP目录服务折腾之后的总结 - huan&ping - 博客园 ](http://www.cnblogs.com/wadeyu/p/ldap-search-summary.html)


## 前言

公司管理员工信息以及组织架构的后台系统要和Active Directory目录服务系统打通，后台系统使用PHP开发，


LDAP协议定义

LDAP(Lightweight Directory Access Protocol)轻量目录访问协议，定义了目录服务实现以及访问规范。

## 目录定义

A directory is a specialized database specifically designed for searching and browsing, 
in additional to supporting basic lookup and update functions.

LDAP协议实现

0. 基于TCP/IP的应用层协议 `默认端口389 加密端口636`
1. 客户端发送命令，服务器端响应
2. 目录主要操作
   2.0 用户验证(bind操作)
     2.1 添加节点
     2.2 更新节点
     2.3 移动节点
     2.4 删除节点
     2.5 节点搜索
3. 节点类型
    3.0 节点属性规范(SCHEMA)
4. 节点
    4.0 目录里的对象
     4.1 属性即是节点的数据
     4.2 目录中通过DN(Distinguished Name)唯一标识(可以认为是路径)
     4.2.0 节点DN = RDN(Relative Distinguished Name) + 父节点的DN
     4.3 目录是TREE结构，节点可以有子节点，也可以有父节点
5. 属性
    5.0 同一个属性可以有多个值
     5.1 包含属性名称，属性类型
6. 节点唯一标识DN说明
    6.0 示例: dn:CN=John Doe,OU=Texas,DC=example,DC=com
     6.1 从右到左 根节点 -> 子节点
     6.2 DC:所在控制域 OU:组织单元 CN:通用名称
7. 目录规范(SCHEMA)
    7.0 目录节点相关规则
     7.1 Attribute Syntaxes
     7.2 Matching Rules
     7.3 Matching Rule Uses
     7.4 Attribute Types
     7.5 Object Classes
     7.6 Name Forms
     7.7 Content Rules
     7.8 Structure Rule

LDAP服务器端的实现

openLDAP，Active Directory(Microsoft)等等，除了实现协议之外的功能，还对它进行了扩展

LDAP应用场景

0.单点登录(用户管理)
1.局域网资源统一管理

## 安装

### 1.安装

    a.yum -y install openldap-servers openldap-clients

### 2.配置
#### a.配置HOST
        [root@vm ldap]# vi /etc/hosts
       127.0.0.1 test.com
#### b.创建证书
```sh
cd /etc/pki/tls/certs
[root@vm certs]# pwd
/etc/pki/tls/certs
[root@vm certs]# rm -rf slapd.pem
[root@vm certs]# make slapd.pem
#执行命令之后 显示如下信息 按照提示填写即可
umask 77 ; \
    PEM1=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
    PEM2=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
    /usr/bin/openssl req -utf8 -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 -set_serial 0 ; \
    cat $PEM1 >  slapd.pem ; \
    echo ""    >> slapd.pem ; \
    cat $PEM2 >> slapd.pem ; \
    rm -f $PEM1 $PEM2
Generating a 2048 bit RSA private key
.....................................+++
.........+++
writing new private key to '/tmp/openssl.IQ8972'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [GB]:CN
State or Province Name (full name) [Berkshire]:GuangDong
Locality Name (eg, city) [Newbury]:ShenZhen
Organization Name (eg, company) [My Company Ltd]:Boyaa
Organizational Unit Name (eg, section) []:OA
Common Name (eg, your name or your server's hostname) []:Test LDAP 
Email Address []:WadeYu@boyaa.com
[root@vm certs]#
```
#### c.生成管理员密码

            root@vm ~]# slappasswd 

            New password: 
           Re-enter new password: 
          {SSHA}2eG1IBeHhSjfgS7pjoAci1bHz5p4AVeS

#### d.配置slapd.conf
        [root@vm certs]# vi /etc/openldap/slapd.conf

       去掉TLS相关注释
       设置数据库配置
#### e.BerkeleyDb配置
        [root@vm certs]# cd /etc/openldap/
        [root@vm openldap]# mv ./DB_CONFIG.example /var/lib/ldap/DB_CONFIG
#### f.配置ldap.conf
        [root@vm openldap]# vi ldap.conf
#### g.开启加密支持
        [root@vm ~]# vim /etc/sysconfig/ldap
        SLAPD_LDAPS=yes

## 3.使用slapadd命令添加根节点 未启动前

```
[root@vm ~]# cd ~
[root@vm ~]# vim root.ldif
dn: dc=test,dc=com
dc: test
objectClass: dcObject
objectClass: organizationalUnit
ou: test.com
[root@vm ~]# slapadd -v -n 1 -l root.ldif
```
## 4.启动slapd
[root@vm ~]# slapd -h "ldap:// ldaps://"
389非加密端口 636加密端口



## 5.检测

```sh
[root@vm ~]# ldapsearch -x -H ldap://localhost
# extended LDIF
#
# LDAPv3
# base <> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#
 
# test.com
dn: dc=test,dc=com
dc: test
objectClass: dcObject
objectClass: organizationalUnit
ou: test.com
 
# search result
search: 2
result: 0 Success
 
# numResponses: 2
# numEntries: 1
 
[root@vm ~]# ldapsearch -x -H ldaps://localhost
# extended LDIF
#
# LDAPv3
# base <> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#
 
# test.com
dn: dc=test,dc=com
dc: test
objectClass: dcObject
objectClass: organizationalUnit
ou: test.com
 
# search result
search: 2
result: 0 Success
 
# numResponses: 2
# numEntries: 1
```

## 6.phpldapadmin客户端访问
a.官网下载源码放入WEB目录下 下载页面:http://phpldapadmin.sourceforge.net/wiki/index.php/Download
    b.安装依赖的扩展gettext ldap这2个扩展
    c.按需配置 源码目录下config/config.php


## 参考资料

[1] LDAPV3协议
http://tools.ietf.org/html/rfc4511
[2] LDAP百度百科
http://baike.baidu.com/view/159263.htm
[3] WIKI LDAP
http://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
[4] LDAP Data Interchange Format
http://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format
[5] OpenLDAP介绍
http://en.wikipedia.org/wiki/OpenLDAP
[6] OpenLDAP管理员文档
[7] Zend LDAP API
http://framework.zend.com/manual/1.11/en/zend.ldap.api.html
[8] BerkeleyDb以及OPENLDAP安装指南
http://www.openldap.org/lists/openldap-technical/201001/msg00046.html
[9] LDAP环境搭建 OpenLDAP和phpLDAPadmin -- yum版
http://www.cnblogs.com/yafei236/p/4141897.html
[10] phpldapadmin开源项目
http://phpldapadmin.sourceforge.net/wiki/index.php/Main_Page

作者：WadeYu 
出处：http://www.cnblogs.com/wadeyu/ 

#  OpenLDAP学习笔记

* [OpenLDAP学习笔记 - 坚强的石头 - ITeye博客 ](http://jianshi-dlw.iteye.com/blog/1557846)
* [图文介绍openLDAP在windows上的安装配置 | micmiu - 软件开发+生活点滴 ](http://www.micmiu.com/enterprise-app/sso/openldap-windows-config/)
* [jldap实现Java对LDAP的基本操作 | micmiu - 软件开发+生活点滴 ](http://www.micmiu.com/opensource/java-ldap-demo/)

## LDAP协议
 
目录是一组具有类似属性、以一定逻辑和层次组合的信息。常见的例子是通讯簿，由以字母顺序排列的名字、地址和电话号码组成。

目录服务是一种在分布式环境中发现目标的方法。目录具有两个主要组成部分：
 
* 第一部分是数据库，数据库是分布式的，且拥有一个描述数据的规划。
* 第二部分则是访问和处理数据的各种协议。
      
目录服务其实也是一种数据库系统，只是这种数据库是`一种树形结构`，而不是通常使用的关系数据库。目录服务与关系数据库之间的主要区别在于：二者都允许对存储数据进行访问，只是`目录主要用于读取，其查询的效率很高`，而关系数据库则是为读写而设计的。

提示：目录服务不适于进行频繁的更新，属于典型的分布式结构。 
      
LDAP是一个目录服务协议，目前存在众多版本的LDAP，而最常见的则是V2和V3两个版本，它们分别于1995年和1997年首次发布。

## 搜索测试

```sh
#注意：-b后面是两个单引号，用来阻止特殊字符被Shell解析。
[root@localhost ~]# ldapsearch -x -b '' -s base '(objectclass=*)'  
# extended LDIF
#
# LDAPv3
# base <> with scope baseObject
# filter: (objectclass=*)
# requesting: ALL
#

#
dn:
objectClass: top
objectClass: OpenLDAProotDSE

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

## 了解schema

对于LDAP目录中保存的信息，可以使用`LDIF（LDAP Interchange Format）`格式来保存。这是一种标准文本文件格式，使用这种格式保存得的LDAP服务器数据库中的数据可方便读取和修改，这也是其他大多数服务配置文件所采取的格式。

LDIF文件常用来向目录导入或更改记录信息，这些信息需要按照LDAP中schema的格式进行组织，并会接受schema的检查，不符合其要求的格式将会出现报错信息。有关LDIF文件的格式和创建将在第4章进行介绍，这里简单介绍一下组织LDAP数据格式的schema文件。

在LDAP中，schema用来指定一个目录中所包含的对象（objects）的类型（objectClass），以及每一个类型（objectClass）中必须提供的属性（Atrribute）和可选的属性。可将schema理解为面向对象程序设计中的类，通过类定义一个具体的对象。LDIF中的数据条目可理解为是一个具体的对象，是通过schema来规划创建的。因此，schema是一个数据模型，用来决定数据按什么方式存储，并定义存储在不同的条目（Entry）下的数据之间的关系。schema需要在主配置文件slapd.conf中指定，以用来决定在目录中可以使用哪些objectClass。

## 向目录数据库中添加数据

初始状态下，LDAP是一个空目录，即没有任何数据。可通过程序代码向目录数据库中添加数据，也可使用OpenLDAP客户端工具`ldapadd`命令来完成添加数据的操作，`该命令可将一个LDIF文件中的条目添加到目录`。因此，需要首先创建一个LDIF文件，然后再进行添加操作。

### 1．LDIF文本条目格式
 
LDIF用文本格式表示目录数据库的信息，以方便用户创建、阅读和修改。在LDIF文件中，一个条目的基本格式如下：

```sh
# 注释
dn: 条目名
属性描述: 值
属性描述: 值
属性描述: 值
... ...
```
 
dn行类似于关系数据库中一条记录的关键字，不能与其他dn重复。一个LDIF文件中可以包含多个条目，每个条目之间用一个空行分隔。

例如，以下内容组成一个条目：

```sh
1: dn: dc=dlw, dc=com
2: objectclass: top
3: objectclass: dcobject
4: objectclass: organization
5: dc: dlw
6: o: dlw,Inc.
```

在以上文本中，各行含义如下：

* 第1行的dn定义该条目的标识。
* 第2～4行定义该条目的objectcCass，可以定义多个属性，如上面代码中定义了3个objectClass。条目的属性根据objectClass的不同而不同，有的objectClass有必须设置的属性。在2～4行的3个objectClass中，top没有必须定义的属性，dcobject必须定义属性dc，用来表示一个域名的部分，而organization必须定义属性o，用来表示一个组织的名称。
* 根据objectClass的要求，第5、6行分别定义属性dc和属性o的值。


# openldap基本配置和操作

* [openldap基本配置和操作 - 人生如棋 - CSDN博客 ](http://blog.csdn.net/zhangyang0402/article/details/4897546)


## 一、配置

配置文件一般在/etc/openldap/slapd.conf 或/usr/local/etc/openldap/slapd.conf
 
### 1.数据库的基本配置s
database        bdb
suffix          "dc=zy,dc=net"
rootdn          "cn=Manager,dc=zy,dc=net"
rootpw          123456
 
 
### 2.ACL  Access Control List
禁止匿名访问
access to *
        by self write
        by users read
        by anonymous auth
 
### 3. sizelimit  num
指定从一个搜索操作中返回的最大entry个数
默认值是500，unlimited表示没有限制
sizelimit  100  搜索返回的entry个数最大是100
sizelimit  unlimited 不限制搜索返回的entry的个数的最大值
 
## 二、操作
### 1. 指定端口启动

```sh
启动: slapd
指定端口启动: slapd -h "ldap:///  ldaps:///"       默认从389,636监听
修改默认的389端口：
# ps -ef |grep slapd
root      7322     1  0 11:04 ?        00:00:00 slapd -h ldap:///
root      7325  6997  0 11:04 pts/2    00:00:00 grep slapd
# kill 7322
# slapd -h "ldap://:2009"
# ps -ef |grep slapd
root      7338     1  0 11:06 ?        00:00:00 slapd -h ldap://:2009
root      7341  6997  0 11:06 pts/2    00:00:00 grep slapd
[root@localhost openldap]# netstat -ant|grep 389
[root@localhost openldap]# netstat -ant|grep 2009
tcp        0      0 0.0.0.0:2009                0.0.0.0:*                   LISTEN
tcp        0      0 :::2009                     :::*                        LISTEN
 
使用默认389端口
# slapd -h "ldap:///"
slapd  -h "ldap:/// ldaps:///"         //启用389端口，和SSL的636端口
slapd  -h "ldap://:2009 ldaps://:2010" // ldap使用2009监听，ldaps使用2010监听
```
 
### 2.Operation:
 
目录：/usr/bin
常用参数
```sh
-x     Use simple authentication instead of SASL.
-f file  Read a series of lines from file
-D binddn
 Use the Distinguished Name binddn to bind to the LDAP directory.
-W     Prompt for simple authentication.  
-w passwd  Use passwd as the password for simple authentication.
-h ldaphost
Specify an alternate host on which the ldap server  is  running.
-p ldapport
Specify  an  alternate TCP port where the ldap server is listening.  
-b searchbase
Use searchbase as the starting point for the search  
-h ldaphost
Specify an alternate host on which the ldap server  is  running.
```

(1) ldapadd
> #ldapadd -x -D "cn=Manager,dc=zy,dc=net" -w 123456  -f  1.ldif

(2)ldapdelete
> #ldapdelete "ou=qa,dc=zy,dc=net" -x -D "cn=Manager,dc=zy,dc=net" -w 123456

(3)ldapsearch
>ldapsearch -x -h 10.226.45.197 -b "ou=qa,dc=zy,dc=net" -D "cn=test1,ou=qa,dc=zy,dc=net" -w testpass '(objectclass=*)'
在主机10.226.45.197上，查询 base DN 为"ou=qa,dc=zy,dc=net" ,绑定为cn=test1,ou=qa,dc=zy,dc=net 密码为testpass ，search filter为了（objecttclass=*）的entry

# OpenLdap的安装及基本管理

* [OpenLdap的安装及基本管理 | IT人生录 ](http://www.huqiwen.com/2014/04/17/openldap-install-manager/)

## OpenLdap简介
OpenLDAP是轻型目录访问协议（Lightweight Directory Access Protocol，LDAP）的自由和开源的实现，在其OpenLDAP许可证下发行，并已经被包含在众多流行的Linux发行版中。
它主要包括下述4个部分：
1. slapd - 独立LDAP守护服务
2. slurpd - 独立的LDAP更新复制守护服务
3. 实现LDAP协议的库
4. 工具软件和示例客户端

可以使用默认配置,一直点击Next，最后一步使用默认的BDB数据库即可。安装完成点击Close退出.
注：Database backend（后端数据库）
* BDB--Berkeley DB是历史悠久的嵌入式数据库系统，主要应用在UNIX/LINUX操作系统上，其设计思想是简单、小巧、可靠、高性能。
* MDB-- Memory Mapped Database。
* LDAP—使用代理LDAP服务。
* LDIF—使用LDFI文件存储。
* SQL SERVER—微软SQL SERVER数据库。

## LDAP的主要名词解释

* dc：（Domain Component）域
* ObjectClass：对象类（不同的对象类存在某些不同的属性，根据自己需要选择对象类）
* dn：(Distinguished Name)节点绝对路径,例如:uid=admin,ou=users,dc=eruipan,dc=com
* o:(Organizational)组织
* ou：(Organizational Unit)组织单位
* cn：(Common Name)通用名（继承自person对象的对象类必须有值的属性，否则无法创建）
* sn：（surname）全名（继承自person对象的对象类必须有值的属性，否则无法创建）

其他需要用到的属性
* mail：电子邮件
* userpassword：用户密码
* uid：唯一标识（如果使用uid验证）

## LDAP管理工具Apache Directory Studio

LDAP的管理工具有许多，这里介绍一个，Apache Directory Studio 是一个 LDAP 的工具平台，用来连接到任何 LDAP 服务器并进行管理和开发工作。拥有LDAP浏览器、LDIF编辑器、嵌入式 ApacheDS、ACI编辑器等。

# OpenLDAP 服务端安装与配置

* [OpenLDAP 服务端安装与配置 - 运维点滴记录 - 51CTO技术博客 ](http://wzlinux.blog.51cto.com/8021085/1835595)

## 查询

查询LDAP的目录条目，首先我们介绍一下ldapsearch命令，具体可以使用man帮助手册查看。
* -b：指定查找的节点
* -D：指定查找的DN
* -x：使用简单认证
* -W：查询是输入密码，或者使用-w password
* -h：OpenLDAP的主机地址，可以使用IP或者域名
* -H：使用LDAP服务器的URI地址进行操作

```sh
[root@mldap ~]# ldapsearch -x -D "cn=admin,dc=wzlinux,dc=com" -H ldap://192.168.2.10 -W
Enter LDAP Password:                    #就是我们在slapd.conf加密的密码
ldap_bind: Invalid credentials (49)
```

```sh
[root@mldap ~]# ldapsearch -x -D "cn=admin,dc=wzlinux,dc=com" -h 192.168.2.10 -W
Enter LDAP Password: 
# extended LDIF
#
# LDAPv3
# base <> (default) with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#
 
# search result
search: 2
result: 32 No such object
 
# numResponses: 1
```

## 3、为ldap server添加数据
    为ldap添加用户数据，有四种方法，分别如下，我们选择第四种方法进行试验。
1）可以直接修改slapd.d目录下面的数据文件，好处是不用重启服务，直接生效；
2）安装开源工具migrationtools来生成ldfi文件，并通过ldapadd来添加；
3）安装ldap 客户端，这种方法最为简单；
4）直接编辑ldfi文件，然后通过ldapadd添加。
    首先我们手动编辑base.ldif文件，直接复制好像会因为格式有问题。每个条目之间有个空格，直接复制过去会有点问题，需要你把每个条目之间空行的第一个空位删除一下。

```sh
[root@mldap ~]# vim base.ldif 
dn: dc=wzlinux,dc=com
objectClass: organization
objectClass: dcObject
dc: wzlinux
o: wzlinux
 
dn: ou=people,dc=wzlinux,dc=com
objectClass: top
objectClass: organizationalUnit
ou: people
 
dn: ou=group,dc=wzlinux,dc=com
objectClass: top
objectClass: organizationalUnit
ou: group
```

### 通过`ldapadd`导入数据

通过`ldapadd`导入数据，通过man可以看到，他的大部分参数和ldapsearch差不多，我们这里就直接使用了。

```sh
[root@mldap ~]# ldapadd -x -D "cn=admin,dc=wzlinux,dc=com" -w 123456a -h 192.168.2.10 -f base.ldif 
 
adding new entry "dc=wzlinux,dc=com"
 
adding new entry "ou=people,dc=wzlinux,dc=com"
 
adding new entry "ou=group,dc=wzlinux,dc=com"
```

通过反馈的结果，我们已经看到添加成功了，我们在另外一台安装了客户端的机器上面进行查询一下，可以看到我们查询到的结果和我们的base.ldif是一样的。
```sh
[root@test01 ~]# ldapsearch -x -D "cn=admin,dc=wzlinux,dc=com" -w 123456a -h 192.168.2.10 -b "dc=wzlinux,dc=com" -LLL
dn: dc=wzlinux,dc=com
objectClass: organization
objectClass: dcObject
dc: wzlinux
o: wzlinux
 
dn: ou=people,dc=wzlinux,dc=com
objectClass: top
objectClass: organizationalUnit
ou: people
 
dn: ou=group,dc=wzlinux,dc=com
objectClass: top
objectClass: organizationalUnit
ou: group
```
### 通过user.ldif和group.ldif增加一个用户和一个组。
```
[root@mldap ~]# cat user.ldif group.ldif 
dn: uid=test1,ou=people,dc=wzlinux,dc=com
objectClass: posixAccount
objectClass: top
objectClass: inetOrgPerson
objectClass: shadowAccount
gidNumber: 0
givenName: test1
sn: test1
uid: test1
homeDirectory: /home/test1
loginShell: /bin/bash
shadowFlag: 0
shadowMin: 0
shadowMax: 99999
shadowWarning: 0
shadowInactive: 99999
shadowLastChange: 12011
shadowExpire: 99999
cn: test1
uidNumber: 24422
userPassword:: e1NIQX10RVNzQm1FL3lOWTNsYjZhMEw2dlZRRVpOcXc9
 
dn: cn=DBA,ou=group,dc=wzlinux,dc=com
objectClass: posixGroup
objectClass: top
cn: DBA
memberUid: test1
gidNumber: 10673
```

 添加用户和组。
```
[root@mldap ~]# ldapadd -x -D "cn=admin,dc=wzlinux,dc=com" -w 123456a -h 192.168.2.10 -f group.ldif 
adding new entry "cn=DBA,ou=group,dc=wzlinux,dc=com"
 
[root@mldap ~]# ldapadd -x -D "cn=admin,dc=wzlinux,dc=com" -w 123456a -h 192.168.2.10 -f user.ldif 
adding new entry "uid=test1,ou=people,dc=wzlinux,dc=com"
```
然后通过下面的命令查看自己是否添加成功。
```
ldapsearch -x -D "cn=admin,dc=wzlinux,dc=com" -w 123456a -h 192.168.2.10 -b "dc=wzlinux,dc=com" -LLL
```

可能每次查询都写这么多，或许感觉比较麻烦，我们可以在客户端的配置文件里面添加两行数据，客户端的配置文件是/etc/openldap/ldap.conf。

```sh
BASE   dc=wzlinux,dc=com
URI    ldap://ldap.wzlinux.com     #提前设置好hosts文件
```