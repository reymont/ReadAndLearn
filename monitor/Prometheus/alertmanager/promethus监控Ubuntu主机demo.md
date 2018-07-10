3@promethus监控Ubuntu主机demo 
http://blog.leanote.com/post/mozhata/promethus%E7%9B%91%E6%8E%A7Ubuntu%E4%B8%BB%E6%9C%BA


参考链接：Monitoring linux stats with Prometheus.io
这个demo展示如何使用prometheus监控Ubuntu系统信息
大概流程大概是这个样子
1.	node_exporter监控主机信息并提供API接口
2.	prometheus定时拉去node_exporter的监控信息
3.	prometheus定时检查报警条件是否触发，若触发则发送报警信息给Alertmanager处理
4.	Alertmanager决定如何处理报警，比如忽略，发送邮件等
准备工作
•	安装prometheus主程序， 为了方便，这里直接用了docker镜像
1.	docker pull prom/prometheus
如果要直接用二进制文件部署的话需要指定一些依赖文件，比如html模板，依赖库等， 具体可查看prometheus项目的Dockerfile
•	安装alertmanager用于报警服务
•	安装node_exporter用于监控主机的CPU 内存 磁盘状况等信息
创建目录prometheus_demo,所有先关文件都放在这个目录内
1.	mkdir -p /home/root/prometheus_demo
•	创建prometheus.yml文件，用来配置prometheus
•	创建alert.rules文件，用来定义触发报警条件
•	创建alertmanager.yml 配置alertmanager
文件结构类似这个样子
1.	├── alertmanager.yml
2.	├── alert.rules
3.	└── prometheus.yml
监控数据
这里使用node_exporter作为exporters监控Ubuntu主机信息。 
默认端口为9100，也可以使用-web.listen-address ":<PORT>"参数修改，访问http://<your-device-ip>:9100/metrics查看node_exporter的监控项
1.	node_exporter &
这里就是http://localhost://9100/metrics
有个问题， 因为prometheus主程序用的是docker，所以主程序无法直接访问到localhost这个地址，可以使用主机ip
配置prometheus
收集监控数据到prometheus
主要就是配置target然后加一些label， 大概像这个样子
1.	// prometheus.yml
2.	
3.	scrape_configs:
4.	  - job_name: "node"
5.	    static_configs:
6.	      - targets: ["192.168.0.66:9100"]
7.	        labels:
8.	          device_ID: "local"
其中192.168.0.66 是我的主机ip
设置警报触发条件
修改alert.rules 写入报警触发条件
1.	// alert.rules
2.	
3.	ALERT cpu_threshold_exceeded  
4.	  IF (100 * (1 - avg by(job)(irate(node_cpu{mode='idle'}[5m])))) > 6
5.	  ANNOTATIONS {
6.	    summary = "Instance {{ $labels.instance }} CPU usage is dangerously high",
7.	    description = "This device's CPU usage has exceeded the threshold with a value of {{ $value }}.",
8.	  }
9.	
10.	  ALERT service_down
11.	    IF up == 0
12.	    ANNOTATIONS {
13.	      summary = "Instance {{ $labels.instance }} is down",
14.	    }
其中，第一条：cpu_threshold_exceeded 当CPU利用率超过6%之后触发报警 
第二条：service_down 当监控服务挂掉则报警，我们只有一个target， 把node_exporter进程杀掉就会触发报警
把alert.rules中的规则应用到prometheus:
1.	// prometheus.yml
2.	
3.	rule_files:
4.	  - "/conf/alert.rules"
这里的文件路径是/conf而不是上面提到的/home/root/prometheus_demo，是因为这个目录是因为这里用的是docker， /conf是主机目录/home/root/prometheus_demo在容器内的映射目录，后面会提到
配置alertmanager链接
1.	// prometheus.yml
2.	
3.	alerting:
4.	  alertmanagers:
5.	  - scheme: http
6.	    static_configs:
7.	    - targets:
8.	      - "192.168.0.66:9093"
其中"192.168.0.66:9093"是alertmanager
prometheus.yml文件配置完之后是这个样子
1.	# config for docker
2.	global:
3.	  scrape_interval:     15s # By default, scrape targets every 15 seconds.
4.	  evaluation_interval: 15s # Evaluate rules every 15 seconds.
5.	
6.	  # Attach these extra labels to all timeseries collected by this Prometheus instance.
7.	  external_labels:
8.	    monitor: 'codelab-monitor'
9.	
10.	rule_files:
11.	  - "/conf/alert.rules"
12.	
13.	scrape_configs:
14.	  - job_name: "node"
15.	    static_configs:
16.	      - targets: ["192.168.0.66:9100"]
17.	        labels:
18.	          device_ID: "local"
19.	
20.	alerting:
21.	  alertmanagers:
22.	  - scheme: http
23.	    static_configs:
24.	    - targets:
25.	      - "192.168.0.66:9093"
启动prometheus：
1.	    docker run --rm -p 9090:9090 \
2.	    -v /home/root/prometheus_demo:/conf \
3.	    -d prom/prometheus \
4.	    -config.file=/conf/prometheus.yml \
5.	    -storage.local.path=/prometheus \
6.	    -web.console.libraries=/usr/share/prometheus/console_libraries \
7.	    -web.console.templates=/usr/share/prometheus/consoles
打开http://localhost:9090/alerts查看定义的报警规则 
 
点击链接可以直接跳到graph界面
 
接下来配置Alertmanager
配置Alertmanager
这里设置的是邮件报警
1.	// alertmanager.yml
2.	
3.	global:
4.	  # The smarthost and SMTP sender used for mail notifications.
5.	  smtp_smarthost: 'smtp.163.com:25'
6.	  smtp_from: "sender@163.com"
7.	  smtp_auth_username: "sender@163.com"
8.	  smtp_auth_password: 'SENDERPWD'
9.	  # The auth token for Hipchat.
10.	  # hipchat_auth_token: 'SENDERPWD'
11.	
12.	route:  
13.	  group_by: [Alertname]
14.	  # Send all notifications to me.
15.	  receiver: email-me
16.	  # When a new group of alerts is created by an incoming alert, wait at
17.	  # least 'group_wait' to send the initial notification.
18.	  # This way ensures that you get multiple alerts for the same group that start
19.	  # firing shortly after another are batched together on the first
20.	  # notification.
21.	  group_wait: 30s
22.	
23.	  # When the first notification was sent, wait 'group_interval' to send a batch
24.	  # of new alerts that started firing for that group.
25.	  group_interval: 5m
26.	
27.	  # If an alert has successfully been sent, wait 'repeat_interval' to
28.	  # resend them.
29.	  repeat_interval: 5m
30.	
31.	receivers:  
32.	- name: email-me
33.	  email_configs:
34.	  - to: "receiver@aliyun.com"
其中SENDERPWD是邮箱sender@163.com的密码
启动Alertmanager:
1.	alertmanager -config.file=./alertmanager.yml &
当有报警需要处理的时候就会使用邮箱sender@163.com向邮箱receiver@aliyun.com发送邮件
像这样：
 
上一篇: sublime 笔记
