#Elasticsearch JNACLibrary调用

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->


JNACLibrary类有四个方法，分别为：mlockall，geteuid，getrlimit，strerror。

# static native int mlockall(int flags);

系统调用 mlock 家族允许程序在物理内存上锁住它的部分或全部地址空间。这将阻止Linux 将这个内存页调度到交换空间（swap space），即使该程序已有一段时间没有访问这段空间【3】。mlockall() 锁定调用进程所有映射到地址空间的分页。这包括代码、数据、栈片段分页，同时也包括共享库、用户空间内核数据、共享内存以及内存映射的文件。调用成功返回后所有映射的分页都保证在 RAM 中：直到后来的解锁，这些分页都保证一直在 RAM 内【4】。

# static native int geteuid();

geteuid()：返回有效用户的ID。getuid()：返回实际用户的ID【7】。实际用户：表示一开始执行程序的用户，比如用账号iceup登录shell，然后执行程序ls，那么实际用户就是iceup。有效用户：有效用户是指在程序运行时，计算权限的用户。大多数情况下实际用户和有效用户相等，但是在执行拥有SUID权限的程序的时候，这两个用户通常会不一致【5】。总结，有效用户ID（EUID）是你最初执行程序时所用的ID，表示该ID是程序的所有者。真实用户ID（UID）是程序执行过程中采用的ID，该ID表明当前运行位置程序的执行者【6】。

# static native int getrlimit(int resource, Rlimit rlimit);

getrlimit查询进程所受的系统限制。这些系统限制通过一对硬/软限制对来指定。当一个软限制被超过时，进程还可以继续。另一方面，进程不可以超过它的硬限制。软限制值可以被进程设置在位于0和最大硬限制间的任意值。硬限制值不能被任何进程降低，仅仅超级用户可以增加【8】。  

getrlimit和setrlimit都使用下面的数据结构:

    struct rlimit { 
      rlim_t rlim_cur; 
      rlim_t rlim_max; 
    };

rlim_cur 为指定的资源指定当前的系统软限制。rlim_max 将为指定的资源指定当前的系统硬限制。

# static native String strerror(int errno);

当linuc C api函数发生异常时,一般会将errno变量赋一个整数值，不同的值表示不同的含义，可以使用strerror()获取错误的信息【1】。例如errno等于12的话，它就会返回"Cannot allocate memory"【2】。

# 参考：

1.  [linux下错误的捕获：errno和strerror的使用 - 冀博 - CSDN博客](http://blog.csdn.net/tigerjibo/article/details/6819891)
2.  [linux系统编程之错误处理：perror,strerror和errno - mickole - 博客园](http://www.cnblogs.com/mickole/p/3181097.html)
3.  [mlock家族：锁定物理内存 - 涛行无疆的专栏 - CSDN博客](http://blog.csdn.net/fjt19900921/article/details/8074541)
4.  [linux mlockall - Terry 的博客 - CSDN博客](http://blog.csdn.net/u012450329/article/details/52797670)
5.  [linux实际用户和有效用户的区别，附程序示例说明 - 快乐编程](http://www.01happy.com/linux-actual-user-and-effective-user/)
6.  [getuid 和 geteuid 的区别-CSDN论坛](http://bbs.csdn.net/topics/310140359)
7.  [geteuid()和getuid（）的区别 - 行者无疆 - CSDN博客](http://blog.csdn.net/dongzhongshu/article/details/6215054)
8.  [linux资源限制函数getrlimit，setrlimit - Dicky](https://my.oschina.net/qichang/blog/84092)