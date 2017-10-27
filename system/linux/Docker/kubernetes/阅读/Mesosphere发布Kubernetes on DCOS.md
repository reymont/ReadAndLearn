

* [Mesosphere发布Kubernetes on DC/OS 1.10 ](http://www.infoq.com/cn/news/2017/10/mesosphere-kubernetes)
http://blog.kubernetes.io/2015/04/kubernetes-and-mesosphere-dcos.html

* Mesosphere
  * Apache Mesos的商业实现
  * 操作数据密集型应用
  * 工具
    * 容器编排
    * 分布式数据库
    * 消息队列
    * 数据流处理
    * 机器学习
    * 监控和管理能力
    * 安全工具和部署自动化
  * 容器编排工具
    * https://mesosphere.github.io/marathon/
  * DC/OS（Datacenter Operating System，数据中心操作系统）
    * Kubernetes将运行在DC/OS上
    * 可以无缝地升级到更新的版本
    * 且滚动式的非破坏性升级（NDU，Non-Disruptive Upgrade）使多个版本可以运行在同一系统中
    * http://blog.kubernetes.io/2015/04/kubernetes-and-mesosphere-dcos.html
    * Kubernetes on DC/OS最终会支持将无状态工作负载扩展到云上，以添加本地（On-Premises）部署的能力
* 管理有状态
  * 数据存储：Cassandra、Redis
  * 数据库：MySQL和PostgreSQL
  * Kubernetes提供了一些使用StatefulSet特性的解决方案
  * [工具间的责任分割](https://news.ycombinator.com/item?id=15187261)