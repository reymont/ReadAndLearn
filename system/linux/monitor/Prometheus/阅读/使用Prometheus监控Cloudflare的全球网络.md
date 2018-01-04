
使用Prometheus监控Cloudflare的全球网络
http://www.infoq.com/cn/news/2017/11/monitoring-cloudflare-prometheus
https://www.infoq.com/news/2017/10/monitoring-cloudflare-prometheus

https://www.cloudflare.com/
https://www.cncf.io/blog/2016/04/09/welcome-prometheus/
https://prometheus.io/
https://www.infoq.com/news/2016/04/jare-free-cdn
https://promcon.io/2017-munich/talks/monitoring-cloudflares-planet-scale-edge-network-with-prometheus/
https://bosun.org/quickstart#creating-an-alert


介绍了如何使用Prometheus实现对CloudFlare分布于全球的架构和网络的监控。Prometheus是一种基于度量进行监控的工具，CloudFlare是一家CDN、DNS和DDoS防御（Mitigation）服务提供商。

基于度量的开源监控项目Prometheus最早推出于2012年，它是CNCF（原生云计算基金会，Cloud Native Computing Foundation）的成员。Prometheus的动态配置和查询语言PromQL支持用户编写对告警的复杂查询。

* Anycast
  * Anycast DNS使得DNS查询可以被最接近用户的服务器所处理
  * Anycast HTTP使得内容可以从距离用户最近的服务提供。作为原始Web站点和用户之间的中介
  * CloudFlare还检查访问者的流量中是否存在有威胁的模式
  * 每个入网点（PoP，Point-Of-Presence）提供HTTP、DNS、DDoS防御和键值存储服务

* 服务包括日志访问、分析业务，
* Marathon、Mesos、Chronos、Docker、Sentry、Ceph（用于存储）、Kafka、Spark、Elasticsearch和Kibana等技术栈构建的API。

* jiralerts
  * jiralerts实现JIRA工单系统与Alertmanager的集成
  * https://github.com/fabxc/jiralerts
  * JIRA可以用户定制工作流，使得报警监控中可以包括一些监控工作流特定的用户定制状态
* alertmanagere2s
  * alertmanagere2s的工具接收报警，并将报警信息集成到Elasticsearch索引中，用于进一步的检索和分析。
  * https://github.com/cloudflare/alertmanager2es
* unsee
  * https://github.com/cloudflare/unsee
  * 仪表盘
* 监控自身情况
  * 由一个Prometheus去监控另一个Prometheus
  * 自顶向下的方法，由顶层Prometheus服务器监控位于数据中心层面的Prometheus服务