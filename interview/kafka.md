

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Kafka 对比 ActiveMQ](#kafka-对比-activemq)
	* [kafka同步怎么解决乱序问题](#kafka同步怎么解决乱序问题)

<!-- /code_chunk_output -->


# Kafka 对比 ActiveMQ

* [Kafka 对比 ActiveMQ - liujiayu2的专栏 - CSDN博客 ](http://blog.csdn.net/liujiayu2/article/details/51152366)

* Kafka
  * 日志收集
  * 流式数据处理
  * 在线和离线消息分发
* 概念
  * 消息按Topic组织
  * 保存消息的服务器称为Broker
  * 消费者可以订阅一个或多个Topic
  * 为负载均衡，一个Topic消息可以划分多个分区Partition
* 组件
  * Kafka集群需要zookeeper支持
  * 同时启动zookeeper server和kafka server
* 消息处理
  * 消费者需要自己保留一个offset 
  * 从kafka获取消息时，只拉取当前offset以后的消息
* 缺点
  * 重复消息，保证消息至少送达一次，但一条消息有可能会被送达多次
  * 消息乱序，一个Topic有多个Partition，Partition之间的消息送达不保证有序
  * 复杂性，Topic需要人工来创建

## kafka同步怎么解决乱序问题

* [kafka同步怎么解决乱序问题？ - 知乎 ](https://www.zhihu.com/question/57761908)

* 三个方面的含义
  * 消息全局顺序是乱的。Kafka不保证全局的消息顺序
  * 消息在单个分区内是乱序的。启动reties或调整max.in.flight.requests.per.connection  = 1
  * 某条消息在源集群中属于分区A，在目标集群中属于分区B
    * 消息必须有key
    * 单独创建一个自定义的分区策略

# 消息系统Kafka介绍

* [董的博客 » 消息系统Kafka介绍 ](http://dongxicheng.org/search-engine/kafka/)

* 概述
  * 处理活跃的流式数据
  * 离线和在线处理日志
  * Kafka的作用类似于缓存，即活跃的数据和离线处理系统之间的缓存
* 关键技术
  * zero-copy
    * 每次请求把一组message发给相应的consumer
    * sendfile系统调用

【1】Kafka主页：http://sna-projects.com/kafka/design.php
【2】Zero-copy原理：https://www.ibm.com/developerworks/linux/library/j-zerocopy/
【3】Kafka与Hadoop：http://sna-projects.com/sna/media/kafka_hadoop.pdf

# 浅析Linux中的零拷贝技术

* [浅析Linux中的零拷贝技术 - 简书 ](http://www.jianshu.com/p/fad3339e3448)

* 引文
  * 文件下载
    * 将服务端主机磁盘中的文件不做修改的从已连接的socket发出去
    * 循环的从磁盘读入文件内容到缓冲区，再将缓冲区的内容发送到socket
  * 应用访问某块数据
    * 文件内容是否在内存缓冲区
      * 已缓存，将内核缓冲区的内容拷贝到指定的用户空间缓冲区
      * 未缓存，先将数据拷贝到内核缓冲区（DMA），再将内核缓冲区上的内容拷贝到用户缓冲区
    * write系统调用把用户缓冲区的内容拷贝到Socket缓冲区
    * socket把内核缓冲区的内容发送到网卡上
  * 发生了四次数据拷贝
    * 使用DMA处理硬件的通信，CPU仍然需要处理两次数据拷贝
  * DMA
    * Direct Memory Access，直接内存访问
    * 一种不经过CPU而直接从内存存取数据的数据交换模式
    * CPU只须向DMA控制器下达指令，让DMA控制器来处理数据的传送，数据传送完毕再把信息反馈给CPU
* 零拷贝
  * 避免CPU将数据从一块存储到另一块存储
  * 减少数据在内核空间和用户空间来回拷贝
* mmap让数据传输不需要经过user space
  * mmap()将内核缓冲区与应用程序共享
  * write()直接将内核缓冲区的内容拷贝到socket缓冲区
  * 陷阱
    * mmap的一个文件被另一个进程截断时，
    * write系统调用会因为访问非法地址而被SIGBUS信号终止
  * 解决
    * 为SIGBUS信号建立信号处理程序
      * 信号处理程序简单的返回
      * 没有解决问题的实质核心
    * 使用文件租借锁
      * 在文件描述符上使用租借锁
* sendfile
  * 数据只能从文件传递到套接字上，反之不行
  * 数据传送始终只发生在kernel space
  * 其它进程截断文件，sendfile仅仅返回被中断之前已经传输的字节数
  * 文件加锁与mmap()行为一致
  * 一次拷贝
    * 页缓存到socket缓存的拷贝
  * 借助硬件的帮助
    * 缓冲区描述符传到socket缓冲区
    * 数据长度传过去
    * DMA控制器直接将页缓存中的数据打包发送到网络中
  * 总结
    * sendfile系统调动利用DMA引擎将文件内容拷贝到内核缓冲区去
    * 将带有文件位置和长度信息的缓冲区描述符添加socket缓冲区
    * DMA引擎会将内存缓冲区的数据拷贝到协议引擎中去
* splice
  * 用于在两个文件描述符中移动数据
  * 不需要数据在内核空间和用户空间来回拷贝
  * 两个文件描述符必须有一方是管道设备
  * 利用管道缓冲区机制
* Linux I/O中O_DIRECT
* fbufs
* 写时复制copy on write
  * 多个程序同时访问同一块数据
  * 当程序需要对数据内容进行修改时，拷贝数据内容，称为该程序的私有数据