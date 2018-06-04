
# 使用logstash+elasticsearch+kibana快速搭建日志平台 - buzzlight - 博客园
 http://www.cnblogs.com/buzzlight/p/logstash_elasticsearch_kibana_log.html

使用logstash+elasticsearch+kibana快速搭建日志平台
日志的分析和监控在系统开发中占非常重要的地位，系统越复杂，日志的分析和监控就越重要，常见的需求有:
•	根据关键字查询日志详情
•	监控系统的运行状况
•	统计分析，比如接口的调用次数、执行时间、成功率等
•	异常数据自动触发消息通知
•	基于日志的数据挖掘
很多团队在日志方面可能遇到的一些问题有:
•	开发人员不能登录线上服务器查看详细日志，经过运维周转费时费力
•	日志数据分散在多个系统，难以查找
•	日志数据量大，查询速度慢
•	一个调用会涉及多个系统，难以在这些系统的日志中快速定位数据
•	数据不够实时
常见的一些重量级的开源Trace系统有
•	facebook scribe
•	cloudera flume
•	twitter zipkin
•	storm
这些项目功能强大，但对于很多团队来说过于复杂，配置和部署比较麻烦，在系统规模大到一定程度前推荐轻量级下载即用的方案，比如logstash+elasticsearch+kibana(LEK)组合。
对于日志来说，最常见的需求就是收集、查询、显示，正对应logstash、elasticsearch、kibana的功能。
logstash
 
logstash主页
logstash部署简单，下载一个jar就可以用了，对日志的处理逻辑也很简单，就是一个pipeline的过程
inputs >> codecs >> filters >> outputs
对应的插件有
 
从上面可以看到logstash支持常见的日志类型，与其他监控系统的整合也很方便，可以将数据输出到zabbix、nagios、email等。
推荐用redis作为输入缓冲队列。
你还可以把数据统计后输出到graphite，实现统计数据的可视化显示。
metrics demo 
statsd 
graphite
参考文档
•	cookbook
•	doc
•	demo
elasticsearch
 
elasticsearch主页
elasticsearch是基于lucene的开源搜索引擎，近年来发展比较快，主要的特点有
•	real time
•	distributed
•	high availability
•	document oriented
•	schema free
•	restful api
elasticsearch的详细介绍以后再写，常用的一些资源如下
中文
smartcn, ES默认的中文分词 
https://github.com/elasticsearch/elasticsearch-analysis-smartcn
mmseg 
https://github.com/medcl/elasticsearch-analysis-mmseg
ik 
https://github.com/medcl/elasticsearch-analysis-ik
pinyin, 拼音分词，可用于输入拼音提示中文 
https://github.com/medcl/elasticsearch-analysis-pinyin
stconvert, 中文简繁体互换 
https://github.com/medcl/elasticsearch-analysis-stconvert
常用插件
elasticsearch-servicewrapper，用Java Service Wrapper对elasticsearch做的一个封装 
https://github.com/elasticsearch/elasticsearch-servicewrapper
Elastic HQ，elasticsearch的监控工具 
http://www.elastichq.org
elasticsearch-rtf，针对中文集成了相关插件(rtf = Ready To Fly) 
https://github.com/medcl/elasticsearch-rtf 
作者主页
kibana
 
kibana主页
kibana是一个功能强大的elasticsearch数据显示客户端，logstash已经内置了kibana，你也可以单独部署kibana，最新版的kibana3是纯html+js客户端，可以很方便的部署到Apache、Nginx等Http服务器。
kibana3的地址: https://github.com/elasticsearch/kibana 
kibana2的地址: https://github.com/rashidkpc/Kibana 
kibana3 demo地址: http://demo.kibana.org
从demo可以先看一下kibana的一些基本功能
图表
 
数据表格，可以自定义哪些列显示以及显示顺序
 
可以看到实际执行的查询语句
 
新加一行
 
新加panel，可以看到支持的panel类型
 
加一个饼图
 
用地图显示统计结果
 
按照http response code来统计
 
丰富的查询语法
 
安装部署
下面列一下一个简易LEK体验环境的搭建步骤
安装jdk 1.7
oracle java主页
省略安装过程，推荐1.7+版本
java -version
设置java的环境变量，比如
sudo vim ~/.bashrc

>>
export JAVA_HOME=/usr/lib/jvm/java-7-oracle
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH  
>>

source ~/.bashrc
安装redis
redis主页
cd ~/src
wget http://download.redis.io/releases/redis-2.6.16.tar.gz
tar -zxf redis-2.6.16.tar.gz
cd redis-2.6.16
make
sudo make install
可以通过redis源代码里utils/install_server下的脚本简化配置工作
cd utils
sudo ./install_server.sh 
install_server.sh在问你几个问题后会把redis安装为开机启动的服务，可以通过下面的命令行来启动/停止服务
sudo /etc/init.d/redis_ start/end 
启动redis客户端来验证安装
redis-cli
> keys *
安装Elasticsearch
Elasticsearch主页
cd /search
sudo mkdir elasticsearch
cd elasticsearch
sudo wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.zip
sudo unzip elasticsearch-0.90.5.zip
elasticsearch解压即可使用非常方便，接下来我们看一下效果，首先启动ES服务，切换到elasticsearch目录，运行bin下的elasticsearch
cd /search/elasticsearch/elasticsearch-0.90.5 
bin/elasticsearch -f
访问默认的9200端口
curl -X GET http://localhost:9200
安装logstash
logstash主页
cd /search
sudo mkdir logstash
cd logstash
sudo wget http://download.elasticsearch.org/logstash/logstash/logstash-1.2.1-flatjar.jar
logstash下载即可使用，命令行参数可以参考logstash flags，主要有
agent   #运行Agent模式
-f CONFIGFILE #指定配置文件

web     #自动Web服务
-p PORT #指定端口，默认9292
安装kibana
logstash的最新版已经内置kibana，你也可以单独部署kibana。kibana3是纯粹JavaScript+html的客户端，所以可以部署到任意http服务器上。
cd /search
sudo mkdir kibana
sudo wget http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip
sudo unzip kibana-latest.zip
sudo cp -r  kibana-latest /var/www/html
可以修改config.js来配置elasticsearch的地址和索引。
用浏览器访问试试看 http://127.0.0.1/html/kibana-latest/index.html
集成
把上面的系统集成起来
首先把redis和elasticsearch都启动起来
为logstash新建一个配置文件
cd /search/logstash
sudo vi redis.conf
配置文件内容如下
input {
  redis {
    host => "127.0.0.1"
    port => "6379" 
    key => "logstash:demo"
    data_type => "list"
    codec  => "json"
    type => "logstash-redis-demo"
    tags => ["logstashdemo"]
  }
}

output {
  elasticsearch {
    host => "127.0.0.1"
  }

}
用这个配置文件启动logstash agent
java -jar /search/logstash/logstash-1.2.1-flatjar.jar agent -f /search/logstash/redis.conf &
启动logstash内置的web
java -jar /search/logstash/logstash-1.2.1-flatjar.jar web &
查看web，应该还没有数据
http://127.0.0.1:9292
在redis 加一条数据
RPUSH logstash:demo "{\"time\": \"2013-01-01T01:23:55\", \"message\": \"logstash demo message\"}"
看看elasticsearch中的索引现状
curl 127.0.0.1:9200/_search?pretty=true 

curl -s http://127.0.0.1:9200/_status?pretty=true | grep logstash
再通过logstash web查询一下看看
http://127.0.0.1:9292
通过单独的kibana界面查看
http://127.0.0.1/html/kibana-latest/index.html#/dashboard/file/logstash.json
数据清理
logstash默认按天创建ES索引，这样的好处是删除历史数据时直接删掉整个索引就可以了，方便快速。
elasticsearch也可以设置每个文档的ttl(time to live)，相当于设置文档的过期时间，但相比删除整个索引要耗费更多的IO操作。
索引
elasticsearch默认会按照分隔符对字段拆分，日志有些字段不要分词，比如url，可以为这类字段设置not_analyzed属性。
设置multi-field-type属性可以将字段映射到其他类型。multi-field-type。
大量日志导入时用bulk方式。
对于日志查询来说，filter比query更快 过滤器里不会执行评分而且可以被自动缓存。query-dsl。
elasticsearch默认一个索引操作会在所有分片都完成对文档的索引后才返回，你可以把复制设置为异步来加快批量日志的导入。
elasticsearch 优化
优化JVM 
优化系统可以打开最大文件描述符的数量 
适当增加索引刷新的间隔
最佳实践
•	首先你的程序要写日志
•	记录的日志要能帮助你分析问题，只记录"参数错误"这样的日志对解决问题毫无帮助
•	不要依赖异常，异常只处理你没考虑到的地方
•	要记录一些关键的参数，比如发生时间、执行时间、日志来源、输入参数、输出参数、错误码、异常堆栈信息等
•	要记录sessionid、transitionid、userid等帮你快速定位以及能把各个系统的日志串联起来的关键参数
•	推荐纯文本+json格式
•	使用队列
其他日志辅助工具
•	rsyslog
•	syslog-ng
•	graylog
•	fluentd
•	nxlog
标签: logstash, elasticsearch, kibana, log
