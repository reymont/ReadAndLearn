

Java深入 - logback的配置和使用 - CSDN博客 
http://blog.csdn.net/initphp/article/details/40891821

1. logback介绍

Logback是由log4j创始人设计的又一个开源日志组件。logback当前分成三个模块：logback-core,logback- classic和logback-access。logback-core是其它两个模块的基础模块。logback-classic是log4j的一个 改良版本。此外logback-classic完整实现SLF4J API使你可以很方便地更换成其它日志系统如log4j或JDK14 Logging。logback-access访问模块与Servlet容器集成提供通过Http来访问日志的功能。

2. maven依赖

[html] view plain copy
<!-- logback+slf4j -->  
<dependency>  
    <groupId>org.slf4j</groupId>  
    <artifactId>slf4j-api</artifactId>  
    <version>1.6.0</version>  
    <type>jar</type>  
    <scope>compile</scope>  
</dependency>  
<dependency>  
    <groupId>ch.qos.logback</groupId>  
    <artifactId>logback-core</artifactId>  
    <version>0.9.28</version>  
    <type>jar</type>  
</dependency>  
<dependency>  
    <groupId>ch.qos.logback</groupId>  
    <artifactId>logback-classic</artifactId>  
    <version>0.9.28</version>  
    <type>jar</type>  
</dependency>  

如果你没有使用maven，那么你自己去下载jar包吧...

3. 配置和使用

1. 日志使用

我们使用org.slf4j.LoggerFactory，就可以直接使用日志了。
[java] view plain copy
protected final Logger       logger = LoggerFactory.getLogger(this.getClass());  
使用：
[java] view plain copy
@Controller  
@RequestMapping(value = "")  
public class IndexController extends BaseController {  
  
    /** 
     * Success 
     * @param response 
     * @throws IOException 
     */  
    @RequestMapping(value = "")  
    @ResponseBody  
    public void hello(HttpServletResponse response) throws IOException {  
        logger.debug("DEBUG TEST 这个地方输出DEBUG级别的日志");  
        logger.info("INFO test 这个地方输出INFO级别的日志");  
        logger.error("ERROR test 这个地方输出ERROR级别的日志");  
    }  
  
}  

2. 在控制台输出特定级别的日志

logback的配置文件都放在/src/main/resource/文件夹下的logback.xml文件中。其中logback.xml文件就是logback的配置文件。只要将这个文件放置好了之后，系统会自动找到这个配置文件。
下面的配置中，我们输出特定的ERROR级别的日志：
[html] view plain copy
<?xml version="1.0"?>  
<configuration>  
  
    <!-- ch.qos.logback.core.ConsoleAppender 控制台输出 -->  
    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">  
        <encoder>  
            <pattern>[%-5level] %d{HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n</pattern>  
        </encoder>  
    </appender>  
  
    <!-- 日志级别 -->  
    <root>  
        <level value="error" />  
        <appender-ref ref="console" />  
    </root>  
  
</configuration>   

结果只在控制台输出ERROR级别的日志。

3. 设置输出多个级别的日志

[html] view plain copy
<?xml version="1.0"?>  
<configuration>  
  
    <!-- ch.qos.logback.core.ConsoleAppender 控制台输出 -->  
    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">  
        <encoder>  
            <pattern>[%-5level] %d{HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n</pattern>  
        </encoder>  
    </appender>  
  
    <!-- 日志级别 -->  
    <root>  
        <level value="error" />  
        <level value="info" />  
        <appender-ref ref="console" />  
    </root>  
  
</configuration>   

设置两个level，则可以输出 ERROR和INFO级别的日志了。

4. 设置文件日志

[html] view plain copy
<?xml version="1.0"?>  
<configuration>  
  
    <!-- ch.qos.logback.core.ConsoleAppender 控制台输出 -->  
    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">  
        <encoder>  
            <pattern>[%-5level] %d{HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n  
            </pattern>  
        </encoder>  
    </appender>  
  
    <!-- ch.qos.logback.core.rolling.RollingFileAppender 文件日志输出 -->  
    <appender name="file"  
        class="ch.qos.logback.core.rolling.RollingFileAppender">  
        <Encoding>UTF-8</Encoding>  
        <File>/home/test.log</File>  
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">  
            <FileNamePattern>/home/test-%d{yyyy-MM-dd}.log  
            </FileNamePattern>  
            <MaxHistory>10</MaxHistory>  
            <TimeBasedFileNamingAndTriggeringPolicy  
                class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">  
                <MaxFileSize>5MB</MaxFileSize>  
            </TimeBasedFileNamingAndTriggeringPolicy>  
        </rollingPolicy>  
        <layout class="ch.qos.logback.classic.PatternLayout">  
            <pattern>[%-5level] %d{HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n  
            </pattern>  
        </layout>  
    </appender>  
  
    <!-- 日志级别 -->  
    <root>  
        <!-- 定义了ERROR和INFO级别的日志，分别在FILE文件和控制台输出 -->  
        <level value="error" />  
        <level value="info" />  
        <appender-ref ref="file" />   
        <appender-ref ref="console" />  
    </root>  
  
  
</configuration>   

5. 精确设置每个包下面的日志

[html] view plain copy
<logger name="com.xxx" additivity="false">  
    <level value="info" />  
    <appender-ref ref="file" />  
    <appender-ref ref="console" />  
</logger>  


详细参考：http://logback.qos.ch/manual/configuration.html