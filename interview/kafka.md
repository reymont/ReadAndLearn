

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