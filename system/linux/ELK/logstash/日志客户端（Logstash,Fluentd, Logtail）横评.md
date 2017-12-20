


# 日志客户端（Logstash,Fluentd, Logtail）横评-博客-云栖社区-阿里云 
https://yq.aliyun.com/articles/3228?spm=5176.team4.teamshow1.37.faH93Z


摘要： 针对主流日志采集客户端（Logstash，Fluentd，以及日志服务客户端Logtail）进行功能、性能和稳定性测评
日志收集的场景
DT时代，数以亿万计的服务器、移动终端、网络设备每天产生海量的日志。
中心化的日志处理方案有效地解决了在完整生命周期内对日志的消费需求，而日志从设备采集上云是始于足下的第一步。
 
三款日志收集工具
logstash
开源界鼎鼎大名ELK stack中的"L"，社区活跃，生态圈提供大量插件支持。
logstash基于JRuby实现，可以跨平台运行在JVM上。
模块化设计，有很强的扩展性和互操作性。
fluentd
开源社区中流行的日志收集工具，td-agent是其商业化版本，由Treasure Data公司维护，是本文选用的评测版本。
fluentd基于CRuby实现，并对性能表现关键的一些组件用C语言重新实现，整体性能不错。
fluentd设计简洁，pipeline内数据传递可靠性高。相较于logstash，其插件支持相对少一些。
logtail
阿里云日志服务的生产者，目前在阿里集团内部机器上运行，经过3年多时间的考验，目前为阿里公有云用户提供日志收集服务。
采用C++语言实现，对稳定性、资源控制、管理等下过很大的功夫，性能良好。相比于logstash、fluentd的社区支持，logtail功能较为单一，专注日志收集功能。
日志文件收集场景 - 功能对比
功能项	logstash	fluentd	logtail
日志读取	轮询	轮询	事件触发
文件轮转	支持	支持	支持
Failover处理 (本地checkpoint)	支持	支持	支持
通用日志解析	支持grok（基于正则表达式）解析	支持正则表达式解析	支持正则表达式解析
特定日志类型	支持delimiter、key-value、json等主流格式	支持delimiter、key-value、json等主流格式	支持key-value格式
数据发送压缩	插件支持	插件支持	LZ4
数据过滤	支持	支持	支持
数据buffer发送	插件支持	插件支持	支持
发送异常处理	插件支持	插件支持	支持
运行环境	JRuby实现，依赖JVM环境	CRuby、C实现，依赖Ruby环境	C++实现，无特殊要求
线程支持	支持多线程	多线程受GIL限制	支持多线程
热升级	不支持	不支持	支持
中心化配置管理	不支持	不支持	支持
运行状态自检	不支持	不支持	支持cpu/内存阈值保护
日志文件收集场景 - 性能对比
日志样例
以Nginx的access log为样例，如下一条日志365字节，结构化成14个字段：
 
在接下来的测试中，将模拟不同的压力将该日志重复写入文件，每条日志的time字段取当前系统时间，其它13个字段相同。
相比于实际场景，模拟场景在日志解析上并无差异，有一点区别是：较高的数据压缩率会减少网络写出流量。
logstash
logstash-2.0.0版本，通过grok解析日志并写出到kafka（内置插件，开启gzip压缩）。
日志解析配置：
grok {
    patterns_dir=>"/home/admin/workspace/survey/logstash/patterns"
    match=>{ "message"=>"%{IPORHOST:ip} %{USERNAME:rt} - \[%{HTTPDATE:time}\] \"%{WORD:method} %{DATA:url}\" %{NUMBER:status} %{NUMBER:size} \"%{DATA:ref}\" \"%{DATA:agent}\" \"%{DATA:cookie_unb}\" \"%{DATA:cookie_cookie2}\" \"%{DATA:monitor_traceid}\" %{WORD:cell} %{WORD:ups} %{BASE10NUM:remote_port}" }
    remove_field=>["message"]
}
测试结果：
写入TPS	写入流量 (KB/s)	CPU使用率 (%)	内存使用 (MB)
500	178.22	22.4	427
1000	356.45	46.6	431
5000	1782.23	221.1	440
10000	3564.45	483.7	450
fluentd
td-agent-2.2.1版本，通过正则表达式解析日志并写入kafka（第三方插件fluent-plugin-kafka，开启gzip压缩）。
日志解析配置：
<source>
  type tail
  format /^(?<ip>\S+)\s(?<rt>\d+)\s-\s\[(?<time>[^\]]*)\]\s"(?<url>[^\"]+)"\s(?<status>\d+)\s(?<size>\d+)\s"(?<ref>[^\"]+)"\s"(?<agent>[^\"]+)"\s"(?<cookie_unb>\d+)"\s"(?<cookie_cookie2>\w+)"\s"(?
<monitor_traceid>\w+)"\s(?<cell>\w+)\s(?<ups>\w+)\s(?<remote_port>\d+).*$/
  time_format %d/%b/%Y:%H:%M:%S %z
  path /home/admin/workspace/temp/mock_log/access.log
  pos_file /home/admin/workspace/temp/mock_log/nginx_access.pos
  tag nginx.access
</source>
测试结果：
写入TPS	写入流量 (KB/s)	CPU使用率 (%)	内存使用 (MB)
500	178.22	13.5	61
1000	356.45	23.4	61
5000	1782.23	94.3	103
注：受GIL限制，fluentd单进程最多使用1个cpu核心，可以使用插件multiprocess以多进程的形式支持更大的日志吞吐。
logtail
logtail 0.9.4版本，设置正则表达式进行日志结构化，数据LZ4压缩后以HTTP协议写到阿里云日志服务，设置batch_size为4000条。
日志解析配置：
logRegex : (\S+)\s(\d+)\s-\s\[([^]]+)]\s"([^"]+)"\s(\d+)\s(\d+)\s"([^"]+)"\s"([^"]+)"\s"(\d+)"\s"(\w+)"\s"(\w+)"\s(\w+)\s(\w+)\s(\d+).*
keys : ip,rt,time,url,status,size,ref,agent,cookie_unb,cookie_cookie2,monitor_traceid,cell,ups,remote_port
timeformat : %d/%b/%Y:%H:%M:%S
测试结果：
写入TPS	写入流量 (KB/s)	CPU使用率 (%)	内存使用 (MB)
500	178.22	1.7	13
1000	356.45	3	15
5000	1782.23	15.3	23
10000	3564.45	31.6	25
单核处理能力对比
 
总结
可以看到三款日志工具各有特点：
•	logstash支持所有主流日志类型，插件支持最丰富，可以灵活DIY，但性能较差，JVM容易导致内存使用量高。
•	fluentd支持所有主流日志类型，插件支持较多，性能表现较好。
•	logtail占用机器cpu、内存资源最少，结合阿里云日志服务的E2E体验良好，但目前对特定日志类型解析的支持较弱，后续需要把这一块补起来。





