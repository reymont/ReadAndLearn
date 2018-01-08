

360基于Prometheus的在线服务监控实践 - PaaS云 - DBAplus社群——围绕数据库、大数据、PaaS云，运维圈最专注围绕“数据”的学习交流和专业社群 http://dbaplus.cn/news-72-1462-1.html

本文根据DBAplus社群第116期线上分享整理而成。
 
讲师介绍  

赵鹏
奇虎360运维开发工程师
 
 
目前负责平台基础服务开发和研究工作，在工作中通过使用Prometheus，完成基础服务的复杂监控需求；
曾参与HULK私有云平台基础服务的建设和实施，对OpenStack、Docker、Ceph等领域均有研究。
 
主题简介：
Prometheus基础介绍
Prometheus打点及查询技巧
Prometheus高可用和服务发现经验
 
初衷
   
 
最近参与的几个项目，无一例外对监控都有极强的要求，需要对项目中各组件进行详细监控，如服务端API的请求次数、响应时间、到达率、接口错误率、分布式存储中的集群IOPS、节点在线情况、偏移量等。
 
比较常见的方式是写日志，将日志采集到远端进行分析和绘图，或写好本地监控脚本进行数据采集后，通过监控系统客户端push到监控系统中进行打点。基本上我们需要的都能覆盖，但仍然有一些问题在使用上不太舒服，如在大规模请求下日志采集和分析的效率比较难控制，或push打点的粒度和纬度以及查询不够灵活等。
 
后来在同事对《Google SRE》这本书中的一些运维思想进行一番安利后，抱着试一试的态度，开始尝试使用Prometheus做为几个项目的监控解决方案。
 
Prometheus的特点
   
 
多维数据模型（时序数据由 metric 名和一组K/V标签构成）。
灵活强大的查询语句（PromQL）。
不依赖存储，支持local和remote(OpenTSDB、InfluxDB等)不同模型。
采用 HTTP协议，使用Pull模式采集数据。
监控目标，可以采用服务发现或静态配置的方式。
支持多种统计数据模型，图形化友好(Grafana)。
 
数据类型
   
 

 
Counter
 
`Counter表示收集的数据是按照某个趋势（增加／减少）一直变化的。`
 

 
Gauge
 
`Gauge表示搜集的数据是瞬时的，可以任意变高变低。`
 

 
Histogram
 
Histogram可以理解为直方图，主要用于表示一段时间范围内对数据进行采样，（通常是请求持续时间或响应大小），并能够对其指定区间以及总数进行统计。
 

 
Summary
 
Summary和Histogram十分相似，主要用于表示一段时间范围内对数据进行采样，（通常是请求持续时间或响应大小），它直接存储了 quantile 数据，而不是根据统计区间计算出来的。
 
在我们的使用场景中，大部分监控使用Counter来记录，例如接口请求次数、消息队列数量、重试操作次数等。比较推荐多使用Counter类型采集，因为Counter类型不会在两次采集间隔中间丢失信息。
 
一小部分使用Gauge，如在线人数、协议流量、包大小等。Gauge模式比较适合记录无规律变化的数据，而且两次采集之间可能会丢失某些数值变化的情况。随着时间周期的粒度变大，丢失关键变化的情况也会增多。
 
还有一小部分使用Histogram和Summary，用于统计平均延迟、请求延迟占比和分布率。另外针对Historgram，不论是打点还是查询对服务器的CPU消耗比较高，通过查询时查询结果的返回耗时会有十分直观的感受。
 
时序数据-打点-查询
   
 
我们知道每条时序数据都是由 metric（指标名称），一个或一组label（标签），以及float64的值组成的。
 
标准格式为 {=,...}
 
例如：
 
rpc_invoke_cnt_c{code="0",method="Session.GenToken",job="Center"} 5
rpc_invoke_cnt_c{code="0",method="Relation.GetUserInfo",job="Center"} 12
rpc_invoke_cnt_c{code="0",method="Message.SendGroupMsg",job="Center"} 12
rpc_invoke_cnt_c{code="4",method="Message.SendGroupMsg",job="Center"} 3
rpc_invoke_cnt_c{code="0",method="Tracker.Tracker.Get",job="Center"} 70
 
这是一组用于统计RPC接口处理次数的监控数据。
 
其中rpc_invoke_cnt_c为指标名称，每条监控数据包含三个标签：code 表示错误码，service表示该指标所属的服务，method表示该指标所属的方法，最后的数字代表监控值。
 
针对这个例子，我们共有四个维度（一个指标名称、三个标签），这样我们便可以利用Prometheus强大的查询语言PromQL进行极为复杂的查询。
 
PromQL
   
 
PromQL(Prometheus Query Language) 是 Prometheus 自己开发的数据查询 DSL 语言，语言表现力非常丰富，支持条件查询、操作符，并且内建了大量内置函，供我们针对监控数据的各种维度进行查询。
 
我们想统计Center组件Router.Logout的频率，可使用如下Query语句：
 
rate(rpc_invoke_cnt_c{method="Relation.GetUserInfo",job="Center"}[1m])
 

 
或者基于方法和错误码统计Center的整体RPC请求错误频率：
 
sum by (method, code)(rate(rpc_invoke_cnt_c{job="Center",code!="0"}[1m]))
 

 
如果我们想统计Center各方法的接口耗时，使用如下Query语句即可：
 
rate(rpc_invoke_time_h_sum{job="Center"}[1m]) / rate(rpc_invoke_time_h_count{job="Center"}[1m])
 

 
更多的内建函数这里不展开介绍了。函数使用方法和介绍可以详细参见官方文档中的介绍：https://Prometheus.io/docs/querying/functions/
 
另外，配合查询，在打点时metric和labal名称的定义也有一定技巧。
 
比如在我们的项目中：
rpc_invoke_cnt_c 表示rpc调用统计
api_req_num_cv 表示httpapi调用统计
msg_queue_cnt_c 表示队列长度统计
 
尽可能使用各服务或者组件通用的名称定义metric然后通过各种lable进行区分。
 
最开始我们的命名方式是这样的，比如我们有三个组件center、gateway、message。RPC调用统计的metric相应的命名成了三个：
center_rpc_invoke_cnt_c
gateway_rpc_invoke_cnt_c
message_rpc_invoke_cnt_c
 
这种命名方式，对于各组件的开发同学可能读起来会比较直观，但是在实际查询过程中，这三个metric相当于三个不同的监控项。
 
例如我们查询基于method统计所有组件RPC请求错误频率，如果我们使用通用名称定义metric名，查询语句是这样的：
 
sum by (method, code) (rate(rpc_invoke_cnt_c{code!="0"}[1m]))
 
但如果我们各个组件各自定义名称的话，这条查询需要写多条。虽然我们可以通过 {__name__=~".*rpc_invoke_cnt_c"} 的方式来规避这个问题，但在实际使用和操作时体验会差很多。
 
例如在Grafana中，如果合理命名相对通用的metric名称，同样一个Dashboard可以套用给多个相同业务，只需简单修改template匹配一下label选择即可。不然针对各个业务不同的metric进行针对性的定制绘图也是一个十分痛苦的过程。
 
同时通过前面的各类查询例子也会发现，我们在使用label时也针对不同的含义进行了区分如 method=GroupJoin|GetUserInfo|PreSignGet|... 来区分调用的函数方法，code=0|1|4|1004|...来区分接口返回值，使查询的分类和结果展示更加方便直观，并且label在Grafana中是可以直接作为变量进行更复杂的模版组合。
 
更多的metric和label相关的技巧可以参考官方文档-https://Prometheus.io/docs/practices/naming/
 
服务发现
   
 
在使用初期，参与的几个项目的Prometheus都是各自独立部署和维护的。其配置也是按照官方文档中的标准配置来操作。机器数量少的时候维护简单，增删机器之后简单reload一下即可。例如：
 

 
但随着服务器量级增长，业务整合到同一组Prometheus时，每次上下线实例都是一个十分痛苦的过程，配置文件庞大，列表过长，修改的过程极其容易眼花导致误操作。所以我们尝试使用了Prometheus的服务发现功能。
 
从配置文档中不难发现Prometheus对服务发现进行了大量的支持，例如大家喜闻乐见的Consul、etcd和K8S。
 
 
 
由于最近参与的几个项目深度使用公司内部的配置管理服务gokeeper，虽然不是Prometheus原生支持，但是通过简单适配也是同样能满足服务发现的需求。我们最终选择通过file_sd_config进行服务发现的配置。
 
file_sd_config 接受json格式的配置文件进行服务发现。每次json文件的内容发生变更，Prometheus会自动刷新target列表，不需要手动触发reload操作。所以针对我们的gokeeper编写了一个小工具，定时到gokeeper中采集服务分类及分类中的服务器列表，并按照file_sd_config的要求生成对应的json格式。
 
下面是一个测试服务生成的json文件样例。
 
 
[
    {
        "targets": [
            "10.10.10.1:65160",
            "10.10.10.2:65160"
        ],
        "labels": {
            "job":"Center",
            "service":"qtest"
        }
    },
    {
        "targets": [
            "10.10.10.3:65110",
            "10.10.10.4:65110"
        ],
        "labels": {
            "job":"Gateway",
            "service":"qtest"
        }
    }
]
 
Prometheus配置文件中将file_sd_configs的路径指向json文件即可。
 
 
-job_name: 'qtest'
    scrape_interval: 5s
    file_sd_configs:
      - files: ['/usr/local/prometheus/qtestgroups/*.json']
 
如果用etcd作为服务发现组件也可以使用此种方式，结合confd配合模版和file_sd_configs可以极大地减少配置维护的复杂度。只需要关注一下Prometheus后台采集任务的分组和在线情况是否符合期望即可。社区比较推崇Consul作为服务发现组件，也有非常直接的内部配置支持。
 
感兴趣的话可以直接参考官方文档进行配置和测试-https://Prometheus.io/docs/operating/configuration/#
 
高可用
   
 
高可用目前暂时没有太好的方案。官方给出的方案可以对数据做Shard，然后通过federation来实现高可用方案，但是边缘节点和Global节点依然是单点，需要自行决定是否每一层都要使用双节点重复采集进行保活。
 
使用方法比较简单，例如我们一个机房有三个Prometheus节点用于Shard，我们希望Global节点采集归档数据用于绘图。首先需要在Shard节点进行一些配置。
 
Prometheus.yml：
 
global:
  external_labels:
  slave: 0 #给每一个节点指定一个编号 三台分别标记为0，1，2
 
rule_files:
  - node_rules/zep.test.rules  #指定rulefile的路径
 
scrape_configs:
  - job_name: myjob
    file_sd_configs:
    - files: ['/usr/local/Prometheus/qtestgroups/*.json']
    relabel_configs:
    - source_labels: [__address__]
      modulus:       3   # 3节点
      target_label:  __tmp_hash
      action:        hashmod
    - source_labels: [__tmp_hash]
      regex:         ^0$ # 表示第一个节点
      action:        keep
 
编辑规则文件：
 
 
node_rules/zep.test.rules：
job:rpc_invoke_cnt:rate:1m=rate(rpc_invoke_cnt_c{code!="0"}[1m])
 
在这里job:rpc_invoke_cnt:rate:1m 将作为metric名，用来存放查询语句的结果。
 
在Global节点Prometheus.yml也需要进行修改。
 
 -job_name: slaves
    honor_labels: true
    scrape_interval: 5s
    metrics_path: /federate
    params:
      match[]:
         - '{__name__=~"job:.*"}'
    static_configs:
      - targets:
         - 10.10.10.150:9090
         - 10.10.10.151:9090
         - 10.10.10.152:9090
 
在这里我们只采集了执行规则后的数据用于绘图，不建议将Shard节点的所有数据采集过来存储再进行查询和报警的操作。这样不但会使Shard节点计算和查询的压力增大（通过HTTP读取原始数据会造成大量IO和网络开销），同时所有数据写入Global节点也会使其很快达到单Prometheus节点的承载能力上限。
 
另外部分敏感报警尽量不要通过global节点触发，毕竟从Shard节点到Global节点传输链路的稳定性会影响数据到达的效率，进而导致报警实效降低。例如服务updown状态，API请求异常这类报警我们都放在s hard节点进行报警。
 
此外我们还编写了一个实验性质的Prometheus Proxy工具，代替Global节点接收查询请求，然后将查询语句拆解，到各shard节点抓取基础数据，然后再在Proxy这里进行Prometheus内建的函数和聚合操作，最后将计算数据抛给查询客户端。这样便可以直接节约掉Global节点和大量存储资源，并且Proxy节点由于不需要存储数据，仅接受请求和计算数据，横向扩展十分方便。
 
当然问题还是有的，由于每次查询Proxy到shard节点拉取的都是未经计算的原始数据，当查询的metric数据量比较大时，网络和磁盘IO开销巨大。因此在绘图时我们对查询语句限制比较严格，基本不允许进行无label限制的模糊查询。
 
报警
   
 
Prometheus的报警功能目前来看相对计较简单。主要是利用Alertmanager这个组件。已经实现了报警组分类，按标签内容发送不同报警组、报警合并、报警静音等基础功能。配合rules_file中编辑的查询触发条件，Prometheus会主动通知Alertmanager然后发出报警。由于我们公司内使用的自研的Qalarm报警系统，接口比较丰富，和Alertmanager的webhook简单对接即可使用。
 
Alertmanager也内建了一部分报警方式，如Email和第三方的Slack，初期我们的存储集群报警使用的就是Slack，响应速度还是很不错的。
 
需要注意的是，如果报警已经触发，但是由于一些原因，比如删除业务监控节点，使报警恢复的规则一直不能触发，那么已出发的报警会按照Alertmanager配置的周期一直重复发送，要么从后台silence掉，要么想办法使报警恢复。例如前段时间我们缩容Ceph集群，操作前没有关闭报警，触发了几个osddown的报警，报警刷新周期2小时，那么每过两小时Alertmanager都会发来一组osddown的报警短信。
 
对应编号的osd由于已经删掉已经不能再写入up对应的监控值，索性停掉osddown报警项，直接重启ceph_exporter，再调用Prometheus API删掉对应osd编号的osdupdown监控项，随后在启用osddown报警项才使报警恢复。
如下图的报警详情页面，红色的是已触发的报警，绿色的是未触发报警：
 

 
绘图展示
   
 
对于页面展示，我们使用的是Grafana，如下面两张图，是两个不同服务的Dashboard，可以做非常多的定制化，同时Grafana的template也可以作为参数传到查询语句中，对多维度定制查询提供了极大的便利。
 

 

 
Q&A  
 
Q1：Promethues Alertmanager，能结合案例来一个么？
A1：直接演示一条报警规则吧。
ALERT SlowRequest
  IF ceph_slow_requests{service="ceph"} > 10
  FOR 1m
  LABELS { qalarm = "true" }
  ANNOTATIONS {
    summary = "Ceph Slow Requests",
    description = "slow requests count: {{ $value }} - Region:{{ $labels.group }}",
  }
这条规则在查询到ceph slow_request > 10并且超过1分钟时触发一条报警。
 
Q2：exporter的编写及使用方法,以及 promethues 如何结合 grafana使用和promethues 是如何进行报警的。
A2：exporter的编写可以单独拿出来写一篇文章了。我们这边主要使用的Prometheus Golang SDK，在项目中注册打点，并通过Http接口暴露出来。报警没有结合Grafana，不过大多数Grafana中使用的查询语句，简单修改即可成为Alertmanager的报警规则。
 
直播链接  
http://m.qlchat.com/topic/details?topicId=280000451202379&isGuide=Y
密码：121