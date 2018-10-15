
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

* [0. awesome](#0-awesome)
* [1. java](#1-java)
	* [1.1 java](#11-java)
	* [1.2 jvm](#12-jvm)
	* [1.3 高并发](#13-高并发)
	* [1.4 spring-boot](#14-spring-boot)
	* [1.5 spring-cloud](#15-spring-cloud)
	* [1.6 spring-security](#16-spring-security)
	* [1.7 Maven](#17-maven)
	* [1.8 OAuth](#18-oauth)
* [2. jenkins](#2-jenkins)
* [3. linux](#3-linux)
* [4. kubernetes](#4-kubernetes)
* [5. ELK](#5-elk)
* [6. Prometheus](#6-prometheus)
* [7. git](#7-git)
	* [7.1 git](#71-git)
	* [7.2 gitlab](#72-gitlab)
	* [7.3 gogs](#73-gogs)
* [8. redis](#8-redis)
* [9. Pinpoint](#9-pinpoint)
* [10. nginx](#10-nginx)
* [11. kong](#11-kong)

<!-- /code_chunk_output -->




# 0. awesome

* https://github.com/sindresorhus/awesome
* https://github.com/xingshaocheng/architect-awesome
* https://github.com/mfornos/awesome-microservices
* https://github.com/avelino/awesome-go
* https://github.com/akullpp/awesome-java
* https://github.com/jobbole/awesome-java-cn
* https://github.com/vinta/awesome-python
* https://github.com/sorrycc/awesome-javascript
* https://github.com/alebcay/awesome-shell
* https://github.com/prakhar1989/awesome-courses
* https://github.com/veggiemonk/awesome-docker
* https://github.com/MaximAbramchuck/awesome-interview-questions
* https://github.com/bayandin/awesome-awesomeness
* https://github.com/binhnguyennus/awesome-scalability
* https://github.com/dastergon/awesome-sre

# 1. java

## 1.1 java

1. [Linux上设置开机启动Java程序](https://www.cnblogs.com/alsodzy/p/7931618.html)
2. [hashCode和identityHashCode的区别](https://blog.csdn.net/tbdp6411/article/details/46915981)

## 1.2 jvm

1. [Java调优经验谈 - ImportNew](http://www.importnew.com/22336.html)
2. [top+jstack分析cpu过高原因](https://blog.csdn.net/ct29102656/article/details/51882946)
3. [一步一步优化JVM](https://blog.csdn.net/zhoutao198712/article/category/1194642)
4. [java核心技术 - 专栏](https://blog.csdn.net/column/details/14009.html)
5. [JVM 线上故障排查基本操作](https://www.cnblogs.com/stateis0/p/9062196.html)
6. [happen-before](https://blog.csdn.net/ns_code/article/details/17348313)
7. [实战JAVA虚拟机.JVM故障诊断与性能优化.葛一鸣.2015 源代码](https://github.com/reymont/JVMInPractice)
8. https://github.com/reymont/szjvm.git
9. [jvm的GC日志分析](https://blog.csdn.net/doc_sgl/article/details/46594123)
10. [GC日志分析](https://blog.csdn.net/huangzhaoyang2009/article/details/11860757)

> 虚拟机参数

1. [HeapByteBuffer&DirectByteBuffer以及回收DirectByteBuffer](https://blog.csdn.net/xieyuooo/article/details/7547435)

> 吞吐量

* 吞吐量是指应用程序线程用时占程序总用时的比例。
* 术语“暂停时间”是指一个时间段内应用程序线程让与GC线程执行而完全暂停。
* “高吞吐量”和“低暂停时间”互相矛盾。因为，在GC的时候，垃圾回收的工作总量是不变的，如果将停顿时间减少，那频率就会提高；既然频率提高了，说明就会频繁的进行GC，那吞吐量就会减少，性能就会降低。

1. https://blog.csdn.net/moshenglv/article/details/54178186
2. https://blog.csdn.net/zhoutao198712/article/details/7842500
3. [JVM常见问题总结](https://www.cnblogs.com/smyhvae/p/4810168.html)

> jstack

1. https://blog.csdn.net/ct29102656/article/details/51882946

> OQL

1. [visualvm oql查询](https://www.cnblogs.com/lmjk/articles/7478154.html)
2. [强引用、软引用、弱引用和虚引用](https://www.cnblogs.com/renhui/p/6069437.html)

## 1.3 高并发

> 并发容器

CountDownLatch、CyclicBarrier、Semaphore

1. http://www.importnew.com/21889.html

>> CountDownLatch
1. https://blog.csdn.net/shihuacai/article/details/8856370
2. https://blog.csdn.net/xlgen157387/article/details/78218736
3. https://www.cnblogs.com/xubiao/p/7785042.html

## 1.4 spring-boot

1. http://hao.jobbole.com/spring-boot/
2. https://www.cnblogs.com/ityouknow/category/914493.html

> redis

1. [使用redis的Keyspace Notifications实现定时任务队列](https://blog.csdn.net/liuchuanhong1/article/details/70147149)

## 1.5 spring-cloud

1. 	https://www.cnblogs.com/ityouknow/category/994104.html
2. 	[史上最简单的 Spring Cloud 教程 - 专栏](https://blog.csdn.net/column/details/15197.html)
3. 	[方志朋的博客](https://blog.csdn.net/forezp)
4. 	https://github.com/forezp/SpringCloudLearning
5. 	https://github.com/forezp/springcloud-book
6. 	http://projects.spring.io/spring-cloud/
7. 	https://github.com/spring-cloud
8. 	http://cloud.spring.io/spring-cloud-static/Dalston.SR3/
9.  https://springcloud.cc/
10. https://eacdy.gitbooks.io/spring-cloud-book/content/
11. http://cloud.spring.io/spring-cloud-netflix/spring-cloud-netflix.html
12. http://cloud.spring.io/spring-cloud-static/Finchley.M2/
13. http://cloud.spring.io/spring-cloud-static/Dalston.SR4/single/spring-cloud.html



> dubbo vs spring-cloud

1. https://www.cnblogs.com/lfs2640666960/p/9026612.html
2. https://www.cnblogs.com/ityouknow/p/7864800.html
3. http://blog.51cto.com/13127751/2108480
4. https://github.com/itmuch/spring-cloud-dubbo-together
5. https://blog.csdn.net/dream8062/article/details/71169545/

> actuator

1. [spring boot 配置动态刷新](https://www.cnblogs.com/flying607/p/8459397.html)
2. [Full authentication is required to access this resource](https://blog.csdn.net/fly910905/article/details/78580895)
3. https://gitee.com/ylimhhmily/SpringCloudTutorial/tree/master/springms-config-client-refresh
4. https://gitee.com/ylimhhmily/SpringCloudTutorial/tree/master/springms-config-client-refresh-bus
5. [AbstractApplicationContext抽象类的refresh()方法](https://www.cnblogs.com/GooPolaris/p/8184429.html)

> Spring Cloud Bus

1. [Spring Cloud 是如何实现热更新的](https://www.jianshu.com/p/ee504c7b6fe2)
2. [第八篇: 消息总线(Spring Cloud Bus)](https://blog.csdn.net/forezp/article/details/70148235)
3. https://github.com/forezp/SpringCloudLearning/tree/master/chapter8
4. https://cloud.spring.io/spring-cloud-bus/
5. [SpringCloud之消息总线Spring Cloud Bus实例](https://blog.csdn.net/smartdt/article/details/79073765)
6. [SpringBoot整合ActiveMq](https://blog.csdn.net/u013115157/article/details/79413429)
7. https://hub.docker.com/r/_/rabbitmq/
8. [springboot 2.0.0.RELEASE+springcloud bus实现配置动态刷新](https://my.oschina.net/u/2263272/blog/1634010)
9. [解决Spring Cloud Bus不刷新所有节点的问题](https://blog.csdn.net/liu_yulong/article/details/79581697)
10. [Spring cloud properties与yml配置说明](https://blog.csdn.net/hxc1314157/article/details/79424381)

> Eureka

1. [Consul vs Zookeeper vs Etcd vs Eureka](https://blog.csdn.net/u010963948/article/details/71730165)
2. [服务的注册与发现Eureka(Finchley版本)](https://blog.csdn.net/forezp/article/details/81040925)
3. [服务的注册与发现（Eureka）](https://blog.csdn.net/forezp/article/details/69696915)
4. [高可用的服务注册中心](https://blog.csdn.net/forezp/article/details/70183572)
5. [深入理解Eureka之源码解析](https://blog.csdn.net/forezp/article/details/73017664)

> config

1. [轻松读取项目中properties文件的方式](https://blog.csdn.net/liq816/article/details/78909269)
2. [spring boot 打成jar包后 通过命令行传入的参数 3中实现方式](https://blog.csdn.net/zhuchunyan_aijia/article/details/78891533)

>> Spring Cloud Zookeeper

1. [使用Spring Cloud Zookeeper实现服务的注册和发现](https://blog.csdn.net/mn960mn/article/details/51803703)

>> config-keeper

1. [分布式配置中心 ConfigKeeper](https://www.oschina.net/p/configkeeper?origin=wx2wm)
2. https://github.com/sxfad/config-keeper
3. https://gitee.com/sxfad

> zuul

1. [Zuul忽略某些路径](https://blog.csdn.net/chengqiuming/article/details/80805647)
2. [微服务网关解决方案调研和使用总结](https://www.cnblogs.com/softidea/p/7261095.html)
3. [在Spring Cloud中实现降级之权重路由和标签路由](https://xujin.org/sc/sc-ribbon-demoted/)
4. https://github.com/jmnarloch/zuul-route-cassandra-spring-cloud-starter
5. [使用zuul及oauth2构建api网关实践之路](https://www.jianshu.com/p/b1fc3f7260d3)
6. [Spring Framework灰度发布 - 蓝绿、滚筒和灰度](https://blog.csdn.net/yejingtao703/article/details/78562895)
7. https://github.com/SpringCloud/spring-cloud-gray


>> 动态路由

1. [Zuul过滤器动态加载](https://blog.csdn.net/chengqiuming/article/details/81267421)
2. [spring-cloud-zuul动态路由的实现](https://my.oschina.net/dengfuwei/blog/1621627)
3. [Zuul动态路由及动态Filter实现](https://blog.csdn.net/u014091123/article/details/75433656)
4. [zuul实现动态路由以及相关源码解析](https://segmentfault.com/a/1190000009191419)
5. [zuul动态配置路由规则，从DB读取](https://www.jishux.com/p/40091e9adcfed5e6)
6. [springcloud----Zuul动态路由](https://blog.csdn.net/u013815546/article/details/68944039)
7. [redis存储与读取对象和对象集合](https://blog.csdn.net/dongzhongyan/article/details/76984611)
8. https://github.com/reymont/ccp-starter/blob/master/ccp-gate/ccp-gate-server/src/main/java/com/coracle/cloud/security/gate/route/RedisRouteLocator.java (fork)
9. https://github.com/CoracleCloud/ccp-starter/blob/master/ccp-auth/ccp-auth-server/src/main/java/com/coracle/cloud/security/auth/module/client/biz/GatewayRouteBiz.java (fork)

>> groovy

1. https://blog.csdn.net/u010928250/article/details/70789494

## 1.6 spring-security

1. https://springcloud.cc/spring-security-zhcn.html
2. http://spring.io/projects/spring-security
3. https://github.com/forezp/springcloud-book
4. [Spring Security Guides](https://docs.spring.io/spring-security/site/docs/current/guides/html5/index.html)

> Shiro vs Spring Security

1. https://blog.csdn.net/liyuejin/article/details/77838868

> 入门

1. https://www.jianshu.com/p/a8e317e82425
2. https://www.jianshu.com/p/e6655328b211

> @EnableGlobalMethodSecurity

1. https://www.jianshu.com/p/41b7c3fb00e0

## 1.7 Maven

> dependencyManagement

1. [Maven 中 dependencyManagement 标签使用](https://www.jianshu.com/p/ee15cda51d9d)

## 1.8 OAuth

1. [理解OAuth 2.0 - 阮一峰](http://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)


# 2. jenkins

1. https://jenkins.io/doc/tutorials
2. https://www.w3cschool.cn/jenkins
3. https://jenkins.io/doc/book/
4. https://blog.csdn.net/wangmuming/article/category/2167947
5. https://github.com/jenkinsci/jenkins
6. https://www.cnblogs.com/itech/category/245402.html
7. https://github.com/ciandcd

> plugin

>> Role-based Authorization Strategy

1. [jenkins 创建用户角色项目权限](https://blog.csdn.net/u013066244/article/details/53407985)

> pipeline

1. https://jenkins.io/doc/book/pipeline/

>> try

1. https://stackoverflow.com/questions/38392254/jenkins-pipeline-try-catch-insyde-a-retry-block/38403003
2. https://www.w3cschool.cn/jenkins/jenkins-qc8a28op.html

>> step

1. https://jenkins.io/doc/pipeline/steps/
2. https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/
3. https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/
4. https://jenkins.io/doc/pipeline/steps/git

>> booleanParam

1. https://jenkins.io/doc/pipeline/steps/pipeline-build-step/

>> readjson

1. https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#-readjson

>> credentials

1. https://jenkins.io/doc/pipeline/steps/credentials-binding/
2. http://www.cnblogs.com/jinanxiaolaohu/p/9204739.html
3. https://wiki.jenkins.io/display/JENKINS/Credentials+Binding+Plugin


> parallel

1. https://www.cnblogs.com/itech/p/5646219.html
2. https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md
3. https://www.cnblogs.com/itech/p/5678643.html
4. https://stackoverflow.com/questions/39958446/jenkins-parallel-pipeline-all-subroutine-calls-in-parameter-blocks-pass-argumen
5. https://stackoverflow.com/questions/36872657/running-stages-in-parallel-with-jenkins-workflow-pipeline

> BlueOcean

1. http://blog.csdn.net/neven7/article/details/53645215

> environment

1. https://jenkins.io/doc/pipeline/tour/environment

# 3. linux

> dos2unix

1. [关于 bash:$'\r': command not found 的问题](https://blog.csdn.net/shenzhen_zsw/article/details/73924489)


# 4. kubernetes



1.  https://mp.weixin.qq.com/s/RK6DDc8AUBklsUS7rssW2w
2.  https://jimmysong.io/kubernetes-handbook/
3.  http://blog.csdn.net/column/details/12761.html
4.  https://www.gitbook.com/book/feisky/kubernetes/details
5.  http://kubernetes.kansea.com/docs/
6.  https://github.com/kelseyhightower/kubernetes-the-hard-way
7.  https://github.com/opsnull/follow-me-install-kubernetes-cluster
8.  https://kubernetes.io/docs/reference/kubectl/cheatsheet/
9.  http://docs.kubernetes.org.cn
10. https://www.kubernetes.org.cn/
11. [深入浅出kubernetes](https://blog.csdn.net/column/details/12761.html)

> kubectl 

1. [Kubernetes之kubectl常用命令使用指南:1:创建和删除](https://blog.csdn.net/liumiaocn/article/details/73913597)
2. [Kubernetes之kubectl常用命令使用指南:2:故障排查](https://blog.csdn.net/liumiaocn/article/details/73925301)
3. [Kubernetes之kubectl常用命令使用指南:3:故障对应](https://blog.csdn.net/liumiaocn/article/details/73997635)

>> autoscale

1. http://docs.kubernetes.org.cn/486.html
2. http://blog.itpub.net/28624388/viewspace-2154459/

> python client

1. [CERTIFICATE_VERIFY_FAILED](https://github.com/kubernetes-client/python/issues/521)

> ingress

>> nginx-ingress

1. [初试 Kubernetes 暴漏服务类型之 Nginx Ingress](https://blog.csdn.net/aixiaoyang168/article/details/78485581)

>> traefik

1. https://docs.traefik.io/user-guide/kubernetes/
2. [详解k8s组件Ingress边缘路由器并落地到微服务](https://www.cnblogs.com/justmine/p/8991379.html)
3. [初试 Kubernetes 集群中使用 Traefik 反向代理](https://blog.csdn.net/aixiaoyang168/article/details/78557739)

# 5. ELK

> 入门

- [知乎为什么要自己开发日志聚合系统「kids」而不用更简洁方便的「ELK」？ - 知乎](https://www.zhihu.com/question/27214433) （2010年scribe停止开发，之后才有一大把开源日志系统出现）
- [日志收集架构－ELK | kazaff's blog | 种一棵树最佳时间是十年前，其次是现在](http://blog.kazaff.me/2015/06/05/%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E6%9E%B6%E6%9E%84--ELK/)
- [Elastic Stack and Product Documentation | Elastic](https://www.elastic.co/guide/index.html) （总文档）
- [Elasticsearch Reference [5.4] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [elastic/examples](https://github.com/elastic/examples): Home for Elasticsearch examples available to everyone. It's a great way to get started.
- [前言 · ELKstack 中文指南](https://kibana.logstash.es/content/) （gitbook）
- [前言 | Mastering Elasticsearch 中文版](https://wizardforcel.gitbooks.io/mastering-elasticsearch/content/index.html) （gitbook）

> prefix

- [prefix 前缀查询 | Elasticsearch: 权威指南 | Elastic](https://www.elastic.co/guide/cn/elasticsearch/guide/current/prefix-query.html)
- [escaping forward slashes in elasticsearch - Stack Overflow](https://stackoverflow.com/questions/31963643/escaping-forward-slashes-in-elasticsearch)

    {"prefix":{"uri.keyword":"/api/v1"}}
    { "query_string": {"query":"\/api/v1","analyzer": "keyword" }}

> 集群

- [https://hub.docker.com/r/library/elasticsearch/](https://hub.docker.com/r/library/elasticsearch/)
- [Install Elasticsearch with Docker | Elasticsearch Reference [5.5] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
- [docs/README.md at master · docker-library/docs](https://github.com/docker-library/docs/blob/master/elasticsearch/README.md)
- [docs/README.md at master · docker-library/docs](https://github.com/docker-library/docs/blob/master/logstash/README.md)
- [Log4j – Log4j 2 Layouts - Apache Log4j 2](https://logging.apache.org/log4j/2.x/manual/layouts.html)

> Search

- [elasticsearch - Elastic Search : Expected numeric type on field - Stack Overflow](https://stackoverflow.com/questions/44626157/elastic-search-expected-numeric-type-on-field) （Integer.parseInt(doc["mlf16_txservnum"].value)）
- [《Elasticsearch in Action》阅读笔记八：使用聚合函数探索数据 - 竹林品雨|zhulinpinyu's blog](http://blog.zhulinpinyu.com/2016/08/22/elasticsearch-read-notes8-aggs-explore-data/) （精度）

> vm.max_map_count

- [elasticsearch - Docker - ELK - vm.max_map_count - Stack Overflow](https://stackoverflow.com/questions/41064572/docker-elk-vm-max-map-count) （sysctl -w vm.max_map_count=655360）
- [我的ELK搭建笔记（阿里云上部署） - 推酷](http://www.tuicool.com/articles/ZbIZbeR)

> node.js

- [Getting started with elasticsearch and Express.js](https://blog.raananweber.com/2015/11/24/simple-autocomplete-with-elasticsearch-and-node-js/)
- [RaananW/express.js-elasticsearch-autocomplete-demo: A simple demo showing how simple it is to use elasticsearch with express.js](https://github.com/RaananW/express.js-elasticsearch-autocomplete-demo)
- [elastic/elasticsearch-js: Official Elasticsearch client library for Node.js and the browser](https://github.com/elastic/elasticsearch-js)
- [Build a Search Engine with Node.js and Elasticsearch — SitePoint](https://www.sitepoint.com/search-engine-node-elasticsearch/)
- [sitepoint-editors/node-elasticsearch-tutorial: Examples for setting up and using elasticsearch in Node.js](https://github.com/sitepoint-editors/node-elasticsearch-tutorial)
- [javascript - Example of Angular and Elasticsearch - Stack Overflow](https://stackoverflow.com/questions/22661996/example-of-angular-and-elasticsearch)
- [dncrews/angular-elastic-builder](https://github.com/dncrews/angular-elastic-builder): This is an Angular.js directive for building an Elasticsearch query. You just give it the fields and can generate a query for it.
- [Running a Node.js Express app with an Elasticsearch back end on Docker on Mac OS X | André Kolell](http://www.andrekolell.de/blog/running-nodejs-express-app-with-elasticsearch-on-docker-on-mac)

> golang

- [olivere/elastic: Elasticsearch client for Go.](https://github.com/olivere/elastic)
- [Getting started with elastic.v3](https://gist.github.com/olivere/114347ff9d9cfdca7bdc0ecea8b82263)
- [Home · olivere/elastic Wiki](https://github.com/olivere/elastic/wiki)
- [kamorahul/golang-elastic-api: A working api with golang and oliver elastic search](https://github.com/kamorahul/golang-elastic-api)
- [Elastic: An Elasticsearch client for Go](http://olivere.github.io/elastic/)

> Lucene

- [百度脑图](http://naotu.baidu.com/file/28c217f0ae265f2b7fabed2d3bda33ab?token=bf3384588c267201)
- [Lucene的基本概念 - 简书](http://www.jianshu.com/p/23512e8158da)
- [实战 Lucene，第 1 部分: 初识 Lucene](https://www.ibm.com/developerworks/cn/java/j-lo-lucene1/index.html)

> docker

- [Docker日志自动化: ElasticSearch、Logstash、Kibana以及Logspout - DockOne.io](http://dockone.io/article/373)
- [Install Elasticsearch with Docker | Elasticsearch Reference [5.4] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) （current，官方docker安装配置文档）
- [docker-library/elasticsearch: Docker Official Image packaging for elasticsearch](https://github.com/docker-library/elasticsearch)
- [dockerfile/elasticsearch: ElasticSearch Dockerfile for trusted automated Docker builds.](https://github.com/dockerfile/elasticsearch)
- [docs/elasticsearch at master · docker-library/docs](https://github.com/docker-library/docs/tree/master/elasticsearch)
- [sebp/elk - Docker Hub](https://hub.docker.com/r/sebp/elk/)（All in one 版本）
- [elk-docker](http://elk-docker.readthedocs.io/) （sebp/elk文档）
- [spujadas/elk-docker: Elasticsearch, Logstash, Kibana (ELK) Docker image](https://github.com/spujadas/elk-docker) （sebp/elk github地址）
- [deviantony/docker-elk: The ELK stack powered by Docker and Compose.](https://github.com/deviantony/docker-elk)（基于官方做的docker-compose）
- [elastic/elasticsearch-docker: Official Elasticsearch Docker image](https://github.com/elastic/elasticsearch-docker)
- [elastic/logstash-docker: Official Logstash Docker image](https://github.com/elastic/logstash-docker)
- [elastic/kibana-docker: Official Kibana Docker image](https://github.com/elastic/kibana-docker)

> nginx

- [logstash通过rsyslog对nginx的日志收集和分析 - 金戈铁马行飞燕 - 51CTO技术博客](http://bbotte.blog.51cto.com/6205307/1615477)
- [ELK+Filebeat 集中式日志解决方案详解](https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html)
- [ELK+Filebeat+Nginx集中式日志解决方案（一） - 郑小明的技术博客 - 51CTO技术博客](http://zhengmingjing.blog.51cto.com/1587142/1907456)
- [examples/ElasticStack_NGINX-json at master · elastic/examples](https://github.com/elastic/examples/tree/master/ElasticStack_NGINX-json) （官网提供的nginx例子）

> filebeat

- [使用Filebeat输送Docker容器的日志 | Tony Bai](http://tonybai.com/2016/03/25/ship-docker-container-log-with-filebeat/)
- [Running Filebeat on Docker | Filebeat Reference [5.4] | Elastic](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html)
- [初探ELK-filebeat使用小结 - 好记性不如烂笔头 - 51CTO技术博客](http://nosmoking.blog.51cto.com/3263888/1853781)
- [Docker使用-v挂载主机目录到容器后出现Permission denied - Amei1314 - 博客园](http://www.cnblogs.com/linux-wangkun/p/5746107.html)

# 6. Prometheus

> alertmanager

- [Monitoring linux stats with Prometheus.io](https://resin.io/blog/monitoring-linux-stats-with-prometheus-io/)
- [Prometheus监控 - Alertmanager报警模块 - y_xiao_的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/y_xiao_/article/details/50818451)
- [promethus监控Ubuntu主机demo](http://blog.leanote.com/post/mozhata/promethus%E7%9B%91%E6%8E%A7Ubuntu%E4%B8%BB%E6%9C%BA)
- [Prometheus with Alertmanager](http://www.songjiayang.com/technical/prometheus-with-alertmanager/)
- [Prometheus Alertmanager with slack receiver ](http://www.songjiayang.com/technical/prometheus-alert-slack-receiver/)
- [How to monitor your system with prometheus](http://www.songjiayang.com/technical/how-to-monitor-your-system-with-prometheus/)
- [Prometheus with hot reload](http://www.songjiayang.com/technical/prometheuswith-hot-reload/)
- [Alert manager fails to send email through smtp server configured with port 465 · Issue #705 · prometheus/alertmanager](https://github.com/prometheus/alertmanager/issues/705)
- [docker - Prometheus Alertmanager - Server Fault](https://serverfault.com/questions/801317/prometheus-alertmanager) （docker run alertmanager）
- [blts/latency.rules at master · jaqx0r/blts](https://github.com/jaqx0r/blts/blob/master/prom/latency.rules)（提供recording rules的例子）
- [Monitoring Docker Services with Prometheus - CenturyLink Cloud Developer Center](https://www.ctl.io/developers/blog/post/monitoring-docker-services-with-prometheus/)
- [Recording rules | Prometheus https://prometheus.io/docs/practices/rules/](https://prometheus.io/docs/practices/rules/)
- [Recording rules | Prometheus https://prometheus.io/docs/querying/rules/](https://prometheus.io/docs/querying/rules/)
- [IT运维利用Slack 传送手机报警讯息-搜狐](http://mt.sohu.com/20161111/n472932125.shtml)
- [Bringing the light of monitoring with Prometheus](http://trustmeiamadeveloper.com/2016/07/03/bringing-the-light-of-monitoring-with-prometheus/)
- [can prometheus get multi values in rules file? · Issue #2496 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/2496)
- [Prometheus: A practical guide to alerting at scale (Monitorama 2015) - Google 幻灯片](https://docs.google.com/presentation/d/1X1rKozAUuF2MVc1YXElFWq9wkcWv3Axdldl8LOH9Vik/edit#slide=id.gb421125b5_0_15)
- [jaqx0r/blts: Better Living Through Statistics: Monitoring Doesn't Have To Suck](https://github.com/jaqx0r/blts)
- [Combining alert conditions | Robust Perception](https://www.robustperception.io/combining-alert-conditions/)
- [Booleans, logic and math | Robust Perception](https://www.robustperception.io/booleans-logic-and-math/)

> alert template

- [Grabbing host URL of Prometheus from within ALERT summary/description - Google 网上论坛](https://groups.google.com/forum/#!searchin/prometheus-users/printf$20alert|sort:relevance/prometheus-users/kKvVNwE-JSc/3Cf4UKMMBgAJ)
- [Little help with an error happening while expanding alert template - Google 网上论坛](https://groups.google.com/forum/#!searchin/prometheus-users/printf$20alert|sort:relevance/prometheus-users/th2zEaM0R_I/wRNJXvgeBgAJ)
- [Notification template reference | Prometheus](https://prometheus.io/docs/alerting/notifications/)
- [Template examples | Prometheus](https://prometheus.io/docs/visualization/template_examples/)
- [Console templates | Prometheus](https://prometheus.io/docs/visualization/consoles/)
- [Custom Alertmanager Templates | Prometheus](https://prometheus.io/blog/2016/03/03/custom-alertmanager-templates/)
- [prometheus - Using alert annotations in an alertmanager receiver - Stack Overflow](https://stackoverflow.com/questions/39389463/using-alert-annotations-in-an-alertmanager-receiver)
- [go - Prometheus email alert to show metric value - Stack Overflow](https://stackoverflow.com/questions/43473473/prometheus-email-alert-to-show-metric-value)
- [how to add custom email template? · Issue #259 · prometheus/alertmanager](https://github.com/prometheus/alertmanager/issues/259)

> docuement

- [1046102779/prometheus](https://github.com/1046102779/prometheus): Prometheus官网的非官方中文手册，旨在为大家提供一个比较容易入手的文档。翻译得不好，请大家多多包涵，并帮忙修订校正

> black_box

- [Checking if SSH is responding with Prometheus | Robust Perception](https://www.robustperception.io/checking-if-ssh-is-responding-with-prometheus/)

> client_golang

- [go - How to push metrics to prometheus using client_golang? - Stack Overflow](http://stackoverflow.com/questions/37611754/how-to-push-metrics-to-prometheus-using-client-golang)

> config

- [when -web.route-prefix is set, resource and nav links are not prefixed · Issue #2193 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/2193)
- [monitoringartist/play.monitoringartist.com](https://github.com/monitoringartist/play.monitoringartist.com)

> ferderate

- [Scaling and Federating Prometheus | Robust Perception](https://www.robustperception.io/scaling-and-federating-prometheus/)

> function

- [Irate graphs are better graphs | Robust Perception](https://www.robustperception.io/irate-graphs-are-better-graphs/)
- [prometheus/functions.md at master · 1046102779/prometheus](https://github.com/1046102779/prometheus/blob/master/querying/functions.md) （irate vs rate）

> kubernetes_sd_configs

- [After deploy prometheus, it shows x509: certificate is valid for apiserver, not kubernetes.default.svc · Issue #2088 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/2088)
- [prometheus/prometheus-kubernetes.yml at master · prometheus/prometheus](https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml)
- [Switch kubelet scraping to http and port 10255 · Issue #2613 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/2613)

> kafka

- [Monitoring Kafka with Prometheus | Robust Perception](https://www.robustperception.io/monitoring-kafka-with-prometheus/)

> mysql

- [采用prometheus 监控mysql - HF_Cherish - 博客园](http://www.cnblogs.com/hf-cherish/p/6016374.html)

> Prometheus

- [prometheus/kubernetes_bearertoken_basicauth.bad.yml](https://github.com/prometheus/prometheus/blob/master/config/testdata/kubernetes_bearertoken_basicauth.bad.yml)
- [使用Prometheus监控kubernetes(k8s)集群 | 程序印象](http://www.do1618.com/archives/595)
- [Advanced Service Discovery in Prometheus 0.14.0 | Prometheus](https://prometheus.io/blog/2015/06/01/advanced-service-discovery/)
- [Providing an API to configure configuration · Issue #1623 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/1623)
- [Error opening memory series storage · Issue #1600 · prometheus/prometheus](https://github.com/prometheus/prometheus/issues/1600)

> python

- [Prometheus query results as CSV | Robust Perception](https://www.robustperception.io/prometheus-query-results-as-csv/)

> query

- [Prometheus监控 - 查询表达式篇 - y_xiao_的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/y_xiao_/article/details/50820225)

> storage

- [[ 翻译 ] 从头编写一款时间序列数据库](http://devopstarter.info/translate-writing-a-time-series-database-from-scratch/)
- [Prometheus的架构及持久化 - davygeek - 博客园](http://www.cnblogs.com/davygeek/p/6668706.html)

> TLS

- [OpenSSL命令---s_client - VitalityShow(网络通讯) - 博客频道 - CSDN.NET](http://blog.csdn.net/as3luyuan123/article/details/16812071)
- [Configuration <tls_config>| Prometheus](https://prometheus.io/docs/operating/configuration/#<tls_config>)
- [x509: certificate signed by unknown authority · Issue #1528 · kubernetes/kubernetes](https://github.com/kubernetes/kubernetes/issues/1528)
- [OpenSSL s_server / s_client 应用实例-博客-云栖社区-阿里云](https://yq.aliyun.com/articles/44400)
- [应用 openssl 工具进行 SSL 故障分析](https://www.ibm.com/developerworks/cn/linux/l-cn-sclient/)
- [【原创】k8s源码分析-----EndpointController - 月牙寂 - 博客频道 - CSDN.NET](http://blog.csdn.net/screscent/article/details/51016335?locationNum=11&fps=1)

> windows

- [martinlindhe/wmi_exporter](https://github.com/martinlindhe/wmi_exporter): Prometheus exporter for Windows machines using WMI

# 7. git

## 7.1 git

## 7.2 gitlab

## 7.3 gogs

1. [故障排查](https://gogs.io/docs/intro/troubleshooting)
2. [GOGS代码仓库迁移教程](https://blog.csdn.net/asukasmallriver/article/details/78614699)

# 8. redis

1. http://redisdoc.com/
2. http://www.redis.net.cn/

# 9. Pinpoint

> log

1. https://naver.github.io/pinpoint/perrequestfeatureguide.html

# 10. nginx

1. [配置nginx为UDP反向代理服务](https://blog.csdn.net/russell_tao/article/details/80001907)

# 11. kong

1. [微服务网关解决方案调研和使用总结](https://www.cnblogs.com/softidea/p/7261095.html)
2. [专栏：kong初探 - CSDN博客 ](https://blog.csdn.net/column/details/18049.html)
3. https://github.com/Kong/kong
4. https://konghq.com/kong-community-edition/
5. https://getkong.org
6. https://github.com/PGBI/kong-dashboard
7. https://docs.konghq.com/hub/ （插件）