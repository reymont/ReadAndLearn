Elastalert-基于Elasticsearch层面的监控告警框架 - Thinkgamer博客 - CSDN博客 http://blog.csdn.net/gamer_gyt/article/details/52917116

转载请注明出处：http://blog.csdn.net/gamer_gyt 
博主微博：http://weibo.com/234654758 
Github：https://github.com/thinkgamer
写在前边的话

Elastalert是Yelp公司用python2.6写的一个报警框架，github地址为 
https://github.com/Yelp/elastalert

环境介绍

Ubuntu16.04 
Elasticsearch 2.4.1 
Logstash 2.4.0 
Kibana 4.6.1

Elastalert的安装

Elastalert的安装相对比较简单，只需要按照步骤走就没有问题

git clone https://github.com/Yelp/elastalert.git
进入elastalert的目录，执行

Pip install -r requirements.txt 
Python setup.py install
OK 安装完事

安装之后会自带三个命令

elastalert-create-index：ElastAlert会把执行记录存放到一个ES 索引中，该命令就是用来 创建这个索引的，默认情况下，索引名叫elastalert_status。其中有4个 _type，都有 自己的@timestamp字段，所以同样也可以用kibana，来查看这个索引的日志记录情况。
elastalert-rule-from-kibana：从Kibana3已保存的仪表盘中读取Filtering设置，帮助生成config.yaml里的配置。不过注意，它只会读取filtering，不包括queries。
elastalert-test-rule：测试自定义配置中的rule设置。
Elastalert支持的警告类型

Command
Email
JIRA
OpsGenie
SNS
HipChat
Slack
Telegram
Debug
至于每种是干什么的，参考官网资料吧，不过多解释 
http://elastalert.readthedocs.io/en/latest/

config.ymal中的配置项

Rules_folder：用来加载下一阶段rule的设置，默认是example_rules
Run_every：用来设置定时向elasticsearch发送请求
Buffer_time：用来设置请求里时间字段的范围，默认是45分钟
Es_host：elasticsearch的host地址
Es_port：elasticsearch 对应的端口号
Use_ssl：可选的，选择是否用SSL连接es，true或者false
Verify_certs：可选的，是否验证TLS证书，设置为true或者false，默认为true
Es_username：es认证的username
Es_password：es认证的password
Es_url_prefix：可选的，es的url前缀（我的理解是https或者http）
Es_send_get_body_as：可选的，查询es的方式，默认的是GET
Writeback_index：elastalert产生的日志在elasticsearch中的创建的索引
Alert_time_limit：失败重试的时间限制
Elastalert的rule规则

name：配置，每个rule需要有自己独立的name，一旦重复，进程将无法启动。
type：配置，选择某一种数据验证方式。
index：配置，从某类索引里读取数据，目前已经支持Ymd格式，需要先设置 use_strftime_index:true，然后匹配索引，配置形如：index: logstash-es-test%Y.%m.%d，表示匹配logstash-es-test名称开头，以年月日作为索引后缀的index。
filter：配置，设置向ES请求的过滤条件。
timeframe：配置，累积触发报警的时长。
alert：配置，设置触发报警时执行哪些报警手段。不同的type还有自己独特的配置选项。目前ElastAlert 有以下几种自带ruletype： 
any：只要有匹配就报警；
blacklist：compare_key字段的内容匹配上 blacklist数组里任意内容；
whitelist：compare_key字段的内容一个都没能匹配上whitelist数组里内容；
change：在相同query_key条件下，compare_key字段的内容，在 timeframe范围内 发送变化；
frequency：在相同 query_key条件下，timeframe 范围内有num_events个被过滤出 来的异常；
spike：在相同query_key条件下，前后两个timeframe范围内数据量相差比例超过spike_height。其中可以通过spike_type设置具体涨跌方向是up,down,both 。还可以通过threshold_ref设置要求上一个周期数据量的下限，threshold_cur设置要求当前周期数据量的下限，如果数据量不到下限，也不触发；
flatline：timeframe 范围内，数据量小于threshold 阈值；
new_term：fields字段新出现之前terms_window_size(默认30天)范围内最多的terms_size (默认50)个结果以外的数据；
cardinality：在相同 query_key条件下，timeframe范围内cardinality_field的值超过 max_cardinality 或者低于min_cardinality
一个小demo

这里我们还是测试rrsyslog发送日志的这个例子，就是启动ELK服务，rsyslog通过logstash把日志发送给elasticsearch，然后传送给kibana，logstash编写rsyslog_test.conf文件，内容为

input {
  tcp{
    port => 5000
    type => syslog
  }
  udp{
    port => 5000
    type => syslog
  }
}
output {
  stdout {
    codec=> rubydebug
  }
  elasticsearch {
    hosts => ["192.168.1.198:9200"]
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
然后启动ELK服务和rsyslog_test.conf文件 
编辑elastalert下的configure.yaml文件

rules_folder: example_rules

run_every:
  minutes: 1

buffer_time:
  minutes: 15

es_host: localhost
es_port: 9200

writeback_index: elastalert_status

alert_time_limit:
  days: 2
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
编辑example_rules/example_frequency.yaml 文件内容如下：

es_host: localhost

es_port: 9200

name: Example rule

use_strftine_index: true

type: frequency

index: logstash-*

num_events: 5

timeframe:
  hours: 1

filter:
- term:
    _type: "syslog"

alert:
- "email"
email:
- "elastalert@example.com"
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
上边我们设置的事件次数是5，也就是说elaticseach记录的事件条件超过即发送email文件，这里的email文件我并没有配置，原因是测试没有成功，需要提供密码验证，没有解决，以后解决的话会在评论中给出，不过这里用debug替换下列verbose即可将邮件内容打印在窗口 
启动elastalert服务，监听elasticsearch

python -m elastalert.elastalert –debug –rule example_rules/example_frequency.yaml
这个时候我们的ELK已经启动了，再次启动终端，执行ssh localhost进行测试，只要在一分钟内连续输入几次的错误密码，这个时候就会在elastalert的终端看到类似下面这样的提示：

INFO:elastalert:Queried rule Example rule from 2016-10-24 08:20 PDT to 2016-10-24 08:35 PDT: 34 / 34 hits
INFO:elastalert:Skipping writing to ES: {'rule_name': 'Example rule', '@timestamp': '2016-10-24T15:35:00.120937Z', 'exponent': 0, 'until': '2016-10-24T15:36:00.120924Z'}
INFO:elastalert:Alert for Example rule at 2016-10-24T15:34:24.422Z:
INFO:elastalert:Example rule

At least 5 events occurred between 2016-10-24 07:34 PDT and 2016-10-24 08:34 PDT

@timestamp: 2016-10-24T15:34:24.422Z
@version: 1
_id: AVf3VBTs1Cgl8RD3WDw9
_index: logstash-2016.10.24
_type: syslog
host: 127.0.0.1
message: <38>Oct 24 08:34:24 ubuntu sshd[3097]: Connection closed by 127.0.0.1 port 52434 [preauth]
type: syslog

INFO:elastalert:Skipping writing to ES: {'hits': 34, 'matches': 1, '@timestamp': '2016-10-24T15:35:00.123939Z', 'rule_name': 'Example rule', 'starttime': '2016-10-24T15:20:00.031300Z', 'endtime': '2016-10-24T15:35:00.031300Z', 'time_taken': 0.09257292747497559}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
说明整个告警体系已经OK了

邮件告警配置

上次在配置邮件告警时并没有取得成功，后来又尝试了几次，ok了 
以下进行得操作基于上边得demo步骤

首先添加发送方： 
在elastalert目录下编辑smtp_auth_file.yaml文件，加入你要使用发送邮件的账号和密码 
这里我使用的是网易的163邮箱，这里的密码是你开启邮箱的POP3的客户端登陆密码，不是网页登陆邮箱的密码

user: "thinkgamer@163.com"
password: "xxxxxxxx"
1
2
然后编辑你的配置文件，我这里使用 example_rules/example_frequency.yaml 
别的配置正常配置，在alert之前加入

#SMTP协议的邮件服务器相关配置（我这里是腾讯企业邮箱）
#smtp.163.com是网易163邮箱的smtp服务器
smtp_host: smtp.163.com
smtp_port: 25

#用户认证文件，需要user和password两个属性
# smtp_auth_file.yaml，为刚才编辑的配置文件
smtp_auth_file: smtp_auth_file.yaml
email_reply_to: thinkgamer@163.com
from_addr: thinkgamer@163.com
1
2
3
4
5
6
7
8
9
10
修改email为你要接受邮件的邮箱

然后启动配置文件

python -m elastalert.elastalert --verbose --rule example_rules/example_frequency.yaml
1
测试： 
这里写图片描述

查看邮件： 
这里写图片描述

Over！