# Filebeat简介

反压力敏感协议，Ingest Node

-----

- [Filebeat: Lightweight Log Analysis & Elasticsearch | Elastic ](https://www.elastic.co/products/beats/filebeat)

# 轻量级的日志传输工具
当有数万、数百甚至数千台服务器、虚拟机和生成日志的容器时，忘记使用SSH吧。Filebeat可以通过提供一种轻量级的方式来转发和集中日志和文件，帮助你把简单的事情简单化。

# 健壮，从没错过任何一个细节(Doesn't Miss a Beat)
在任何环境中，应用程序停机总是时不时的停机。在读取和转发日志行的过程中，如果被中断，Filebeat会记录中断的位置。并且，当重新联机时，Filebeat会从中断的位置开始。

# Filebeat使简单的事情保持简单
Filebeat附带了内部模块(auditd、Apache、Nginx、System和MySQL)，这些模块简化了普通日志格式的聚集、解析和可视化。结合使用基于操作系统的自动默认设置，使用Elasticsearch Ingest Node的管道定义，以及Kibana仪表盘来实现这一点。

# 它不会让你超负荷工作
当发送数据到Logstash或Elasticsearch时，Filebeat使用一个`反压力敏感(backpressure-sensitive)`的协议来解释高负荷的数据量。当Logstash数据处理繁忙时，Filebeat放慢它的读取速度。一旦压力解除，Filebeat将恢复到原来的速度，继续传输数据。

<!-- ![](img/filebeat-diagram.png) -->
![](https://static-www.elastic.co/assets/blt203883a0718cdc5a/filebeat-diagram.png?q=540)

# 传输数据到Elasticsearch或者Logstash。在Kibana中可视化。
Filebeat是Elastic Stack的一部分，这意味着它可以无缝地与Logstash、Elasticsearch和Kibana结合。无论你是想要配合Logstash转换日志和文件，还是在Elasticsearch中使用一些分析，或者在Kibana中构建和共享仪表板，Filebeat都可以轻松地将数据发送到你最关注的位置。

# Ingest Node

- [Ingest Node | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html)

在实际的索引发生之前，可以将ingest节点用于预处理文档。这种预处理发生在一个ingest节点，该节点拦截批量和索引请求，应用转换，然后将文档传递回索引或批量api。

可以在任何节点上启用ingest，甚至配置节点专门做ingest。节点默认启用Ingest。想在节点上禁用ingest，可以在elasticsearch.yml文件中中设置:
```yml
node.ingest: false
```
在索引之前对预处理文档进行定义，定义了指定一系列处理器的管道。每个进程以某种方式转换文档。例如，可能有一条由一个进程组成的管道，它从文档中删除一个字段，然后再由另一个进程重命名一个字段。

要使用管道，只需在索引或批量请求中指定管道参数，告诉正在使用管道的ingest节点。例如:

```bash
curl -XPUT 'localhost:9200/my-index/my-type/my-id?pipeline=my_pipeline_id&pretty' -H 'Content-Type: application/json' -d'
{
  "foo": "bar"
}
'
```