
# Kafka剖析（一）：Kafka背景及架构介绍


* [Kafka剖析（一）：Kafka背景及架构介绍 ](http://www.infoq.com/cn/articles/kafka-analysis-part-1)

## Kafka简介

* Kafka是一种分布式，基于发布/订阅的消息系统。设计目标
  * 以时间复杂度为O(1)的方式提供`消息持久化`能力
  * 高吞吐率：单机100k/秒
  * 消息分区，分布式消费
  * 同时支持离线数据处理和实时数据处理
  * 支持在线水平扩展

## 架构

* Terminology（术语）
  * Broker：包含一个或多个服务器broker
  * Topic（主题）：消息的类别
  * Partition：每个Topic包含一个或多个Partition
  * Producer：发布消息到Kafka broker。使用push模式将消息发布到broker
  * Consumer：从Kafka broker读取消息。使用pull模式从broker订阅消息并消费消息
  * 

* Topic & Partition
  * 物理上Topic分成一个或多个Partition
  * 每个Partion在物理上对应一个文件夹，该文件夹下存储这个Partition的所有消息和索引文件

  Kafka集群会保留所有消费消息


# kafka入门：简介、使用场景、设计原理、主要配置及集群搭建（转）

* [kafka入门：简介、使用场景、设计原理、主要配置及集群搭建（转） - 李克华 - 博客园 ](http://www.cnblogs.com/likehua/p/3999538.html)


# kafka学习笔记：知识点整理

* [kafka学习笔记：知识点整理 - cyfonly - 博客园 ](http://www.cnblogs.com/cyfonly/p/5954614.html)

