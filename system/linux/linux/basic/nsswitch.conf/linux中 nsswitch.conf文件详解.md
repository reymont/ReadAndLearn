

* [linux中 nsswitch.conf文件详解 - CSDN博客 ](http://blog.csdn.net/u011150719/article/details/42708469)

# 一、nsswithch.conf：服务搜索顺序 

文件/etc/nsswitch.conf(name service switch configuration，名字服务切换配置)规定通过哪些途径以及按照什么顺序通过这些途径来查找特定类型的信息

Nsswitch.conf中的每一行配置都指明了如何搜索信息，每行配置的格式如下： 
Info: method[[action]] [method[[action]]...] 
    其中，info指定该行所描述的信息的类型，method为用来查找该信息的方法，action是对前面的method返回状态的响应。action要放在方括号里。 

# 二、nsswitch.conf的工作原理 
    当需要提供nsswitch.conf文件所描述的信息的时候，系统将检查含有适当info字段的配置行。它按照从左向右的顺序开始执行配置行中指定的方法。在默认情况下，如果找到期望的信息，系统将停止搜索。如果没有指定action，那么当某个方法未能返回结果时，系统就会尝试下一个动作。有可能搜索结束都没有找到想要的信息。

## 1、信息(Info) 
    Nsswitch.conf文件通常控制着用户(在passwd中)、口令(在shadow中)、主机IP和组信息(在group中)的搜索。下面的列表描述了nsswitch.conf文件控制搜索的大多数信息(Info项)的类型。
automount：
自动挂载（/etc/auto.master和/etc/auto.misc）
bootparams：
无盘引导选项和其他引导选项（参见bootparam的手册页）
ethers：
MAC地址
group：
用户所在组（/etc/group),getgrent()函数使用该文件
hosts：
主机名和主机号（/etc/hosts)，gethostbyname()以及类似的函数使用该文件
networks：
网络名及网络号（/etc/networks)，getnetent()函数使用该文件
passwd：
用户口令（/etc/passwd)，getpwent()函数使用该文件
protocols：
网络协议（/etc/protocols），getprotoent()函数使用该文件
publickey：
NIS+及NFS所使用的secure_rpc的公开密钥
rpc：
远程过程调用名及调用号（/etc/rpc），getrpcbyname()及类似函数使用该文件
services：
网络服务（/etc/services），getservent()函数使用该文件
shadow：
映射口令信息（/etc/shadow），getspnam()函数使用该文件
aiases：
邮件别名，sendmail()函数使用该文件

## 2、方法(method) 
    下面列出了nsswich.conf文件控制搜索信息类型的方法，对于每一种信息类型，都可以指定下面的一种或多种方法：

files：
搜索本地文件，如/etc/passwd和/etc/hosts
nis：
搜索NIS数据库，nis还有一个别名，即yp
dns：
查询DNS（只查询主机）
compat：
passwd、group和shadow文件中的±语法（参见本节后面的相关内容）

## 3、搜索顺序(从左至右) 
    两个或者更多方法所提供的信息可能会重叠。举例来说，files和nis可能都提供同一个用户的口令信息。如果出现信息重叠现象，就需要考虑将哪一种方法作为权威方法（优先考虑），并将该方法放在方法列表中靠左的位置上。 
    默认nsswitch.conf文件列出的方法并没有动作项，并假设没有信息重叠（正常情况）。在这种情况下，搜索顺序无关紧要：当一种方法失败之后，系统就会尝试下一种方法，只是时间上受到一点损失。如果在方法之间设置了动作，或者重叠的项的内容不同，那么搜索顺序就变得重要起来。 

例如下面两行nsswitch.conf文件配置行： 
passwd files nis 
host nis files dns 

    第一行让系统在/etc/passwd文件中搜索口令信息，如果失败的话，就使用NIS来查找信息。如果正在查找的用户同时出现在这两个地方，就会使用本地文件中的信息，因此它就是权威信息。第二行先使用NIS搜索；如果失败的话，就搜索/etc/hosts文件；如果再次失败的话，核对DNS以找出主机信息。 

## 4、动作项([action]) 
    在每个方法后面都可以选择跟一个动作项，用来指定如果由于某种原因该方法成功抑或失败需要做些什么。动作项的格式如下： 
[[!]STATUS =action] 
    其中，开头和末尾的方括号属于格式的一部分，并不是用来指出括号中的内容是可选的。STATUS（按照约定使用大写字母，但本身并不区分大小写）是待测试的状态，action是如果STATUS匹配前面的方法所返回的状态将要执行的动作。开头的感叹号（!）是可选的，其作用是将状态取反。
STATUS：
STATUS的取值如下：
NOTFOUND：方法已经执行，但是并没有找到待搜索的值。 默认的动作是continue。
SUCCESS：方法已经执行，并且已经找到待搜索的值，没有返回错误。默认动作是return。
UNAVAIL：方法失败，原因是永久不可用。举例来说，所需的文件不可访问或者所需的服务器可能停机。默认的动作是continue。
TRYAGAIN：方法失败，原因是临时不可用。举例来说，某个文件被锁定，或者某台服务器超载。默认动作是continue。
action：
action的取值如下：
return：返回到调用例程，带有返回值，或者不带返回值。
continue：继续执行下一个方法。任何返回值都会被下一个方法找到的值覆盖。
示例：
举例来说，下面这行取自nsswitch.conf文件，它的作用是让系统首先使用DNS来搜索给定主机的IP地址。DNS方法后面的动作项是测试该方法所返回的状态是否为“非（!）UNAVAIL”。
hosts    dns [!UNAVAIL=return] files
如果DNS方法没有返回UNAVAIL（!UNAVAIL），也就是说DNS返回SUCCESS、NOTFOUND或者TRYAGAIN，那么系统就会执行与该STATUS相关的动作（return）。其结果就是，只有在DNS服务器不可用的情况下才会使用后面的方法（files）。
如果DNS服务器并不是不可用（两次否定之后就是“可用”），那么搜索返回域名或者报告未找到域名。只有当服务器不可用的时候，搜索才会使用files方法（检查本地的/etc/hosts文件）。

## 5、compat方法：passwd、group和shadow文件中的"±" 
    可以在/etc/passwd、/etc/group和/etc/shadow文件中放入一些特殊的代码，（如果在nsswitch.conf文件中指定compat方法的话）让系统将本地文件和NIS映射表中的项进行合并和修改。 
    在这些文件中，如果在行首出现加号'＋'，就表示添加NIS信息；如果出现减号'－'，就表示删除信息。举例来说，要想使用passwd文件中的这些代码，可以在nsswitch.conf文件中指定passwd: compat。然后系统就会按照顺序搜寻passwd文件，当它遇到以+或者 开头的行时，就会添加或者删除适当的NIS项。 
    虽然可以在passwd文件的末尾放置加号，在nsswitch.conf文件中指定passwd: compat，以搜索本地的passwd文件，然后再搜寻NIS映射表，但是更高效的一种方法是在nsswitch.conf文件中添加passwd: file nis而不修改passwd文件。

转自：http://www.cnblogs.com/cute/archive/2012/05/17/2506342.html