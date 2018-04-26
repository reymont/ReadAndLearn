日志规范 之 logback日志 - CSDN博客 https://blog.csdn.net/aibisoft/article/details/39340207

目的
为了规范应用日志，方便系统问题分析跟查，特制订本规范。
适用范围
适用 Lifeix 所有后台应用。
内容
日志记录准则
在代码中嵌入 log 代码信息，主要记录下列信息：
1、 记录系统运行异常信息。
2、 记录系统运行状态信息。
3、 记录系统运行性能指标。
通过对上述信息分析和诊断，我们能采取正确的手段来提高系统质量  和  提升系统性能。
 
日志主要分三大类：
安全类信息：记录系统边界交互行为和信息
业务类信息：记录系统内部业务处理行为和信息
性能类信息：记录系统硬件对业务处理的支撑能力
 
 
ERROR
WARN
INFO
DEBUG
安全类信息	 	合法拒绝	正常	其它
业务类信息	重要模块类异常	一般模块异常	正常	其它
性能类信息	 	超越指标信息	正常	其它
 
日志中的相关约定
序号
约定内容
1	简化info级别的日志，去掉framework框架中的action跟踪日志，info级别日志中只保留主要的操作日志，将已有的一些用于定位问题的日志（如sql）调整为debug级别。
2	启用mybatis层的日志，用debug级别输出。
3	强化operation日志接口，使operation日志接口具备既能输出日志到文件，也能将操作日志输出到数据库的功能。
4	清除开发过程中用于调试的日志，清理所有拼音、无意义的字符、程序中的System.out.println等内容,日志中不要使用感叹号，使用英文句号结尾
5	不可以讲敏感业务信息记录入日志文件
6	为保证日志的连续，可以讲不同包下面的日志记录到单独的日志文件方便问题跟踪，例如  LoggerFactory.getLogger("AUTHORITY_APPENDER")
7	logback.xml 文件放在 classpath 目录下。
 
目录及命名规范
文件名
日志描述
${LOG_DIR}/${SYSTEM_NAME}/system.log
系统日志
${LOG_DIR}/${SYSTEM_NAME}/system.%d{yyyy-MM-dd}.%i.log
历史系统日志
${LOG_DIR}/${SYSTEM_NAME}/%modulename%/%initialism%.log
业务日志
${LOG_DIR}/%modulename%/%initialism%.%d{yyyy-MM-dd}.%i.log
历史业务日志
 
logback配置规范
<appender>规范
1、日志输出文件目录及文件名


<file>${LOG_DIR}/${SYSTEM_NAME}/system.log</file>


<file>${LOG_DIR}/${SYSTEM_NAME}/%modulename%/%initialism%.log</file>

root日志通常记录在${LOG_DIR}/${SYSTEM_NAME}/system.log 文件中
其它需要特别记录的日志按照  ${LOG_DIR}/${SYSTEM_NAME}/%modulename%/%initialism%.log 的路径和文件名记录，其中%modulename%需要将实际的模块名替换之，%initialism%需要使用实际的缩略语替换之
 
2、日志按天记录，单个日志文件最大不超过5000MB


<rollingPolicy
class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">


    <!-- 日志每天进行rotate -->


    <fileNamePattern>${LOG_DIR}/${SYSTEM_NAME}/system.%d{yyyy-MM-dd}.%i.log</fileNamePattern>


    <timeBasedFileNamingAndTriggeringPolicy
class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">


        <!-- 每个日志文件大小不超过5GB -->


        <maxFileSize>5000MB</maxFileSize>


    </timeBasedFileNamingAndTriggeringPolicy>


 </rollingPolicy>

fileNamePattern还可以为 <fileNamePattern>${LOG_DIR}/%modulename%/%initialism%.%d{yyyy-MM-dd}.%i.log</fileNamePattern>，其中%modulename%需要将实际的模块名替换之，%initialism%需要使用实际的缩略语替换之
 
3、日志输出格式为


<encoder>


    <pattern>%-20(%d{yyy-MM-dd HH:mm:ss.SSS} [%X{requestId}]) %-5level - %logger{80} - %msg%n</pattern>


</encoder>

 
4、一个完整的Appender配置如下


<appender
name="ROOT_APPENDER"
class="ch.qos.logback.core.rolling.RollingFileAppender">


   <file>${LOG_DIR}/${SYSTEM_NAME}/system.log</file>


   <rollingPolicy
class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">


       <!-- 日志每天进行rotate -->


       <fileNamePattern>${LOG_DIR}/${SYSTEM_NAME}/system.%d{yyyy-MM-dd}.%i.log</fileNamePattern>


       <timeBasedFileNamingAndTriggeringPolicy
class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">


           <!-- 每个日志文件大小不超过5GB -->


           <maxFileSize>5000MB</maxFileSize>


       </timeBasedFileNamingAndTriggeringPolicy>


   </rollingPolicy>


   <!-- 日志输出格式 -->


   <encoder>


       <pattern>%-20(%d{yyy-MM-dd HH:mm:ss.SSS} [%X{requestId}]) %-5level - %logger{80} - %msg%n</pattern>


   </encoder>


</appender>

 
<logger>规范
1、<logger>可以根据需要选择使用包路径还是名字的方式，当需要将某个包的所有日志记录到文件的时候可以配置包路径的方式，当需要纵向记录某个业务的日志的时候可以使用第二种方式


第一种方式：


    <logger
name="com.lifeix.apollo.authority.service.impl"
level="DEBUG">


         <appender-ref
ref="AUTHORITY_APPENDER"
/>


    </logger>


    private static Logger LOGGER = LoggerFactory.getLogger(ContextPhotoServiceImpl.class);


 


第二种方式：


    <logger
name="AUTHORITY"
level="DEBUG">


         <appender-ref
ref="AUTHORITY_APPENDER"
/>


    </logger>


    private static Logger AUTHORITY_LOGGER = LoggerFactory.getLogger("AUTHORITY_APPENDER");

 
2、不要使用 additivity="false" 
system.log 需要完整记录该系统所有的日志，为调试跟踪方便，部分日志重复记录到单独的文件里面去。
 
<root>规范
1、root的配置如下，root 的日志级别要求为ERROR，不可将无用的信息输出到日志文件，appender只可以配置ROOT_APPENDER和logstash。


<root
level="ERROR">


<appender-ref
ref="ROOT_APPENDER"
/>


<appender-ref
ref="logstash"
/>


</root>


logstash规范
1、logstash记录到  ${LOG_DIR}/${SYSTEM_NAME}/logstash.json 文件，每天记录到不同文件，单个文件大小不超过5000MB。
 


<appender
name="logstash"
class="ch.qos.logback.core.rolling.RollingFileAppender">


    <file>${LOG_DIR}/${SYSTEM_NAME}/logstash.json</file>


    <rollingPolicy
class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">


        <fileNamePattern>${LOG_DIR}/${SYSTEM_NAME}/logstash.%d{yyyy-MM-dd}.%i.json


        </fileNamePattern>


        <timeBasedFileNamingAndTriggeringPolicy
class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">


            <!-- or whenever the file size reaches 2MB -->


            <maxFileSize>5000MB</maxFileSize>


        </timeBasedFileNamingAndTriggeringPolicy>


    </rollingPolicy>


    <encoding>UTF-8</encoding>


    <encoder
class="net.logstash.logback.encoder.LogstashEncoder"
/>


</appender>

 
日志记录要求
权限日志
日志条件
用户/用户组权限的指派、移除
日志信息
操作时间
系统设备的主机名和 IP 地址
操作用户：谁在操作
授权用户或授权用户组
权限资源名称
操作方式（如：分配、修改、删除等）
操作结果（如：成功、失败）
账号管理日志
日志条件
用户/用户组的帐户管理，包括创建、删除、修改、禁用等。
用户的帐户密码管理，包括创建、修改等。
日志信息
操作时间
系统设备的主机名和 IP 地址
操作用户
被管理的用户/用户组
操作方式(如:新建、修改、删除等）
操作结果（如：成功、失败）
登陆认证管理日志
日志条件
成功的用户登录认证
失败的用户登录认证
用户注销
用户超时退出
日志信息
操作时间
系统设备的主机名和 IP 地址
操作用户
操作源ip地址
操作方式(如:登录、注销、超时退出等）
认证方式（如：AD＋UKEY）
操作结果（如：成功、失败）
系统自身日志
日志条件 
服务启动
服务停止
系统故障
日志信息
操作时间
系统设备的主机名和 IP 地址
操作用户
操作方式(如:服务启动等）
操作结果（如：成功、失败）
业务访问日志
日志条件
 记录业务资源的访问活动
日志信息
操作时间
系统设备的主机名和 IP 地址
操作用户：谁在操作
操作源 IP
访问的资源名称
操作方式（如：查询、插入、删除等）
操作结果（如：成功、失败）
消息日志
日志条件
产生消息
消息被消费
消息消费异常及重试
日志信息
记录时间
系统设备的主机名和 IP 地址
P2P or Pub/Sub
消息队列
消息处理状态
重试次数
消息发布时间及处理时间
Socket通信
日志条件
socket消息的发送和接受（主要指系统直接的信息交互，并非业务socket通信）
日志信息
记录时间
消息来源系统设备的主机名和 IP 地址
消息体
多线程业务处理
日志条件
采用多线程并行处理大量小业务
日志信息
记录时间
线程ID
业务说明
操作方式（如：查询、插入、删除等）
操作结果（如：成功、失败）
 
帐号请求日志采集
      针对所有帐号
       将用户的龙号或者可以唯一标识用户的号码注入到所有的日志中，比如请求日志，响应日志，，，异常日志等等。当某个用户反馈问题的时候，可以通过龙号查找用户的 请求，响应，异常日志
      针对测试/特殊帐号
       后台系统可以对特殊帐号打详细的日志，这些日志细到后台处理每个节点的日志，响应时间等，  这些帐号可以在后台配置，，方便排查问题。
文章标签： 架构
个人分类： 系统架构