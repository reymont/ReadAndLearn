

Sharding-JDBC 2.0.0正式发布，分库分表 + 读写分离 + 数据治理一体化解决方案 http://www.infoq.com/cn/news/2017/12/Sharding-JDBC-2

Sharding-JDBC 2.0.0，在经过3个里程碑的迭代之后终于正式发布。Sharding-JDBC集分库分表、读写分离、分布式主键、柔性事务和数据治理与一身，提供一站式的解决分布式关系型数据库的解决方案。

从2.x版本开始，Sharding-JDBC正式将包名、Maven坐标、码云仓库、Github仓库和官方网站统一为io.shardingjdbc。这意味着除了当当的无私奉献，我们也乐于采纳第三方公司的代码贡献。本次2.0.0的版本，由当当与数人云共同开发。

Sharding-JDBC是一款基于JDBC的数据库中间件产品，对Java的应用程序无任何改造成本，只需配置分片规则即可无缝集成进遗留系统，使系统在数据访问层直接具有分片化和分布式治理的能力。

Sharding-JDBC 1.x关注SQL兼容性、分库分表、读写分离、分布式主键、柔性事务等分片功能；Sharding-JDBC 2.x提供了全新的Orchestration模块，关注数据库和数据库访问层应用的治理。2.0.0在治理方面的主要更新是：

配置动态化。可以通过zookeeper或etcd作为注册中心动态修改数据源以及分片规则。
数据治理。提供熔断数据库访问程序对数据库的访问和禁用从库的访问的能力。
跟踪系统支持。可以通过sky-walking等基于Opentracing协议的APM系统中查看Sharding-JDBC的调用链，并提供sky-walking的自动探针。
提供Sharding-JDBC的spring-boot-starter。
通过2.x提供的数据治理能力，sharding-jdbc的架构图是：



2.x沿用了1.x的SQL解析、SQL路由、SQL改写、SQL执行以及结果归并的这一套分片化体系。与1.x的最大区别是增加了为数据治理使用的注册中心模块，目前支持最常用的zookeeper和etcd两种注册中心的实现。Sharding-JDBC对分布式配置、分布式治理以及调用链路追踪分析这几个分布式应用的几个核心关注点进行了实现，与服务治理框架类似，数据库访问层的治理可以提供更加细粒度的层级进行熔断等操作。

配置动态化将Sharding-JDBC的配置信息放入注册中心。Sharding-JDBC的配置较为灵活，同时支持Java Config、YAML、Spring命名空间和Spring-boot-starter四种方式。配置动态化模块将不同的配置方式统一转换为JSON，并存储至注册中心，并通过监听配置节点的来探知配置信息的修改。配置信息修改会触发Sharding-JDBC数据源的重建，可以在不重启应用的前提下刷新数据源配置，以动态增减数据库和修改分片策略。

数据治理部分，Sharding-JDBC目前主要提供熔断和禁用相关的能力，未来会做进一步的扩展。熔断是针对数据库访问的应用，可以通过设置注册中心相关节点达到熔断某一运行中的应用对数据库的访问，而不间断其其他行为。在实际应用场景中，对于某些对整体数据库带来操作压力的服务，可以采用该方式减轻数据库的压力，而相关服务会自动降级，所有对数据库的访问将返回空结果集，或通过订阅异常的方式自定义降级行为。禁用功能主要是针对于读写分离中的从库，Sharding-JDBC支持可支持分库分表+读写分离或独立使用读写分离的两种方式。读写分离目前采用一主多从的方式，可以通过对某个从库的禁用以做到从库的不停机动态切换。

和服务化调用链类似，数据库访问同样需要采集、追踪和分析其调用链路。Sharding-JDBC完全遵守Opentracing协议，将数据库的分片SQL和数据源发送至支持Opentracing协议的APM产品。Sharding-JDBC还与sky walking深度合作，提供了sky walking的自动探针，可以让使用Sharding-JDBC的应用自动将调用链路追踪对接至任何标准系统。

本次2.0版本的开发，受到了数人云的大力支持，他们不但贡献了Sharding-JDBC的核心代码，还提供了hawk的统一配置中心平台，也会于近期开源。通过对Sharding-JDBC注册中心的读写，提供了对配置的图形化界面支持。Hawk的架构图如下：



著名的apm开源软件Sky-walking也将于近期采用Sharding-JDBC作为其底层存储追踪日志的存储引擎。整合了Sharding-JDBC作为存储引擎的Sky-walking架构图如下：



Sharding-JDBC将与配置中心hawk，APM的sky-walking一起打造分布式服务的生态圈。

欢迎访问Sharding-JDBC的官网：http://shardingjdbc.io/。