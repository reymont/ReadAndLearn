
# Kafka Zero-Copy 使用分析

* [Kafka Zero-Copy 使用分析 - allwefantasy的专栏 - CSDN博客 ](http://blog.csdn.net/allwefantasy/article/details/50663533)

* 前言
  * NIO
  * Zero Copy
  * 磁盘顺序读写
  * Queue数据结构的机制使用
* Kafka在什么场景下使用该技术
  * 消息消费的时候
  * transferTo()方法
    * channel到channel的数据传输
    * 直接在内核态进行数据传输，避免拷贝数据导致的内核态和用户态的多次切换
* Kafka 如何使用Zero-Copy流程分析
* 数据的生成
  * KafkaApis
    * handle方法是所有处理的入口
    * ApiKeys.FETCH消费者获取数据
    * handleFetchRequest
    * ReplicaManager包含所有主题的所有partition消息
    * readFromLocalLog获取本地日志信息数据
    * log.read中的Log对象是一个Topic的Partition
* 数据的发送
  * SocketeServer
    * 负责和所有的消费者打交道，建立连接的中枢
  * processNewResponses
    * 注册新的连接后，处理新的响应
    * 通过send方法把FetchResponseSend注册到selector上