

# http://www.imekaku.com/2016/09/26/fluentd-conclusion/

fluentd是一个非常优秀的日志收集工具，这里我主要用它来收集docker-swarm集群的各个容器的日志。
fluentd使用插件：
用于路径中加入tag：fluent-plugin-forest
用于修改record：fluent-plugin-record-reformer
用于修改tag：fluent-plugin-rewrite-tag-filter
用于正则匹配日志内容，进行筛选：fluent-plugin-grep
```Shell
# 客户端需要安装的插件
/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-rewrite-tag-filter
/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-grep
/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-record-reformer
 
# 服务器端需要安装的插件
/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-forest
```

# fluentd安装-基本文件路径-插件安装

fluentd-安装：http://www.imekaku.com/2016/09/05/fluentd-install/

安装完成后，需要先去官网了解其基本的使用方法，使用实例等等。
fluentd配置文件所在目录：/etc/td-agent/
fluentd二进制文件所在目录：/opt/td-agent/embedded/bin/
安装插件的方法：/opt/td-agent/embedded/bin/fluent-gem install [插件名称]
docker中log-driver使用fluentd
Docker日志使用Fluentd收集：http://www.imekaku.com/2016/09/08/docker-log-fluentd/

需要注意：log-drive的几个选项，特别是异步的选项，因为如果没有设置为异步，fluentd挂了，容器就挂了。

# fluentd的client-server模式收集日志

如果每台宿主机上的fluentd收集容器的日志之后，存放在本地，那么仍然不便于日志的归纳整理。
Fluentd 配置文件-client fluentd 到 server fluentd：http://www.imekaku.com/2016/09/14/fluentd-configure-client-server/

在这篇文章中，对docker的log-driver的几个选项也有了一个比较详细的介绍。

初步建立了一个client到server的高可用模型。

# fluentd输出

fluentd服务器端收集日志，放在指定的目录
Fluentd 服务器log aggregators根据tag输出到指定路径：http://www.imekaku.com/2016/09/14/fluentd-log-aggregators-tag-path/

收集到的日志希望按照不同的类别，放在不同的目录

## 区别docker的stdout和stderr来源，从而放在不同的路径
Fluentd将Docker log中stdout和stderr分开：http://www.imekaku.com/2016/09/18/fluentd-docker-log-stdout-stderr/

从docker容器中收集的日志，主要有两个来源，分别是stdout和stderr，希望能够区分它们，并且把它们输出到指定目录

## 从fluentd输出的日志文件中提取单个字段
Fluentd提取发送日志中的value-SingleValue：http://www.imekaku.com/2016/09/18/fluentd-remove-time-tag-to-only-value/

从docker容器中提取出来的日志，无论是从stdout中或者是stderr中的日志，fluentd都会放在日志的log字段（fluentd的日志是json格式），所以如果希望提取log字段的信息，从而去除日志中的其他信息的话，可以使用这种方式。

## 根据日志的不同来放在不同的路径
Fluentd使用正则匹配log内容，输出到不同的存储介质：http://www.imekaku.com/2016/09/20/fluentd-regexp-log-output-different-disk/

由于日志的内容可能会比较多，可能会希望过滤掉一些日志，或者根据日志内容的不同，放在不同的目录。

## 在fluentd日志输出的路径，或者文件名中加上时间
Fluentd在输出日志的路径中加入时间：http://www.imekaku.com/2016/09/26/fluentd-put-time-in-path/

在fluentd的输出日志文件名是有时间的，是根据time_slice_format来分割的，但是往往会希望在路径中也加入时间，从而根据路径筛选出不同的日志，避免大量的日志产生干扰。或者希望日志的文件前面加上日志，这样可以根据时间进行排序。

## fluentd日志文件的命令规则
Fluentd输出日志文件命名规则：http://www.imekaku.com/2016/09/21/fluentd-log-filename/

fluentd日志的命令规则主要是根据time_sllice_format设置选项来切割的。如果需要设置5分钟，3分钟一次输出，就需要设置flush_interval选项的时间。或者设置chunk的大小。

# docker缓冲区-fluentd缓冲区

Docker-log-driver缓冲区&Fluentd out_file, out_forward缓冲区：http://www.imekaku.com/2016/09/19/docker-log-driver-buff-fluentd-buff/

当客户端fluentd挂了的时候，docker容器会打在自己的缓冲区；

当服务器端fluentd挂了的时候，fluentd客户端会首先找负载均衡的另一个节点，或者找二级节点，或者找助手节点，如果都挂了，fluentd客户端会将日志打在自己的缓冲区。

这篇文章就讲了docker的缓冲区和fluentd的缓冲区。

# fluentd自己的日志输出

fluentd自己的日志：http://www.imekaku.com/2016/09/23/fluentd-own-log/

# swarm集群中使用fluentd

Docker Swarm使用fluentd收集日志：http://www.imekaku.com/2016/09/19/docker-swarm-fluentd/

Docker Swarm集群使用fluentd收集日志：http://www.imekaku.com/2016/09/22/docker-swarm-clusters-fluentd-collect-log/

使用fluentd主要的目的也是希望能够收集swarm集群中的日志。swarm中使用fluentd和直接使用docker run创建容器收集日志的选项是相同的。

# fluentd配置文件测试和配置文件常用方案

Fluentd日志输出测试-配置文件：http://www.imekaku.com/2016/09/19/fluentd-log-test01/

Fluentd常用配置文件方案：http://www.imekaku.com/2016/09/23/fluentd-configuration-always/

转载请注明：Imekaku-Blog » 日志收集工具Fluentd使用总结