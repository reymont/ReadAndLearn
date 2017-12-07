

Docker日志收集新方案：fluentd-pilot-博客-云栖社区-阿里云
 https://yq.aliyun.com/articles/69382

今天，我们将隆重介绍一款新的docker日志收集工具：fluentd-pilot Github项目地址：https://github.com/AliyunContainerService/fluentd-pilot 你可以在每台机器上部署一个fluentd-pilot实例，就可以收集机器上所有Docker应用日志。fluentd-pilot具有如下特性

* 一个单独fluentd进程，收集机器上所有容器的日志。不需要为每个容器启动一个fluentd进程
* 支持文件日志和stdout。docker log dirver亦或logspout只能处理stdout，fluentd-pilot不光支持收集stdout日志，还可以收集文件日志。
* 声明式配置。当你的容器有日志要收集，只要通过label声明要收集的日志文件的路径，无需改动其他任何配置，fluentd-pilot就会自动收集新容器的日志。
* 支持多种日志存储方式。无论是强大的阿里云日志服务，还是比较流行的elasticsearch组合，甚至是graylog，fluentd-pilot都能把日志投递到正确的地点。
* 开源。fluentd-pilot完全开源，代码在这里。如果现有的功能不满足你的需要，欢迎提issue，如果能贡献代码就更好了。

## 快速启动

下面我们先演示一个最简单的场景：我们先启动一个fluentd-pilot，再启动一个tomcat容器，让fluentd-pilot收集tomcat的日志。为了简单起见，这里先不涉及sls或者elk，如果你想在本地玩玩，只需要有一台运行docker的机器就可以了。

首先启动fluentd-pilot。要注意的是，以这种方式启动，由于没有配置后端使用的日志存储，所有收集到的日志都会直接输出到控制台，所以主要用于调试。

打开终端，输入命令：

docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host \
    registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:0.1


你会看到fluentd-pilot启动的日志。别关终端。新开一个终端启动tomcat。tomcat镜像属于少数同时使用了stdout和文件日志的docker镜像，非常适合这里的演示。

docker run -it --rm  -p 10080:8080 \
-v /usr/local/tomcat/logs \
--label aliyun.logs.catalina=stdout \
--label aliyun.logs.access=/usr/local/tomcat/logs/localhost_access_log.*.txt \
tomcat

先解释下这里的配置。

* aliyun.logs.catalina=stdout告诉fluentd-pilot这个容器要收集stdout日志，
* aliyun.logs.access=/usr/local/tomcat/logs/localhost_access_log.*.txt则表示要收集容器内/usr/local/tomcat/logs/目录下所有名字匹配localhost_access_log.*.txt的文件日志。

后面会详细介绍label的用法。

如果你在本地部署tomcat，而不是在阿里云容器服务上，-v /usr/local/tomcat/logs也需要，否则fluentd-pilot没法读取到日志文件。容器服务自动做了优化，不需自己加-v了。

fluentd-pilot会监控Docker容器事件，发现带有aliyun.logs.xxx容器的时候，自动解析容器配置，并且开始收集对应的日志。启动tomcat之后，你会发现fluentd-pilot的终端立即输出了一大堆的内容，其中包含tomcat启动时输出的stdout日志，也包括fluentd-pilot自己输出的一些调试信息。

Screen_Shot_2017_02_08_at_10_27_59_PM
你可以打开浏览器访问刚刚部署的tomcat，你会发现每次刷新浏览器，在fluentd-pilot的终端里都能看到类似如下的记录。其中message后面的内容就是从/usr/local/tomcat/logs/localhost_access_log.XXX.txt里收集到的日志。

## 使用Elasticsearch+Kibana

首先我们要部署一套Elastichsearch+Kibana，前面的文章里介绍过如何在阿里云容器服务里部署ELK，你可以参照文章在容器服务上直接部署，或者按照Elasticsearch/Kibana的文档直接在机器上部署，这里不再赘述。假设已经部署好了这两个组件。

如果你还在运行刚才启动的fluentd-pilot，先关掉，使用下面的命令启动，执行之前，注意先把ELASTICSEARCH_HOST 和ELASTICSEARCH_PORT两个变量替换成你实际使用的值。ELASTICSEARCH_PORT一般是9200

docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host \
    -e FLUENTD_OUTPUT=elasticsearch \
    -e ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST} \
    -e ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT}
    registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:0.1
相比前面启动fluentd-pilot的方式，这里增加了三个环境变量：

FLUENTD_OUTPUT=elasticsearch: 把日志发送到elasticsearch
ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST}: elasticsearch的域名
ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT}: elasticsearch的端口号
继续运行前面的tomcat，再次访问，让tomcat产生一些日志，所有这些新产生的日志都讲发送到elasticsearch里。打开kibana，这时候你应该还看不到新日志，需要先创建index。fluentd-pilot会把日志写到elasticsearch特定的index下，规则如下

1. 如果应用上使用了标签aliyun.logs.tags，并且tags里包含target，使用target作为elasticsearch里的index，否则
2. 使用标签aliyun.logs.XXX里的XXX作为index
在前面tomcat里的例子里，没有使用aliyun.logs.tags标签，所以默认使用了access和catalina作为index。我们先创建index access

Screen_Shot_2017_02_09_at_8_08_23_PM

创建好index就可以查看日志了。

Screen_Shot_2017_02_09_at_8_09_01_PM

在阿里云容器服务里使用fluentd-pilot

容器服务是最适合fluentd-pilot运行的地方，专门为fluentd-pilot做了优化。要在容器服务里运行fluentd-pilot，你需要做的仅仅是使用下面的编排文件创建一个新应用。

pilot:
  image: registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:0.1
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /:/host
  environment:
    FLUENTD_OUTPUT: elasticsearch #按照你的需要替换 
    ELASTICSEARCH_HOST: ${elasticsearch} #按照你的需要替换
    ELASTICSEARCH_PORT: 9200
  labels:
    aliyun.global: true
接下来，你就可以在要收集日志的应用上使用aliyun.logs.xxx标签了。

## Label说明

启动tomcat的时候，我们声明了这样下面两个，告诉fluentd-pilot这个容器的日志位置。

--label aliyun.logs.catalina=stdout 
--label aliyun.logs.access=/usr/local/tomcat/logs/localhost_access_log.*.txt 
你还可以在应用容器上添加更多的标签

aliyun.logs.$name = $path

变量name是日志名称，具体指随便是什么，你高兴就好。只能包含0-9a-zA-Z_和-
变量path是要收集的日志路径，必须具体到文件，不能只写目录。文件名部分可以使用通配符。/var/log/he.log和/var/log/*.log都是正确的值，但/var/log不行，不能只写到目录。stdout是一个特殊值，表示标准输出
aliyun.logs.$name.format，日志格式，目前支持

none 无格式纯文本
json: json格式，每行一个完整的json字符串
csv: csv格式
aliyun.logs.$name.tags: 上报日志的时候，额外增加的字段，格式为k1=v1,k2=v2，每个key-value之间使用逗号分隔，例如

aliyun.logs.access.tags="name=hello,stage=test"，上报到存储的日志里就会出现name字段和stage字段
如果使用elasticsearch作为日志存储，target这个tag具有特殊含义，表示elasticsearch里对应的index
扩展fluentd-pilot

对于大部分用户来说，fluentd-pilot现有功能足以满足需求，如果遇到没法满足的场景怎么办？

到 https://github.com/AliyunContainerService/fluentd-pilot/issues 提交issue
直接改代码，再提pr
地址