使用Prometheus和Grafana监控Mysql服务器性能 - icyfire - SegmentFault
https://segmentfault.com/a/1190000007040144

这是一篇快速入门文章，介绍了如何使用Prometheus和Grafana对Mysql服务器性能进行监控。内容基于这篇文章，结合了自己的实际实践并根据最新版本的应用进行了调整。下面是两张效果图：





概述
Prometheus是一个开源的服务监控系统，它通过HTTP协议从远程的机器收集数据并存储在本地的时序数据库上。它提供了一个简单的网页界面、一个功能强大的查询语言以及HTTP接口等等。Prometheus通过安装在远程机器上的exporter来收集监控数据，我们用到了以下两个exporter：

node_exporter – 用于收集系统数据
mysqld_exporter – 用于收集Mysql数据
Grafana是一个开源的功能丰富的数据可视化平台，通常用于时序数据的可视化。它内置了以下数据源的支持：



并可以通过插件扩展支持的数据源。

架构图
下面是我们安装时用到的架构图：



安装和运行Prometheus
安装Prometheus
首先我们安装Prometheus：

$ wget https://github.com/prometheus/prometheus/releases/download/v1.6.3/prometheus-1.6.3.linux-amd64.tar.gz -O prometheus-1.6.3.linux-amd64.tar.gz
$ mkdir /usr/local/services/prometheus
$ tar zxf prometheus-1.6.3.linux-amd64.tar.gz -C /usr/local/services/prometheus --strip-components=1
配置prometheus
然后在安装目下编辑配置文件 prometheus.yml：

global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: linux
    static_configs:
      - targets: ['host:9100']
        labels:
          instance: db1

  - job_name: mysql
    static_configs:
      - targets: ['host:9104']
        labels:
          instance: db1
host是我们数据库主机的IP，端口则是对应的exporter的监听端口。

运行Prometheus
然后我们启动Prometheus：

$ ./prometheus       
INFO[0000] Starting prometheus (version=1.6.3, branch=master, revision=c580b60c67f2c5f6b638c3322161bcdf6d68d7fc)  source=main.go:88
INFO[0000] Build context (go=go1.8.1, user=root@a6410e65f5c7, date=20170522-09:15:06)  source=main.go:89
INFO[0000] Loading configuration file prometheus.yml     source=main.go:251
INFO[0000] Loading series map and head chunks...         source=storage.go:421
INFO[0000] 0 series loaded.                              source=storage.go:432
INFO[0000] Listening on :9090                            source=web.go:259
INFO[0000] Starting target manager...                    source=targetmanager.go:61
INFO[0300] Checkpointing in-memory metrics and chunks...  source=persistence.go:633
INFO[0300] Done checkpointing in-memory metrics and chunks in 75.372924ms.  source=persistence.go:665
Prometheus内置了一个web界面，我们可通过http://monitor_host:9090进行访问：



在Status->Targets页面下，我们可以看到我们配置的两个Target，它们的State为DOWN。



部署exporter
下一步我们需要安装并运行exporter。下载exporters并解压：

$ wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz -O node_exporter-0.14.0.linux-amd64.tar.gz
$ wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.10.0/mysqld_exporter-0.10.0.linux-amd64.tar.gz -O mysqld_exporter-0.10.0.linux-amd64.tar.gz
$ mkdir /usr/local/services/prometheus_exporters
$ tar zxf node_exporter-0.14.0.linux-amd64.tar.gz -C /usr/local/services/prometheus_exporters --strip-components=1
$ tar zxf mysqld_exporter-0.10.0.linux-amd64.tar.gz -C /usr/local/services/prometheus_exporters --strip-components=1
运行node_exporter ：

$ cd /usr/local/services/prometheus_exporters
$ ./node_exporter 
INFO[0000] Starting node_exporter (version=0.14.0, branch=master, revision=840ba5dcc71a084a3bc63cb6063003c1f94435a6)  source="node_exporter.go:140"
INFO[0000] Build context (go=go1.7.5, user=root@bb6d0678e7f3, date=20170321-12:12:54)  source="node_exporter.go:141"
INFO[0000] No directory specified, see --collector.textfile.directory  source="textfile.go:57"
INFO[0000] Enabled collectors:                           source="node_exporter.go:160"
INFO[0000]  - netdev                                     source="node_exporter.go:162"
INFO[0000]  - sockstat                                   source="node_exporter.go:162"
INFO[0000]  - stat                                       source="node_exporter.go:162"
INFO[0000]  - vmstat                                     source="node_exporter.go:162"
INFO[0000]  - filefd                                     source="node_exporter.go:162"
INFO[0000]  - loadavg                                    source="node_exporter.go:162"
INFO[0000]  - mdadm                                      source="node_exporter.go:162"
INFO[0000]  - meminfo                                    source="node_exporter.go:162"
INFO[0000]  - time                                       source="node_exporter.go:162"
INFO[0000]  - uname                                      source="node_exporter.go:162"
INFO[0000]  - edac                                       source="node_exporter.go:162"
INFO[0000]  - hwmon                                      source="node_exporter.go:162"
INFO[0000]  - diskstats                                  source="node_exporter.go:162"
INFO[0000]  - entropy                                    source="node_exporter.go:162"
INFO[0000]  - infiniband                                 source="node_exporter.go:162"
INFO[0000]  - netstat                                    source="node_exporter.go:162"
INFO[0000]  - textfile                                   source="node_exporter.go:162"
INFO[0000]  - wifi                                       source="node_exporter.go:162"
INFO[0000]  - zfs                                        source="node_exporter.go:162"
INFO[0000]  - conntrack                                  source="node_exporter.go:162"
INFO[0000]  - filesystem                                 source="node_exporter.go:162"
INFO[0000] Listening on :9100                            source="node_exporter.go:186"
mysqld_exporter需要连接到Mysql，所以需要Mysql的权限，我们先为它创建用户并赋予所需的权限：

mysql> GRANT REPLICATION CLIENT, PROCESS ON *.* TO 'prom'@'localhost' identified by 'abc123';
mysql> GRANT SELECT ON performance_schema.* TO 'prom'@'localhost';
创建.my.cnf文件并运行mysqld_exporter：

$ cd /usr/local/services/prometheus_exporters
$ cat << EOF > .my.cnf
[client]
user=prom
password=abc123
EOF
$ ./mysqld_exporter -config.my-cnf=".my.cnf"  
INFO[0000] Starting mysqld_exporter (version=0.10.0, branch=master, revision=80680068f15474f87847c8ee8f18a2939a26196a)  source="mysqld_exporter.go:460"
INFO[0000] Build context (go=go1.8.1, user=root@3b0154cd9e8e, date=20170425-11:24:12)  source="mysqld_exporter.go:461"
INFO[0000] Listening on :9104                            source="mysqld_exporter.go:479
我们再次回到Status->Targets页面，可以看到两个Target的状态已经变成UP了：



安装和运行Grafana
下载并解压Grafana：

$ wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.3.1.linux-x64.tar.gz
$ mkdir /usr/local/services/grafana
$ tar zxvf grafana-4.3.1.linux-x64.tar.gz -C /usr/local/services/grafana  --strip-components=1
编辑配置文件/usr/local/services/grafana/conf/defaults.ini，修改dashboards.json段落下两个参数的值：

[dashboards.json]
enabled = true
path = /var/lib/grafana/dashboards
安装仪表盘:

$ git clone https://github.com/percona/grafana-dashboards.git
$ cp -r grafana-dashboards/dashboards /var/lib/grafana/
最后我们运行Grafana服务：

$ cd /usr/local/services/grafana/bin/
$ ./grafana-server
INFO[05-25|15:42:46] Starting Grafana                         logger=main version=4.3.1 commit=befc15c compiled=2017-05-23T21:50:22+0800
INFO[05-25|15:42:46] Config loaded from                       logger=settings file=/usr/local/services/grafana/conf/defaults.ini
INFO[05-25|15:42:46] Path Home                                logger=settings path=/usr/local/services/grafana
INFO[05-25|15:42:46] Path Data                                logger=settings path=/usr/local/services/grafana/data
INFO[05-25|15:42:46] Path Logs                                logger=settings path=/usr/local/services/grafana/data/log
INFO[05-25|15:42:46] Path Plugins                             logger=settings path=/usr/local/services/grafana/data/plugins
INFO[05-25|15:42:46] Initializing DB                          logger=sqlstore dbtype=sqlite3
INFO[05-25|15:42:46] Starting DB migration                    logger=migrator
INFO[05-25|15:42:46] Executing migration                      logger=migrator id="copy data account to org"
INFO[05-25|15:42:46] Skipping migration condition not fulfilled logger=migrator id="copy data account to org"
INFO[05-25|15:42:46] Executing migration                      logger=migrator id="copy data account_user to org_user"
INFO[05-25|15:42:46] Skipping migration condition not fulfilled logger=migrator id="copy data account_user to org_user"
INFO[05-25|15:42:46] Creating json dashboard index for path: /var/lib/grafana/dashboards 
INFO[05-25|15:42:46] Starting plugin search                   logger=plugins
INFO[05-25|15:42:46] Initializing CleanUpService              logger=cleanup
INFO[05-25|15:42:46] Initializing Alerting                    logger=alerting.engine
INFO[05-25|15:42:46] Initializing Stream Manager 
INFO[05-25|15:42:46] Initializing HTTP Server                 logger=http.server address=0.0.0.0:3000 protocol=http subUrl= socket=
我们可通过http://monitor_host:3000访问Grafana网页界面（缺省的帐号/密码为admin/admin）：





然后我们到Data Sources页面添加数据源：



最后我们就可以通过选择不同的仪表盘（左上角）和时间段（右上角）来呈现图表了：







遇到的问题
Prometheus和Grafana都正常，但是仪表盘不显示数据
Prometheus和Grafana都运行正常，exporter的状态也正常，Grafana上的添加的数据源也正常工作，但是仪表盘就是没有任何数据。唯一的线索是在Prometheus的管理后台执行查询时显示No datapoints found.的错误，根据这个错误在网上搜索到这个issue：https://github.com/prometheus...，里面有人提到是系统时间不正确的问题，发现系统的时间确实不对，同步时间后解决问题。

参考资料
https://prometheus.io/
http://grafana.org/
https://github.com/percona/gr...
https://www.percona.com/blog/...