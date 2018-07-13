

使用ELK处理Docker日志(一)_搜狐科技_搜狐网 
http://www.sohu.com/a/136519920_332175

容器运行程序时产生的日志具有“无常，分布，隔离”等特点，因此在架构中收集Docker日志面临很大的挑战，有待尝试一种强有力的日志收集和处理方案来解决此类复杂问题。
ELK （Elasticsearch，Logstash和Kibana）是处理容器日志的一种方式，尽管设置ELK工作流并不容易（难度取决于环境规格），但最终可以使用Kibana的监控面板来展示Docker日志:
.
为了纪念Docker四岁生日，我们将撰写一系列文章，介绍如何使用ELK收集和处理Dockerized环境日志。第一部分将介绍如何安装各个组件以及不同日志收集方案的特点，并建立从容器中收集日志的工作流，下一部分将侧重于分析和可视化。
日志收集的流程
Dockerized环境中的典型ELK日志收集流程如下所示：
* Logstash负责从各种Docker容器和主机中提取日志，这个流程的主要优点是可以更好地用过滤器来解析日志，
* Logstash将日志转发到Elasticsearch进行索引，
* Kibana分析和可视化数据。

当然这个流程可以有多种不同的实现方式， 例如可以使用不同的日志收集和转发组件, 如Fluentd或Filebeat 将日志发送到Elasticsearch，
或者，添加一个由Kafka或Redis容器组成的中间层，作为Logstash和Elasticsearch之间的缓冲区。

那么，如何设置这个流程呢？
组件安装
可以将ELK套件安装在一个容器里，也可以使用不同的容器来分别安装各个组件。
关于在Docker上部署ELK是否是生产环境的可行性解决方案（资源消耗和网络是主要问题）仍然存在很多争议，但在开发中这是一种非常方便高效的方案。
ELK的docker镜像推荐使用 docker-elk， 它支持丰富的运行参数(可使用这些参数组合不同的版本)和文档, 
而且完全支持最新版本的 Elasticsearch, Logstash, 和 Kibana.

在安装组件之前需要确保以下端口没有被占用:5601 (Kibana), 9200 (Elasticsearch), and 5044 (Logstash).
同时需要确保内核参数 vmmaxmap_count 至少设置为262144:
sudo sysctl -w vm.max_map_count=262144
运行如下命令:

git clone https://github.com/deviantony/docker-elk.git 
cd docker-elk docker-compose up
正常情况下, ELK套件的三个服务(Elasticsearch, Logstash, Kibana)会启动成功，默认持久化数据目录 /var/lib/elasticsearch (Elasticsearch 的数据存储目录)
sudo docker ps 
CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES 
73aedc3939ad dockerelk_kibana "/bin/sh -c /usr/l..." 7 minutes ago Up 6 minutes 0.0.0.0:5601->5601/tcp dockerelk_kibana_1 b684045be3d6 dockerelk_logstash "logstash -f /usr/..." 7 minutes ago Up 6 minutes 0.0.0.0:5000->5000/tcp dockerelk_logstash_1 a5778b8e4e6a dockerelk_elasticsearch "/bin/bash bin/es-..." 7 minutes ago Up 7 minutes 0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp dockerelk_elasticsearch_1 测试安装组件
可通过如下的方式来确保所有组件都能正常运行。

首先尝试访问Elasticsearch运行如下命令:
curl localhost:9200
输出结果:
{ "name" : "W3NuLnv", "cluster_name" : "docker-cluster", "cluster_uuid" : "fauVIbHoSE2SlN_nDzxxdA", "version" : { "number" : "5.2.1", "build_hash" : "db0d481", "build_date" : "2017-02-09T22:05:32.386Z", "build_snapshot" : false, "lucene_version" : "6.4.1" }, "tagline" : "You Know, for Search" }

打开 Kibaba 页面通过http://[serverIP]:5601:
值得注意的是需要输入索引模式才能正常进行后续处理,这个稍后将会介绍。

# 发送Docker日志到ELK

安装组件比较简单，相比而言将Docker日志发送到ELK有点复杂，这取决于输出日志的方式。
如果没有额外指定，容器的stdout和stderr输出（也称为“docker logs”）输出到JSON文件。
所以，如果是一个小型Docker环境，使用Filebeat来收集日志将是不错的选择。但如果使用其他日志记录驱动程序，则可能需要考虑其他方法。

以下是将日志导入ELK的三种不同的方法，切记，这并不能包含所有的方案。

## 使用Filebeat
Filebeat属于Elastic的Beats系列日志收集组件， Filebeat是用Go语言开发的,支持追踪特定文件和日志加密的中间组件,它可以配置将日志导出到Logstash或者直接导出到Elasticsearch.
如上所述，若使用默认的json文件记录驱动程序，Filebeat是一种相对简便的方式，可以输出日志到ELK.Filebeat部署在主机上，或将其作为容器与ELK容器一起运行（在这种情况下，需要添加到ELK容器的链接），这里有各种Filebeat Docker images可用，有些包括运行Filebeat并将其连接到Logstash的配置。
Filebeat配置将需要指定JSON日志文件的路径（位于：/ var / lib / docker / containers / ...）和目标的详细信息（通常是Logstash容器）。
下面是一个配置的例子
prospectors: - paths: - /var/log/containers/<xxx> document_type: syslog output: logstash: enabled: true hosts: - elk:5044 使用日志驱动
Docker从1.12开始支持Logging Driver，允许将Docker日志路由到指定的第三方日志转发层，可将日志转发到AWS CloudWatch，Fluentd，GELF或NAT服务器。
使用logging drivers比较简单，它们需要为每个容器指定，并且将需要在日志的接收端进行其他配置。
在将日志发送到ELK的上下文中，使用syslog日志驱动可能是最简单的方法。
下面是一个指定Logging Driver的例子:
docker run \ --log-driver=syslog \ --log-opt syslog-address=tcp://<SyslogServerIP>:5000 \ --log-opt syslog-facility=daemon \ alpine ash
如此这样运行每一个容器，结果是将Docker容器日志流输出到syslog实例，这些日志将转发到Logstash容器进行解析和数据增强，进入Elasticsearch。

## 使用Logspout

Logspout是Docker流行和轻量级的（15.2MB）日志路由器，它将附加到主机中的所有容器，并将Docker日志流输出到syslog服务器（除非定义了不同的输出目标）。
sudo docker run -d --name="logspout" --volume=/var/run/docker.sock:/var/run/docker.sock gliderlabs/logspout syslog+tls://<syslogServerIP>:5000

使用Logstash module直接将日志路由到Logstash容器，但这需要其他配置和编译工作。

## Logz.io的日志采集器
本人在 In this blog post这篇文章中介绍了Logz.io的日志采集器，像Logspout一样，它附加在Docker主机中的所有容器上，但它不仅运送Docker日志，还包含Docker统计信息和Docker守护程序事件。
docker run -d --restart=always -v /var/run/docker.sock:/var/run/docker.sock logzio/logzio-docker -t <YourLogz.ioToken>
目前它是为Logz.io ELK 套件的用户设计的，我们正在努力将它开源项目。

## 数据持久化
配置Logstash来解析数据至关重要，因为这部分过程将添加上下文到容器的日志中，并能够更轻松地分析数据。
在Logstash配置文件中需要配置三个主要部分：输入，过滤和输出。 （若运行的是Logstash 5.x，则该文件位于：/ usr / share / logstash / pipeline）
输入取决于日志传送方式，使用Filebeat，则需要指定Beats输入插件。如果使用logspout或syslog日志记录驱动程序，则需要将syslog定义为输入。
过滤器部分包含用于分解日志消息的所有过滤器插件，依赖于正在记录的容器类型以及该特定容器生成的日志消息。
这部分的配置没有捷径，因为每个容器都输出不同类型的日志。有很多尝试和错误涉及，但是有一些在线工具可参考, 比如:Grok Debugger。
导出部分将指定Logstash输出，例子中是Elasticsearch容器。

以下是通过syslog发送的Docker日志的基本Logstash配置示例。注意一系列过滤器的使用（grok，date，mutate和if条件）：
input { syslog { port => 5000 type => "docker" } } filter { grok { match => { "message" => "%{SYSLOG5424PRI}%{NONNEGINT:ver} +(?:%{TIMESTAMP_ISO8601:ts}|-) +(?:%{HOSTNAME:service}|-) +(?:%{NOTSPACE:containerName}|-) +(?:%{NOTSPACE:proc}|-) +(?:%{WORD:msgid}|-) +(?:%{SYSLOG5424SD:sd}|-|) +%{GREEDYDATA:msg}" } } syslog_pri { } date { match => [ "syslog_timestamp", "MMM d HH:mm:ss", "MMM dd HH:mm:ss" ] } mutate { remove_field => [ "message", "priority", "ts", "severity", "facility", "facility_label", "severity_label", "syslog5424_pri", "proc", "syslog_severity_code", "syslog_facility_code", "syslog_facility", "syslog_severity", "syslog_hostname", "syslog_message", "syslog_timestamp", "ver" ] } mutate { remove_tag => [ "_grokparsefailure_sysloginput" ] } mutate { gsub => [ "service", "[0123456789-]", "" ] } if [msg] =~ "^ *{" { json { source => "msg" } if "_jsonparsefailure" in [tags] { drop {} } mutate { remove_field => [ "msg" ] } } } output { elasticsearch { hosts => "elasticsearch:9200" } }
重新启动Logstash容器以应用新的配置。检查Elasticsearch索引,确保日志流能正常工作：
curl 'localhost:9200/_cat/indices?v'
具有Logstash模式的索引：
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size yellow open logstash-2017.03.05 kgJ0P6jmQjOLNTSmnxsZWQ 5 1 3 0 10.1kb 10.1kb yellow open .kibana 09NHQ-TnQQmRBnVE2Y93Kw 1 1 1 0 3.2kb 3.2kb

打开Kibana的页面
Kibana已经创建了'logstash- *' 索引是标识，按下“创建”按钮，可在Kibana中看到日志。

# 结语

Docker日志记录没有完美的方案，无论选择什么解决方案，使用日志记录驱动程序，Filebeat还是SaaS监控平台，每个方案都有优缺点。
值得一提的是，Docker日志很有用，但它们只代表由Docker主机生成的数据的一个维度，检索容器统计信息和守护程序事件等还需要额外的日志记录层。
综上所述，Logz.io日志收集器提供了一个全面的日志解决方案，将三个数据流一起拉到ELK中。如需统计数据，建议尝试一下Dockerbeat.
本系列的下一部分将重点介绍如何在Kibana中分析和可视化Docker日志。

Docker 生日快乐!
Daniel Berman是Logz.io产品经理。擅长日志分析、大数据、云计算,热爱家庭,喜欢跑步,Liverpool FC和写颠覆性的技术内容。
原文链接：https://logz.io/blog/docker-logging