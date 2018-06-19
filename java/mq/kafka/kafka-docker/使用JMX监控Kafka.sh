

# http://blog.csdn.net/qq_23146763/article/details/78680339

# 1.设置jmx参数 
# 修改bin/kafka-run-class.sh ,找到KAFKA_JMX_OPTS，设置 java.rmi.server.hostname，开启远程RMI协议访问，如果不设置，只能本地访问jmx服务
KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=服务器的IP地址或者域名"
# 2.启动时设置JMX_PORT环境变量
export JMX_PORT=9999;nohup bin/kafka-server-start.sh config/server.properties >/dev/null 2>&1 &
# 启动kafka后，使用jconsole就可以远程连接jmx服务 