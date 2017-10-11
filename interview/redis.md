
# Gossip

* [Gossip算法 - 初夏why - 博客园 ](http://www.cnblogs.com/xingzc/p/6165084.html)

* 应用
  * Redis Cluster
  * Cassandra
* 论文
  * Efficient Reconciliation and Flow Control for Anti-Entropy Protocols
* 特点
  * 反熵（Anti-Entropy）
    * 熵代表杂乱无章，而反熵就是在杂乱无章中寻求一致
  * 每个节点都随机的与其他节点通信，经过一番杂乱无章的通信，最终所有节点的状态都会达成一致
  * 有节点因宕机而重启或新节点加入，经过一段时间后，最终所有节点的状态都会达成一致
* 本质
  * 带冗余的容错算法
  * 最终一致性算法
  * 去中心化
  * 冗余通信对网络带宽、CPU资源造成很大的负载
* Gossip节点的通信方式及收敛性
  * 通信方式
    * push：通信1次
    * pull：通信2次
    * push/pull：通信3次，一个周期内两个节点完全一致

# Redis集群技术及Codis实践

* [高效运维最佳实践（01）：七字诀，不再憋屈的运维 ](http://www.infoq.com/cn/articles/effective-ops-part-01?utm_source=infoq&utm_campaign=user_page&utm_medium=link)
* [高效运维最佳实践（02）：员工的四大误区及解决之道 ](http://www.infoq.com/cn/articles/effective-ops-part-02?utm_source=infoq&utm_campaign=user_page&utm_medium=link)
* [高效运维最佳实践（03）：Redis集群技术及Codis实践 ](http://www.infoq.com/cn/articles/effective-ops-part-03)
* [运维 2.0：危机前的自我拯救 | 高效运维最佳实践 （04） ](http://www.infoq.com/cn/articles/effective-ops-part-04?utm_source=infoq&utm_campaign=user_page&utm_medium=link)
* [第十一课——codis-server的高可用，对比codis和redis cluster的优缺点 - 在路上ing - 博客园 ](http://www.cnblogs.com/cjing2011/p/9bafc11fc32e37d2ba29a8758f4b16ff.html)
* [Codis VS redis-cluster简单比较 - lcuzzc的专栏 - CSDN博客 ](http://blog.csdn.net/lcuzzc/article/details/50116655)
* [CodisLabs/codis: Proxy based Redis cluster solution supporting pipeline and scaling dynamically ](https://github.com/CodisLabs/codis)
* [redis4.0、codis、阿里云redis 3种redis集群对比分析-博客-云栖社区-阿里云 ](https://yq.aliyun.com/articles/68593)


* redis cluster
  * 通过分片实现容量扩展
  * 通过主从复制实现节点的高可用
  * 节点之间互相通信
    * P2P模型，gossip协议，去中心化
    * 自动选主
  * 每个节点都维护整个集群的节点信息
  * redis-cluster把所有的物理节点映射到[0-16383]slot上
  * cluster负责维护node -> slot -> key

* Redis常见集群技术
  * Redis本身仅支持单实例，内存一般最多10~20GB
* 三种实现机制
* 客户端分片
  * 特点
    * 将分片工作放在业务程序端
    * 程序代码根据预先设置的路由规则，直接对多个Redis实例进行分布式访问
    * 静态分片技术
  * 优缺点
    * 性能比代理式更好，少了中间分发环节
    * 升级麻烦：Redis实例增减都得手工调整分片程序
* 代理分片
  * 特点
    * 将分片工作交给专门的代理程序
    * 代理程序根据路由规则，将请求分发给正确的Redis实例并返回给业务程序
  * 优缺点
    * 有性能损耗
    * 运维简单
* Redis Cluster
  * 特点
    * 没有中心节点
    * 将所有Key映射到16384个Slot中，集群中每个Redis实例负责一部分
    * 通过节点之间两两通信，定期交换并更新
* Twemproxy
  * 代理分片机制
  * 本身是单点，需要Keepalived做高可用方案
  * 无法平滑的扩容/缩容
* Codis
  * 引入了Group的概念
    * 每个Group包括1个Master及至少1个Slave
    * 运维人员可以通过Dashboard自助式切换到Slave
    * 集群管理层与存储层解耦
  * 一整套缓存解决方案，包含高可用、数据分片、监控、动态扩容
  * 基于2.8.13分支开发，修改Redis源代码，并称之为Codis Server，支持数据热迁移
  * Zookeeper
    * Codis采取预分片机制，最多支持1024个Codis Server，路由信息保存在Zookeeper中
    * ZooKeeper还维护Codis Server Group信息，并提供分布式锁等服务。
    * Codis仅维护Redis Server列表，`不负责主从数据的一致性`
    * 不自动选主，交由运维人员处理
  * Dashboard运维方便，Dashboard监控当前redis-server节点情况
* Codis实用工具
  * 无缝迁移Twemproxy：Codis-port
  * 支持Java程序的HA：单个Codis Proxy宕机，Jodis自动发现
  * 支持Pipeline：使客户端发出一批请求，并一次性获得这批请求的返回结果

