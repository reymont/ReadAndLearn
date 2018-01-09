PROMETHEUS 监控系统介绍与实践总结
prometheus 监控系统介绍与实践总结 · Ruhm https://blog.ruhm.me/post/prometheus-intro/

prometheus 监控系统介绍与实践总结
prometheus 简单介绍
prometheus 是什么？
它有什么特点？
关键词：时间序列数据
关键词：push vs pull model
核心组件
基础架构
实践总结以及监控系统的思考
实践总结
prometheus 适用场景思考
参考资料
prometheus 监控系统介绍与实践总结

关键词：prometheus、时间序列数据、push/pull模型、容器监控

最近，由于在调研容器平台的原因，关注了一些互联网企业的技术博客，阅读了许多容器平台相关技术栈的文章，在他们的技术栈中反复提到了 prometheus这个监控系统，非常好奇它有什么神奇之处，众多架构师对它趋之若鹜，所以在前一周做了一些研究和实践，在这里分享给大家。第一部分主要对 prometheus 做了简单介绍，这一部分主要是官网的资料和一些技术博客的分享；第二部分是基于 prometheus 的MySQL主从结构监控的demo实践和 prometheus 适用场景的一些思考，主要是基于我个人研究和实践的基础上的结论；

prometheus 简单介绍

prometheus 是什么？

Prometheus 是由 SoundCloud 开源监控告警解决方案，从 2012 年开始编写代码，再到 2015 年 github 上开源以来，已经吸引了 9k+ 关注，以及很多大公司的使用；2016 年 Prometheus 成为继 k8s 后，第二名 CNCF(Cloud Native Computing Foundation) 成员。
作为新一代开源解决方案，很多理念与 Google SRE 运维之道不谋而合。
它有什么特点？

自定义多维数据模型(时序列数据由metric名和一组key/value标签组成)
非常高效的存储 平均一个采样数据占 ~3.5 bytes左右，320万的时间序列，每30秒采样，保持60天，消耗磁盘大概228G。
在多维度上灵活且强大的查询语言(PromQl)
不依赖分布式存储，支持单主节点工作
通过基于HTTP的pull方式采集时序数据
可以通过push gateway进行时序列数据推送(pushing)
可以通过服务发现或者静态配置去获取要采集的目标服务器
多种可视化图表及仪表盘支持
上面基本是我从官网上翻译过来的，这其中有几个关键词

关键词：时间序列数据

Prometheus 所有的存储都是按时间序列去实现的，相同的 metrics(指标名称) 和 label(一个或多个标签) 组成一条时间序列，不同的label表示不同的时间序列。

每条时间序列是由唯一的 指标名称 和 一组 标签 （key=value）的形式组成。

指标名称
一般是给监测对像起一名字，例如 http_requests_total 这样，它有一些命名规则，可以包字母数字之类的的。通常是以应用名称开头监测对像数值类型单位这样。例如：

 - push_total
 - userlogin_mysql_duration_seconds
 - app_memory_usage_bytes
标签
就是对一条时间序列不同维度的识别了，例如 一个http请求用的是POST还是GET，它的endpoint是什么，这时候就要用标签去标记了。最终形成的标识便是这样了

http_requests_total{method="POST",endpoint="/api/tracks"}
如果以传统数据库的理解来看这条语句，则可以考虑 http_requests_total是表名，标签是字段，而timestamp是主键，还有一个float64字段是值了。（Prometheus里面所有值都是按float64存储）

关键词：push vs pull model

push_vs_pull (图片来自 google 搜索)

我们目前比较熟悉的监控系统系统，基本上都是第一种 push类型的，监控系统被动接受来自agent主动上报的各项健康指标数据，典型的监控系统是zabbix、open-falcon；还有一种就是基于pull模型的，被监控系统向外暴露系统指标，监控系统主动去通过某些方式（通常是http）拉取到这些指标，最典型的是 prometheus；

下面是这两种方案的对比：

push_vs_pull_comparision

核心组件

Prometheus Server， 主要用于抓取数据和存储时序数据，另外还提供查询和 Alert Rule 配置管理。
client libraries，用于对接 Prometheus Server, 可以查询和上报数据。
push gateway ，用于批量，短期的监控数据的汇总节点，主要用于业务数据汇报等。
各种汇报数据的 exporters ，例如汇报机器数据的 node_exporter, 汇报 MongoDB 信息的 MongoDB exporter 等等。
用于告警通知管理的 alertmanager 。
基础架构

官方的架构图如下：

prometheus_arch

大致使用逻辑是这样： 1. Prometheus server 定期从静态配置的 targets 或者服务发现的 targets 拉取数据。 2. 当新拉取的数据大于配置内存缓存区的时候，Prometheus 会将数据持久化到磁盘（如果使用 remote storage 将持久化到云端）。 3. Prometheus 可以配置 rules，然后定时查询数据，当条件触发的时候，会将 alert 推送到配置的 Alertmanager。 4. Alertmanager 收到警告的时候，可以根据配置，聚合，去重，降噪，最后发送警告。

实践总结以及监控系统的思考

实践总结

基于 percona 官方监控 mysql 的例子做了一个 MySQL 主从架构的监控实践，这里就不再赘述其搭建过程了，直接谈谈这次实践遇到的问题及心得体会：

如果要加入新的 targets（或者叫被监控节点），必须修改prometheus配置文件然后重启服务才能加载，另外，所有的配置都是在配置文件中完成的，这一点在 易用性上比 zabbix 差了很多；；
需要为不同的监控启动不同的 exporter 服务，例如，如果要监控机器的指标，就需要启动Node exporter服务，需要监控 MySQL 性能指标MySQL server exporter服务，并且需要暴露在不同的端口上，这样来看，运维上不易管理；
查询语言PromQL强大，通过简单的表达式就可以计算集群指标；
Grafana 有官方的 Prometheus dashboard ，可视化方面并不逊色；
prometheus 适用场景思考

相比于老牌监控系统，prometheus 还有很多不足，并且基于 pull 的模型并不是监控系统的「银弹」，那么它适合哪些环境下的监控呢？我们可以从它的特征来分析：

纯数字时间序列数据监控 Prometheus在记录纯数字时间序列方面表现非常好，而并不适用于 API 可用性检测等 long-time job 类型的监控；

集群服务监控 prometheus 提供的强大灵活的查询语言PromQL ，用于计算集群服务的相关指标

基于 k8s 平台的容器监控 上面提到，prometheus 可以通过服务发现或者静态配置去获取要采集的目标服务器，所以对于 k8s，可以通过 <kubernetes_sd_config>配置项动态获取kubernetes中定义的 pods 暴露出来的监控指标，而不需要关心 k8s 的调度；另一方面，k8s 提供了Daemon Sets用于在在所有nodes都运行一个node exporter来监控 nodes的机器性能指标，从这一点来说，k8s 和 prometheus 集成度还是很高的，所以很多自建的容器平台都选择了 prometheus 作为监控的基础组件。

所以我的结论是，

基础监控，比如机器各项性能指标监控等还是交给push模型的监控系统提供来做，毕竟成熟且周边生态更完善，对于紫金的监控体系中，交给 Zabbix 就可以了；
prometheus 基于 pull 模型的特点非常适合 应用性能监控（APM），通常应用的开发者最清楚哪些指标是最能体现应用性能的，他可以通过 prometheus 提供的 client library 向外暴露出系统的性能指标，配置好 prometheus 的targets和alert rules就可以很好地监控起来了。一个非常经典的例子是 gitlab 的 omnibus 安装包，它将 prometheus 服务内嵌进来，将 gitlab 服务的各项性能指标都暴露给 prometheus 收集，我们只需要在 Grafana 中导入一个dashboard 就可以对 gitlab 的监控指标可视化；
假设要建设k8s容器平台，监控系统组件优先考虑 premetheus 和 cAdvisor 的组合。
以上，谢谢阅读。

参考资料

Prometheus - Monitoring system & time series database
使用Prometheus监控服务器性能
DockOne微信分享（一一七）：沪江容器化运维实践 - DockOne.io
基于Prometheus的分布式在线服务监控实践 - 知乎专栏
五个Docker监控工具的对比 - DockOne.io
Prometheus 实战 · GitBook