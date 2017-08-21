

* [基于 Distcc 的android分布式编译环境的搭建 - 囧小平-云栖隐者 - CSDN博客 ](http://blog.csdn.net/zimingjushi/article/details/23430023)

关于Ditscc分布式编译环境的搭建，网上也有不少文章，但是基本上都过时了。所以看了很多文章，走了不少弯路，最后总算梳理清楚了一条正确的环境搭建的步骤，而且可以实现zeroconf。本文不涉及负载均衡的实现。

本文所述环境的搭建是基于Ubuntu 12.04 64bit，Android版本是4.1(其他版本估计也一样)。android编译环境的搭建就不再赘述了，请参考尽量参考官方文档https://source.android.com/source/initializing.html

# 1.Distcc简介
Distcc 是一个将 C、C++等程序的编译任务分发到网络中多个主机的程序。 Distcc的工作原理为: GCC 编译C/C++构建一个execualble分为四个阶段: 预处理：.c 到.i，由cc完成 汇编：.i到.s ，由cc完成 编译：.s到.o，由as完成 链接：.o 到可执行文件，由collect2完成 其中第三阶段是效率瓶颈。distcc是一个编译器驱动器。它在”gcc -c”阶段把预处理输出分发到指定的服务器阵列并收集结果。GNU Make的”-j”并行编译可以利用distcc来加速编译。distcc本身事实上并不参与任何编译过程,而只是一个编译器的前端。为编译器加入分布式特性,并参与部分管理和简单的负载均衡的功能。distcc在本地完成预处理(使用gcc -E，完成头文件、宏的展开)，把结果发给集群中的工作主机，由工作主机完成编译（使用gcc -c）并发回编译结果，最后在本地做链接。  distcc分布式编译程序可以将包含两个部分： distcc:在客户端分发编译任务到编译主机 distccd:编译主机启动distccd守护进程接收编译任务，并返回编译结果。