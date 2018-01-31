How to monitor your system with prometheus 
http://www.songjiayang.com/technical/how-to-monitor-your-system-with-prometheus/


14 Sep 2016 in Technical  2 minutes read
 
Prometheus 是什么？
Prometheus 是一个 golang 写的监控告警系统，完全开源，它提供完善的统计模型和友好的查询语句，可以很方便地实现系统机器运行状况监控。
环境准备
•	linux amd64 (ubuntu server)
•	golang 运行环境 (安装文档 https://golang.org/doc/install)
Step 1 — 安装 Prometheus Server
创建下载目录,以便安装过后清理掉
mkdir ~/Download
cd ~/Download
使用 wget 下载 Prometheus 服务（自带数据库）的安装包
wget https://github.com/prometheus/prometheus/releases/download/v1.1.2/prometheus-1.1.2.linux-amd64.tar.gz
创建 Prometheus 目录，用于存放所有 Prometheus 相关的运行服务
mkdir ~/Prometheus
cd ~/Prometheus
使用 tar 解压缩 prometheus-1.1.2.linux-amd64.tar.gz
tar -xvzf ~/Download/prometheus-1.1.2.linux-amd64.tar.gz
cd prometheus-1.1.2.linux-amd64
当解压缩成功后，可以运行 version 检查运行环境是否正常
./prometheus version
如果你看到类似输出，表示你已安装成功:
prometheus, version xxx (branch: master, revision: xxxx)
  build user:       xxx
  build date:       xxx
  go version:       xxx
Step 2 — 安装 Node Exporter
Node Exporter 是官方提供的最基本的 Exporter, 提供机器运行相关的信息收集，比如 CPU, Memory, Disk 等等， 它会在 Prometheus Server 定时来拉取数据的时候，提供当前的数据。
使用 wget 下载 Node Exporter
cd ~/Download
wget https://github.com/prometheus/node_exporter/releases/download/0.12.0/node_exporter-0.12.0.linux-amd64.tar.gz
使用 tar 解压缩 node_exporter-0.12.0.linux-amd64.tar.gz
cd ~/Prometheus
tar -xvzf ~/Download/node_exporter-0.12.0.linux-amd64.tar.gz
cd node_exporter-0.12.0.linux-amd64
Step 3 — 启动 Node Exporter
使用 ./node_exporter 运行 Node Exporter, 如果看到类似输出，表示运行成功
INFO[0000] Starting node_exporter (version=0.12.0, branch=master, revision=df8dcd2)  source=node_exporter.go:135
INFO[0000] Build context (go=go1.6.2, user=root@ff68505a5469, date=20160505-22:15:11)  source=node_exporter.go:136
INFO[0000] No directory specified, see --collector.textfile.directory  source=textfile.go:57
INFO[0000] Enabled collectors:                           source=node_exporter.go:155
INFO[0000]  - loadavg                                    source=node_exporter.go:157
INFO[0000]  - textfile                                   source=node_exporter.go:157
INFO[0000]  - time                                       source=node_exporter.go:157
INFO[0000] Listening on :9100                            source=node_exporter.go:176
当 Node Exporter 运行起来后，可以在浏览器中访问 http://IP:9100/metrics， 将看到类似输出
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
. . .
提示：当然你可以将 node_exporter 添加到 init 配置里，或者使用 supervisord 作为服务自启动
Step 4 — 启动 Prometheus Server
打开 Prometheus 配置文件 prometheus.yml
cd ~/Prometheus/prometheus-1.1.2.linux-amd64
nano prometheus.yml
修改文件，添加如下配置
scrape_configs:
  - job_name: "node"
    scrape_interval: "15s"
    static_configs:
      - targets: ['127.0.0.1:9100']
配置说明：
•	scrape_configs 表示配置一组数据拉取任务相关参数，比如时间间隔，目标地址等
•	job_name 表示一组叫做 node 的任务
•	static_configs 里面的 targets 表示配置的 exporter 地址
详情参考地址 https://prometheus.io/docs/operating/configuration/
保存修改后，启动 Prometheus Server
./prometheus
如果 prometheus 正常启动，你将看到如下信息：
NFO[0000] Starting prometheus (version=1.1.0, branch=master, revision=5ee84a96db6190d4fcdaf4eff74a09b52824a9aa)  source=main.go:73
INFO[0000] Build context (go=go1.6.3, user=root@54c6975115bb, date=20160903-19:04:27)  source=main.go:74
INFO[0000] Loading configuration file prometheus.yml     source=main.go:221
INFO[0000] Loading series map and head chunks...         source=storage.go:358
INFO[0000] 974 series loaded.                            source=storage.go:363
WARN[0000] No AlertManagers configured, not dispatching any alerts  source=notifier.go:176
INFO[0000] Starting target manager...                    source=targetmanager.go:75
INFO[0000] Listening on :9090                            source=web.go:233
当 Prometheus 启动后，你可以通过浏览器来访问 http://IP:9090，将看到如下页面
 
可以使用 PromQL 实现简单查询
 
提示：你可以将 Prometheus 添加到 init 配置里，或者使用 supervisord 作为服务自启动
结论
•	可以看出 Prometheus 安装非常方便，依赖超级少，自带数据库
•	功能蛮强大的，它的 PromQL 很灵活，详情请参考这里
•	自带的 UI 太过于简单，虽然官方提供了 PromDash, 但是已不推荐使用，更好的选择是采用通用的 Dashbord grafana
•	如果想要添加更多的机器，可以在 static_configs 里的 targets 添加对应 IP 地址
