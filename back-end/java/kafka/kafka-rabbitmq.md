
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [RabbitMQ和kafka从几个角度简单的对比](#rabbitmq和kafka从几个角度简单的对比)
	* [1)在架构模型方面，](#1在架构模型方面)
	* [2)在吞吐量，](#2在吞吐量)
	* [3)在可用性方面，](#3在可用性方面)
	* [4)在集群负载均衡方面，](#4在集群负载均衡方面)
* [RabbitMQ, ZeroMQ, Kafka 是一个层级的东西吗](#rabbitmq-zeromq-kafka-是一个层级的东西吗)
	* [Kafka是可靠的分布式日志存储服务](#kafka是可靠的分布式日志存储服务)
	* [kafka特征](#kafka特征)
	* [关于流计算：](#关于流计算)

<!-- /code_chunk_output -->

---


# RabbitMQ和kafka从几个角度简单的对比


* [RabbitMQ和kafka从几个角度简单的对比--转 - 一天不进步，就是退步 - 博客园 ](http://www.cnblogs.com/davidwang456/p/4076097.html)

业界对于消息的传递有多种方案和产品，本文就比较有代表性的两个MQ(rabbitMQ,kafka)进行阐述和做简单的对比，

在应用场景方面，

RabbitMQ,遵循AMQP协议，由内在高并发的erlanng语言开发，用在实时的对可靠性要求比较高的消息传递上。

kafka是Linkedin于2010年12月份开源的消息发布订阅系统,它主要用于处理活跃的流式数据,大数据量的数据处理上。

## 1)在架构模型方面，

RabbitMQ遵循AMQP协议，RabbitMQ的broker由Exchange,Binding,queue组成，其中exchange和binding组成了消息的路由键；客户端Producer通过连接channel和server进行通信，Consumer从queue获取消息进行消费（长连接，queue有消息会推送到consumer端，consumer循环从输入流读取数据）。rabbitMQ以broker为中心；有消息的确认机制。

kafka遵从一般的MQ结构，producer，broker，consumer，以consumer为中心，消息的消费信息保存的客户端consumer上，consumer根据消费的点，从broker上批量pull数据；无消息确认机制。

## 2)在吞吐量，

kafka具有高的吞吐量，内部采用消息的批量处理，zero-copy机制，数据的存储和获取是本地磁盘顺序批量操作，具有O(1)的复杂度，消息处理的效率很高。

rabbitMQ在吞吐量方面稍逊于kafka，他们的出发点不一样，rabbitMQ支持对消息的可靠的传递，支持事务，不支持批量的操作；基于存储的可靠性的要求存储可以采用内存或者硬盘。

## 3)在可用性方面，

rabbitMQ支持miror的queue，主queue失效，miror queue接管。

kafka的broker支持主备模式。

## 4)在集群负载均衡方面，

kafka采用zookeeper对集群中的broker、consumer进行管理，可以注册topic到zookeeper上；通过zookeeper的协调机制，producer保存对应topic的broker信息，可以随机或者轮询发送到broker上；并且producer可以基于语义指定分片，消息发送到broker的某分片上。

rabbitMQ的负载均衡需要单独的loadbalancer进行支持。

原文：http://wbj0110.iteye.com/blog/1974988

收集的rabbitmq资料如下：

http://jzhihui.iteye.com/category/195005

http://lynnkong.iteye.com/blog/1699684

http://blog.csdn.net/anzhsoft/article/details/19607841

http://ybbct.iteye.com/blog/1562326


# RabbitMQ, ZeroMQ, Kafka 是一个层级的东西吗

* [RabbitMQ, ZeroMQ, Kafka 是一个层级的东西吗， 相互之间有哪些优缺点？ - 知乎 ](https://www.zhihu.com/question/22480085)

RabbitMQ是一个AMQP实现，传统的messaging queue系统实现，基于Erlang。老牌MQ产品了。AMQP协议更多用在企业系统内，对**数据一致性、稳定性和可靠性要求很高**的场景，对性能和吞吐量还在其次。

Kafka是linkedin开源的MQ系统，主要特点是基于Pull的模式来处理消息消费，追求高吞吐量，一开始的目的就是用于日志收集和传输，0.8开始支持复制，不支持事务，适合产生大量数据的互联网服务的数据收集业务。

ZeroMQ只是一个网络编程的Pattern库，将常见的网络请求形式（分组管理，链接管理，发布订阅等）模式化、组件化，简而言之socket之上、MQ之下。对于MQ来说，网络传输只是它的一部分，更多需要处理的是消息存储、路由、Broker服务发现和查找、事务、消费模式（ack、重投等）、集群服务等。


## Kafka是可靠的分布式日志存储服务

根本不是一个级别的东西。

>Kafka是可靠的分布式日志存储服务。

用简单的话来说，你可以把Kafka当作可顺序写入的一大卷磁带， 可以随时倒带，快进到某个时间点重放。

![](https://pic4.zhimg.com/v2-469ea8401e86acd04e9fbef8d5624c4f_r.jpg)

先说下日志的定义：日志是数据库的核心，是对数据库的所有变更的严格有序记录，“表”是变更的结果。日志的其他名字有： Changelog, Write Ahead Log, Commit Log, Redo Log, Journaling.

## kafka特征

Kafka的特征如下：

* **高写入速度**：Kafka能以超过1Gbps NIC的速度写这盘磁带（实际可以到SATA 3速度，参考Benchmarking Apache Kafka: 2 Million Writes Per Second (On Three Cheap Machines))，充分利用了磁盘的物理特性，即，**随机写入慢（磁头冲停），顺序写入快（磁头悬浮）**。
* **高可靠性**： 通过**zookeeper**做分布式一致性，同步到任意多块磁盘上，故障自动切换选主，自愈。
* **高容量**：通过横向扩展，LinkedIn每日通过Kafka存储的新增数据高达175TB，8000亿条消息，可无限扩容，类似把两条磁带粘到一起。

传统业务数据库的根本缺陷在于：

* 1.  太慢，读写太昂贵，无法避免的随机寻址。（磁盘最快5ms寻址，固态又太昂贵。）
* 2.  根本无法适应持续产生的数据流，越用越慢。（索引效率问题）
* 3.  无法水平scale。（多半是读写分离，一主多备。另: NewSQL通过一致性算法，有多主。）

针对这些问题，Kafka提出了一种方法: **“log-centric approach（以日志为中心的方法）。”**将传统数据库分为两个独立的系统，即**日志系统和索引系统**。

> **“持久化和索引分开，日志尽可能快的落地，索引按照自己的速度追赶。”**

在数据可靠性在得到Kafka这种快速的，类似磁带顺序记录方式保障的大前提下。数据的呈现，使用方式变得非常灵活，可以根据需要将数据流同时送入搜索系统，RDBMS系统，数据仓库系统， 图数据库系统，日志分析等这些各种不同的数据库系统。这些不同的系统只不过是一种对**Kafka磁带数据的一种诠释，一个侧面，一个索引，一个快照**。数据丢了，没关系，重放一遍磁带即可，更多的时候，对这些各式数据库系统的维护只是需要定期做一个快照，并拷贝到一个安全的对象存储(如S3) 而已。  一句话：**“日志都是相同的日志，索引各有各的不同。”**

## 关于流计算：

在以流为基本抽象的存储模型下，数据流和数据流之间，可以多流混合处理，或者流和状态，状态和状态的JOIN处理，这就是Kafka Stream提供的功能。 一个简单的例子是，在用户触发了某个事件后，和用户表混合处理，产生数据增补（Augment)，再进入数据仓库进行相关性分析，一些简单的窗口统计和实时分析也很容易就能满足，比如 在收到用户登录消息的时候，在线人数+1， 离线的时候-1，反应出当前系统的在线用户总数。这方面可以参考PipelineDB https://www.pipelinedb.com/Kafka会让你重新思考系统的构建方式，使以前不可能的事变为可能，是一个系统中最重要的最核心的部分，不夸张的说，系统设计都需要围绕Kafka做。强烈推荐阅读：oldratlee/translations