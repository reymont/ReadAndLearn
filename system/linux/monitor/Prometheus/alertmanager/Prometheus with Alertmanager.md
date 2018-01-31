2@Prometheus with Alertmanager 
http://www.songjiayang.com/technical/prometheus-with-alertmanager/

强烈推荐使用官方提供的 alertmanager 实现告警通知
20 Oct 2016 in Technical  2 minutes read
 
在文章 How to monitor your system with prometheus 中介绍过 Prometheus 的安装教程，相信看过的小伙伴都已经开始使用了。但这样就够了吗，是否还缺少点什么？
对，没错，我们缺少告警 ！
图表再好看，也不会时时刻刻盯着啊，个人认为一个好的监控系统是能够自发告警，只有在有告警的时候，我们才登上去多喵几眼。
其实，Prometheus 官方提供了告警模块，那就是 Alertmanager, 不过因为代码解耦关系，它被单独剥离成一个独立项目了。
我是分割线
下面我们将完成安装和配置 Alertmanager, 并结合 Onealert 实现报警需求
环境准备
•	已安装 Prometheus Server (参考 How to monitor your system with prometheus)
Step 1 — 安装 Alertmanager
使用 wget 下载 Alertmanager 安装包
cd ~/Download
wget https://github.com/prometheus/alertmanager/releases/download/v0.4.2/alertmanager-0.4.2.linux-amd64.tar.gz
cd Prometheus
使用 tar 解压缩 alertmanager-0.4.2.linux-amd64.tar.gz
tar -xvzf ~/Download/alertmanager-0.4.2.linux-amd64.tar.gz
cd alertmanager-0.4.2.linux-amd64
当解压缩成功后，可以运行 version 检查运行环境是否正常
./alertmanager -version
如果你看到类似输出，表示你已安装成功:
alertmanager, version xxx (branch: master, revision: 9a5ab2fa63dd7951f4f202b0846d4f4d8e9615b0)
  build user:       root@2811d2f42616
  build date:       20160902-15:34:07
  go version:       go1.6.3
Step 2 — 修改 alertmanager 配置
修改 simple.yml 文件，使用 Onealert 的 Prometheus 默认应用配置
#simple.yml
global:
  resolve_timeout: 1m

route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'webhook'

receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://api.110monitor.com/alert/api/event/prometheus/xxxxxxxxx'
    send_resolved: true
提示: 这里我们使用 Alertmanager 的 webhook_configs，地址为 Onealert 一个 App
Step 3 — 启动 Alertmanager
使用 ./alertmanager -config.file simple.yml 运行 Alertmanager, 如果看到类似输出，表示运行成功
INFO[0000] Starting alertmanager (version=0.4.2, branch=master, revision=9a5ab2fa63dd7951f4f202b0846d4f4d8e9615b0)  source=main.go:84
INFO[0000] Build context (go=go1.6.3, user=root@2811d2f42616, date=20160902-15:34:07)  source=main.go:85
INFO[0000] Loading configuration file                    file=simple.yml source=main.go:156
INFO[0000] Listening on :9093                            source=main.go:206
Step 4 — 添加 Rules
切换到 Prometheus Server 目录, 修改 prometheus.yml 文件，添加 rule_files
#prometheus.yml
rule_files:
  - "first.rules"
创建 first.rules 文件, 并添加
#first.rules
ALERT InstanceStatus
  IF up{job="node"} == 0
  FOR 10s
  LABELS {
    instance = "",
  }
  ANNOTATIONS {
    summary = "服务器  运行状态",
    description = "服务器  已当机超过 20s"
  }
使用命令 ./prometheus -alertmanager.url http://localhost:9093 重启 Promtheus Server
此时在浏览器中访问页面 http://localhost:9090/alerts，你将看到配置的所有 Rules
 
停掉 Node Exporter，隔一定时间，刷新该页面，你将看到
 
此时你会收到类似的告警邮件（Onealert 默认通知配置）
 
至此，我们已完成了使用 Alertmanager 来实现应用的告警通知。
________________________________________
结语：
Prometheus 代码是非常解耦的，我们可以使用官方的 Alertmanager 包，再结合 PromQL 强大能力，简单配置 Rules， 即满足常见告警需求，对于比较特殊的告警，则需要结合 Alertmanager 更加细致的配置实现。
我已仔细阅读代码，发现它在告警聚合，去重，以及配置不同发送频率，不同渠道都做的比较完备，以后会展开细讲。
