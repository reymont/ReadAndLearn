Spring Boot全日志设置 - CSDN博客 https://blog.csdn.net/csdn2193714269/article/details/76155008


说在前面

这里日志分两种。一种是tomcat的输出（系统）日志，一种是自己定义的日志。

系统日志设置

目标

当springboot接收到请求时记录日志到文件中

实现

你只需要在你的绿叶application.properties配置文件中加入一下的配置

system.root.path=D:
server.tomcat.basedir=${system.root.path}/log/tomcat_log
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.pattern=%t %a "%r" %s %S (%D ms)
效果

它就会自动在D:/log/tomcat_log目录下生成所有请求的日志

[26/Jul/2017:15:42:19 +0800] 0:0:0:0:0:0:0:1 "GET /assets/img/nav-expand.png HTTP/1.1" 404 - (72 ms)
[26/Jul/2017:15:42:23 +0800] 0:0:0:0:0:0:0:1 "GET /assets/img/nav-expand.png HTTP/1.1" 404 - (6 ms)
[26/Jul/2017:15:42:24 +0800] 0:0:0:0:0:0:0:1 "GET /view/recommendedSetting HTTP/1.1" 200 - (4 ms)
[26/Jul/2017:15:42:24 +0800] 0:0:0:0:0:0:0:1 "GET /assets/css/bootstrap.css.map HTTP/1.1" 404 - (5 ms)
[26/Jul/2017:15:42:24 +0800] 0:0:0:0:0:0:0:1 "GET /assets/img/nav-expand.png HTTP/1.1" 404 - (6 ms)
[26/Jul/2017:15:42:25 +0800] 0:0:0:0:0:0:0:1 "GET /assets/img/nav-expand.png HTTP/1.1" 404 - (5 ms)
[26/Jul/2017:15:42:26 +0800] 0:0:0:0:0:0:0:1 "GET /view/blank.html HTTP/1.1" 404 - (54 ms)
[26/Jul/2017:15:42:29 +0800] 0:0:0:0:0:0:0:1 "GET /view/blank.html HTTP/1.1" 404 - (7 ms)
[26/Jul/2017:15:42:29 +0800] 0:0:0:0:0:0:0:1 "GET /view/blank.html HTTP/1.1" 404 - (4 ms)
[26/Jul/2017:15:42:30 +0800] 0:0:0:0:0:0:0:1 "GET /view/blank.html HTTP/1.1" 404 - (16 ms)
[26/Jul/2017:15:42:30 +0800] 0:0:0:0:0:0:0:1 "GET /view/blank.html HTTP/1.1" 404 - (4 ms)
[26/Jul/2017:15:42:31 +0800] 0:0:0:0:0:0:0:1 "GET /assets/css/bootstrap.css.map HTTP/1.1" 404 - (4 ms)
[26/Jul/2017:15:42:32 +0800] 0:0:0:0:0:0:0:1 "GET /assets/img/nav-expand.png HTTP/1.1" 404 - (3 ms)
[26/Jul/2017:15:42:33 +0800] 0:0:0:0:0:0:0:1 "GET /view/form_component.html HTTP/1.1" 404 - (9 ms)
自定义日志设置（logback）

目标

当自己在写业务逻辑代码的时候，需要自己定义输出日志的内容。

实现

在resources目录下新建一个文件logback-spring.xml
在logback-spring.xml写入以下内容。
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="false">

    <contextName>Logback For demo Mobile</contextName>

    <!-- 设置log日志存放地址 -->
    <!--（改） 单环境设置 -->
    <property name="LOG_HOME" value="D:/log/tomcat_log" />

    <!-- 多环境设置 （如果你需要设置区分 生产环境，测试环境...）-->
    <!-- 如果需要设置多环境的配置，只设置以下注释内容是不够的，还需要给每个环境设置对应的配置文件如（application-dev.properties）-->
   <!--  
   <springProfile name="linux">
        <property name="LOG_HOME" value="/home/logger/mobile_log" />
    </springProfile>
    <springProfile name="dev">
        <property name="LOG_HOME" value="D:/logger/log4j" />
    </springProfile>
    <springProfile name="test">
        <property name="LOG_HOME" value="D:/logger/log" />
    </springProfile>
    <springProfile name="prod">
        <property name="LOG_HOME" value="D:/logger/log" />
    -->


    <!-- 控制台输出 -->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <!-- encoder默认配置为PartternLayoutEncoder -->
        <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{80} -%msg%n</pattern>
        </encoder>
        <target>System.out</target>
    </appender>

    <!-- 按照每天生成日志文件 -->
    <appender name="ROLLING_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!--日志文件输出的文件名 ,每天保存（侧翻）一次 -->
            <FileNamePattern>${LOG_HOME}/%d{yyyy-MM-dd}.log</FileNamePattern>
            <!--日志文件保留天数 -->
            <MaxHistory>180</MaxHistory>
        </rollingPolicy>
        <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{25} -%msg%n</pattern>
        </encoder>
        <!--日志文件最大的大小 -->
        <triggeringPolicy
                class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <MaxFileSize>20MB</MaxFileSize>
        </triggeringPolicy>
    </appender>

    <!-- （改）过滤器，可以指定哪些包，哪个记录到等级， -->
    <!-- 运用的场景比如，你只需要com.demo.controller包下的error日志输出。定义好name="com.demo.controller" level="ERROR" 就行了 -->
    <logger name="com" level="ERROR">
        <appender-ref ref="ROLLING_FILE" />
    </logger>

    <!-- 全局，控制台遇到INFO及以上级别就进行输出 -->
    <root level="INFO">
        <appender-ref ref="STDOUT" />
    </root>

</configuration>
3.怎么使用

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ViewController

    // 日志记录工具，这些都是包里有的，直接用就行不用其他的实现。后面的类名是本类的类名
    private static final Logger log = LoggerFactory.getLogger(ViewController.class);

    // 首页
    @RequestMapping(value = "/index", method = RequestMethod.GET)
    public String index(HttpServletRequest request) {
        //这样调用
        log.error("自己定义的日志输出异常");

        return "index";
    }
}
效果

就是在你设置的日志目录里有生成一个文件，里面会有你定义的日志。

扩展（全局异常捕捉，并通过日志输出）

目标

当我们服务器处理请求的时候，可能会产生一些我们没有捕捉到的异常。那么我们需要做的就是，设置全局的异常捕捉，并把异常的内容（堆栈信息）输出到日子文件中。

实现

1.新建一个类文件GlobalExceptionHandler写入以下内容

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

/**
 * User: Qiu Nick
 * Date: 2017-07-26
 * Time: 15:49
 * Description: 全局异常捕获
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    // 日志记录工具
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(value = Exception.class)
    public void handleGlobalException(HttpServletRequest req, Exception ex) {

        //打印堆栈日志到日志文件中
        ByteArrayOutputStream buf = new ByteArrayOutputStream();
        ex.printStackTrace(new java.io.PrintWriter(buf, true));
        String  expMessage = buf.toString();
        try {
            buf.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        //记录到日志
        log.error("GlobalExceptionHandler,捕获异常:"+ ex.getMessage() + ";eString:" + expMessage);
    }
}
效果

通过打印的日志你就能定位到出现错误的地方，非常方便。（这里模拟了一个除0的异常-ViewController.java:72）

===2017-07-26 16:43:45.018 ERROR com.demo.config.GlobalExceptionHandler Line:46  - GlobalExceptionHandler,捕获异常:/ by zero;eString:java.lang.ArithmeticException: / by zero
    at com.truesun.controller.ViewController.slideshowSetting(ViewController.java:72)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:498)
    at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
    at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:133)
    at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:97)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:827)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:738)
    at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85)
    at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:967)
    at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:901)
    at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)
    at org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:861)
    at javax.servlet.http.HttpServlet.service(HttpServlet.java:635)
    at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:846)
    at javax.servlet.http.HttpServlet.service(HttpServlet.java:742)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:231)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.springframework.web.filter.RequestContextFilter.doFilterInternal(RequestContextFilter.java:99)
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.springframework.web.filter.HttpPutFormContentFilter.doFilterInternal(HttpPutFormContentFilter.java:105)
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.springframework.web.filter.HiddenHttpMethodFilter.doFilterInternal(HiddenHttpMethodFilter.java:81)
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:197)
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
    at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:198)
    at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:96)
    at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:478)
    at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:140)
    at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:80)
    at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:87)
    at org.apache.catalina.valves.AbstractAccessLogValve.invoke(AbstractAccessLogValve.java:624)
    at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:342)
    at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:799)
    at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:66)
    at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:861)
    at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1455)
    at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
    at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
    at java.lang.Thread.run(Thread.java:748)
版权声明：本文为博主原创文章，未经博主允许不得转载。	https://blog.csdn.net/csdn2193714269/article/details/76155008