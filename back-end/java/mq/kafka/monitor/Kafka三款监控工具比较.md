

Kafka三款监控工具比较 - zzm - ITeye博客 
http://m635674608.iteye.com/blog/2287800

在之前的博客中，介绍了Kafka Web Console这 个监控工具，在生产环境中使用，运行一段时间后，发现该工具会和Kafka生产者、消费者、ZooKeeper建立大量连接，从而导致网络阻塞。并且这个 Bug也在其他使用者中出现过，看来使用开源工具要慎重！该Bug暂未得到修复，不得已，只能研究下其他同类的Kafka监控软件。
通过研究，发现主流的三种kafka监控程序分别为：
Kafka Web Conslole
Kafka Manager
KafkaOffsetMonitor
现在依次介绍以上三种工具：
Kafka Web Conslole
使用Kafka Web Console，可以监控：
Brokers列表
Kafka 集群中 Topic列表，及对应的Partition、LogSiz e等信息
点击Topic，可以浏览对应的Consumer Groups、Offset、Lag等信息
生产和消费流量图、消息预览…
kafka-web-console
程序运行后，会定时去读取kafka集群分区的日志长度，读取完毕后，连接没有正常释放，一段时间后产生大量的socket连接，导致网络堵塞。
Kafka Manager
雅虎开源的Kafka集群管理工具:
管理几个不同的集群
监控集群的状态(topics, brokers, 副本分布, 分区分布)
产生分区分配(Generate partition assignments)基于集群的当前状态
重新分配分区
kafka-manager
KafkaOffsetMonitor
KafkaOffsetMonitor可以实时监控：
Kafka集群状态
Topic、Consumer Group列表
图形化展示topic和consumer之间的关系
图形化展示consumer的Offset、Lag等信息
KafkaOffsetMonitor
总结
通过使用，个人总结以上三种监控程序的优缺点：
Kafka Web Console：监控功能较为全面，可以预览消息，监控Offset、Lag等信息，但存在bug，不建议在生产环境中使用。
Kafka Manager：偏向Kafka集群管理，若操作不当，容易导致集群出现故障。对Kafka实时生产和消费消息是通过JMX实现的。没有记录Offset、Lag等信息。
KafkaOffsetMonitor：程序一个jar包的形式运行，部署较为方便。只有监控功能，使用起来也较为安全。
若只需要监控功能，推荐使用KafkaOffsetMonito，若偏重Kafka集群管理，推荐使用Kafka Manager。
因为都是开源程序，稳定性欠缺。故需先了解清楚目前已存在哪些Bug，多测试一下，避免出现类似于Kafka Web Console的问题。
原创文章，转载请注明：
转载自蓝色天堂博客，本文链接地址：http://hadoop1989.com/2015/09/22/Kafka-Monitor_Compare/