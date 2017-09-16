

# 第2章 大流量限流/消峰案例

* 大流量和高并发的问题
  * 连接资源耗尽
  * 分布式缓存容器撑爆
  * 数据库吞吐量降低
* 办法
  * 扩容
  * 动静分离
  * 缓存
  * 服务降级
  * 限流

## 2.1 分布式系统为什么需要进行流量管制

* 限流
  * 流量管制让系统的负载处于一个比较均衡的水位
* 办法
  * CDN：静态数据缓存在CDN上
  * 读服务：读请求尽量在缓存命中
  * 写服务：交易系统进行限流处理，避免给数据库带来较大的负载压力
  * 数据库：读写分离

## 2.2 限流的具体方案

### 2.2.1 常见的限流算法

* 池化资源技术
  * 数据库连接池、线程池、对象池
  * 池化资源技术通过计数器算法来控制全局的总并发数
* 令牌桶算法（Token Bucket）
  * 限制流量的平均流量的**平均流入速率**，并允许出现突发流量
  * 每秒r个令牌放入桶
  * 桶的容量固定不变
  * n个字节的请求消耗n个令牌后，再发送数据包
  * 可用令牌小于n，该数据包将被抛弃或缓存（限流）
* 漏桶算法（Leaky Bucket）
  * 限制流量流出速率，流出速率固定不变，不允许出现突发流量
  * 匀速流入
  * 桶满则弃（超过桶容量，新请求执行限流）
  * 匀速流出
  
### 2.2.2 使用Google的Guava实现平均速率限流

* Guava
  * 封装了集合框架和Cache等特性
  * 本地缓存框架EhCache或Guava Cache
  * Guava限流
* RateLimiter
  * Guava中RateLimiter提供令牌桶算法的实现
  * tryAcquire可以模拟直接等待或短暂等待的情况

### 2.2.3 使用Nginx实现接入层限流

* Tengine
  * limit_zone：定义每个IP的session空间大小
  * limit_req_zone：定义每个IP每秒允许发起的请求数
  * limit_conn：定义每个IP能够发起的并连接数
  * limit_req：缓存还没来得及处理的请求

### 2.2.4 使用计数器算法实现商品抢购限流

* 抢购限流
  * 指定的SKU在单位时间内允许被抢购的次数
  * 超过阈值，则拒绝新的请求，或抢购失败实施排队

## 2.3 基于时间分片的消峰方案

* 削峰
  * 对峰值流量进行分散处理，避免在同一时间段内产生较大的用户流量
  * 活动分时段进行实现削峰
  * 通过答题验证实现削峰

## 2.4 异步调用需求

Java7中Fork/Join框架

### 2.4.1 使用MQ实现系统之间的解耦

* 解耦
  * 消息传递实现异步调用
  * 业务子系统之间可用通过RPC请求实现服务调用
  * 依赖不是必须的，可以用消息传递替代RPC调用

### 2.4.2 使用Apache开源的ActiveMQ实现异步调用

* ActiveMQ
  * JMS Provider消息路由和消息传递
  * Provider负责向消息队列写入消息
  * Consumer负责订阅消息
* 消息模型
  * Point-to-Point（P2P，点对点）
  * P2P：PULL模式，由消费者主动从消息队列中获取消息
  * Publish/Subscribe（pub/sub，发布/订阅）
  * pub/sub：PUSH模式，对于订阅目标Topic的所有消费者广播消息
* 配置
  * 控制台：http://host:8161/admin
  * admin/admin，在/conf/jetty-realm.properties修改默认密码
* 实例
  * 创建ConnectionFactory，获取和启动连接
  * 会话中创建事务Session
  * createQueue设置Point-to-Point模型
  * createTopic设置Publish/Subscribe模型
  * MessageProducer.send()将消息写入消息队列
  * MessageLister.onMessage()实现消息监听

### 2.4.3 使用阿里开源的RocketMQ实现互联网场景下的流量消峰

* RocketMQ
  * ActiveMQ为企业级应用而服务
  * 大型网站考虑高并发和海量数据
  * 顺序消息、事务消息、高吞吐量、高可用性及扩展性等问题
* 特性
  * 支持顺序消息
  * 支持事务消息
  * 支持集群与广播模式
  * 亿级消息堆积能力
  * 分布式特性
  * 支持Push与Pull两种消息订阅模式
* 组成
  * NameServer
    * 注册中心
    * 负责客户端的寻址操作
    * 节点间是无状态的
  * Broker
    * 消息的管理、存储及分发等功能
    * Queue是消息存储的最小逻辑单元，包含在Topic内部
    * Broker会和NameServer所有节点建立长连接，定时发送心跳和Topic信息
    * NameServer定时检查当前的存活连接
  * Producer和Consumer
    * Producer用于向Broker推送消息，Consumer负责消费Broker中的消息
    * Producer和Consumer与某一个NameServer节点建立长连接，定时轮询Topic信息
    * Producer和Consumer还会定时向Broker发送心跳
* 部署Broker
  * 单Master模式：Master宕机整个消息服务不可用
  * 多Master集群模式：性能最好。某个Broker宕机，未被消费的消息在该节点还未恢复之前，Consumer不能进行消费
  * 多Master/Slave异步复制模式：主从之间的数据同步采用异步操作
  * 多Master/Slave同步双写模式：类似MySQL数据库的半同步复制（Semi-synchronous Replication），**同一份数据只有在主从都成功写入后才返回给Producer**
* DefaultMQProducer
  * 设置producerGroup和NameServer地址后调用start()方法启动Producer连接
  * Topic会均匀分布到集群所有的Broker节点上
  * Producer会和关联的所有Broker节点建立长连接
  * DefaultMQProducer.send向消息队列写入消息
* DefaultMQPushConsumer
  * 设置合理的工作线程数
  * 集群模型：同一消息由某一个节点消费
  * 广播模型：所有订阅目标Topic的Consumer节点都可以进行消费
  * setConsumeFromWhere指定Consumer从哪里开始消费
  
### 2.4.4 基于MQ方案实现流量消峰的一些典型案例  

* MQ
  * 异步调用解决分布式环境下系统之间耦合问题
  * 面对高并发和海量数据，MQ实现流量削峰，避免流量过大对系统产生较大冲击
  * 控制并发写流量，降低后端存储系统的负载压力
* 案例
  * 前端埋点数据上报削峰案例；
  * 分布式调用跟踪系统的埋点数据上报削峰案例；
   