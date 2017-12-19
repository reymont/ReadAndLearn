
# http://tool.chinaz.com/regex

\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{1,3} \[.*\] .* .* \- .* 
2017-12-19 14:00:45.918 [pool-3-thread-1] INFO  com.cmi.jego.activity.task.ActivityTask - ******执行发送活动短信定时任务:Tue Dec 19 14:00:45 CST 2017****** 

# http://blog.mallux.me/2017/02/04/fluentd/

Java
日志格式

[%-5level] [%contextName] %d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{req.remoteHost}] [%X{req.requestURI}] [%X{traceId}] %logger - %msg%n
fluentd 配置

```conf
### ------ JAVA ------
<source>
  @type tail
  @label @JAVA
  tag webapp.java.access
  path /data/logs/**/*.log
  exclude_path ["/data/logs/**/*.gz"]
  format multiline
  format_firstline /^\[[\w ]+\]/
  format1 /^\[(?<level>[\w ]+)\] \[(?<app_name>\S+)\] (?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{1,3}) \[(?<thread>[^ ]+)\] \[(?<remote_addr>[^ ]*)\] \[(?<request>[^ ]*)\] \[(?<trace_id>[^ ]*)\] \S+ - (?<msg>.*)/
  pos_file /tmp/webapp.java.access.pos
</source>
<label @JAVA>
  <filter webapp.java.access>
  @type record_transformer
    <record>
      host "#{Socket.gethostname}"
    </record>
  </filter>
  <match webapp.java.access>
    @type copy
    <store>
        @type stdout
    </store>
    <store>
        @type elasticsearch
        host 192.168.112.4
        port 9200
        logstash_format true
        flush_interval 10s # for testing
        logstash_prefix webapp
    </store>
  </match>
</label>
```