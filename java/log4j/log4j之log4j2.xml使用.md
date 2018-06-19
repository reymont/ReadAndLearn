

log4j之log4j2.xml使用 - 小眼儿 - 博客园 http://www.cnblogs.com/hujunzheng/p/6926429.html

log4j之log4j2.xml使用
依赖jar包

log4j-api-2.6.2.jar
log4j-core-2.6.2.jar
log4j-slf4j-impl-2.6.2.jar
slf4j-api-1.7.12.jar
在resources目录下新建log4j2.xml，内容如下。

复制代码
```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--
    status : 这个用于设置log4j2自身内部的信息输出,可以不设置,当设置成trace时,会看到log4j2内部各种详细输出
    monitorInterval : Log4j能够自动检测修改配置文件和重新配置本身, 设置间隔秒数。
-->
<Configuration status="WARN" monitorInterval="600">

    <Properties>
        <!-- 配置日志文件输出目录 -->
        <Property name="LOG_HOME">/usr/local/apache-tomcat-8.5.15/logs</Property>
    </Properties>

    <Appenders>

        <!--这个输出控制台的配置-->
        <Console name="Console" target="SYSTEM_OUT">
            <!-- 控制台只输出level及以上级别的信息(onMatch),其他的直接拒绝(onMismatch) -->
            <ThresholdFilter level="trace" onMatch="ACCEPT" onMismatch="DENY"/>
            <!-- 输出日志的格式 -->
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %class{36} %L %M - %msg%xEx%n"/>
        </Console>

        <!-- 设置日志格式并配置日志压缩格式(service_client.log.年份.gz) -->
        <RollingRandomAccessFile name="service_client_appender"
                                 immediateFlush="false" fileName="${LOG_HOME}/service_client.log"
                                 filePattern="${LOG_HOME}/service_client.log.%d{yyyy-MM-dd}.log.gz">
            <!--
                %d{yyyy-MM-dd HH:mm:ss, SSS} : 日志生产时间
                %p : 日志输出格式
                %c : logger的名称
                %m : 日志内容，即 logger.info("message")
                %n : 换行符
                %C : Java类名
                %L : 日志输出所在行数
                %M : 日志输出所在方法名
                hostName : 本地机器名
                hostAddress : 本地ip地址
             -->
            <PatternLayout>
                <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %class{36} %L %M -- %msg%xEx%n</pattern>
            </PatternLayout>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1" modulate="true" />
            </Policies>
        </RollingRandomAccessFile>


        <!-- DEBUG日志格式 -->
        <RollingRandomAccessFile name="service_client_debug_appender"
                                 immediateFlush="false" fileName="${LOG_HOME}/service_client.log"
                                 filePattern="${LOG_HOME}/service_client.log.%d{yyyy-MM-dd}.debug.gz">
            <PatternLayout>
                <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %class{36} %L %M -- %msg%xEx%n</pattern>
            </PatternLayout>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1" modulate="true" />
            </Policies>
        </RollingRandomAccessFile>
    </Appenders>

    <Loggers>
        <!-- 配置日志的根节点 -->
        <root level="debug">
            <appender-ref ref="Console"/>
        </root>

        <!-- 第三方日志系统 -->
        <logger name="org.springframework.core" level="info"/>
        <logger name="org.springframework.beans" level="info"/>
        <logger name="org.springframework.context" level="info"/>
        <logger name="org.springframework.web" level="info"/>
        <logger name="org.jboss.netty" level="warn"/>
        <logger name="org.apache.http" level="warn"/>

        <!-- 日志实例(info),其中'service_client-log'继承root,但是root将日志输出控制台,而'service_client-log'将日志输出到文件,通过属性'additivity="false"'将'service_client-log'的
             的日志不再输出到控制台 -->
        <logger name="service_client_log" level="info" includeLocation="true" additivity="true">
            <appender-ref ref="service_client_appender"/>
        </logger>

        <!-- 日志实例(debug) -->
        <logger name="service_client_log" level="debug" includeLocation="true" additivity="false">
            <appender-ref ref="service_client_debug_appender"/>
        </logger>

    </Loggers>

</Configuration>
```
复制代码
 

参考来接：http://blog.csdn.net/axwolfer/article/details/40718609