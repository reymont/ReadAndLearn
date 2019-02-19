Mycat使用篇: Mycat启动脚本及脚本配置文件详解 - CrazyPig的技术博客 - CSDN博客 https://blog.csdn.net/d6619309/article/details/73740146

JSW有一个比较重要的配置文件，默认叫做wrapper.conf。通过这个配置文件，配置JSW守护进程和wrapper的一些行为，并且，还可以控制mycat jvm的一些启动参数（如-Xms和-Xmx这些）。

这个文件默认放到/conf目录下

下面我们将重点放在这个文件的配置选项里面:

贴上mycat编译打包后默认生成的wrapper.conf（位于conf子目录下），然后对每个配置参数作出解释，如下所示：

```conf

#********************************************************************
# Wrapper Properties
#********************************************************************
# Java执行命令，默认即可
wrapper.java.command=java
# 用于定位wrapper程序目录，默认即可
wrapper.working.dir=..

# JSW wrapper类，JSW将使用这个类来包装Mycat启动类(MycatStartup.java)，并控制Mycat的执行，
# 即在WrapperSimpleApp的main方法里面加入一些控制逻辑，
# 然后执行MycatStartup的main方法，从而跑其Mycat
wrapper.java.mainclass=org.tanukisoftware.wrapper.WrapperSimpleApp

# 设置环境变量，参考https://wrapper.tanukisoftware.com/doc/english/props-envvars.html
# 在后面的配置wrapper.java.classpath.3被使用
set.default.REPO_DIR=lib
# 不知道哪里会用到这个环境变量
set.APP_BASE=.

# Java Classpath (include wrapper.jar)  Add class path elements as
#  needed starting from 1
# 配置Java应用的classpath，必须要包含wrapper.jar，参数下标从1开始
wrapper.java.classpath.1=lib/wrapper.jar
wrapper.java.classpath.2=conf
wrapper.java.classpath.3=%REPO_DIR%/*

# Java Library Path (location of Wrapper.DLL or libwrapper.so)
# 默认参数，不用修改
wrapper.java.library.path.1=lib

# 配置Java启动参数，参数下标从1开始，包括一系列Java环境变量设定以及JVM参数配置
#wrapper.java.additional.1=
wrapper.java.additional.1=-DMYCAT_HOME=.
wrapper.java.additional.2=-server
wrapper.java.additional.3=-XX:MaxPermSize=64M
wrapper.java.additional.4=-XX:+AggressiveOpts
wrapper.java.additional.5=-XX:MaxDirectMemorySize=8G
wrapper.java.additional.6=-XX:+UseParallelGC
wrapper.java.additional.7=-Xss512K
wrapper.java.additional.8=-Dcom.sun.management.jmxremote
wrapper.java.additional.9=-Dcom.sun.management.jmxremote.port=1984
wrapper.java.additional.10=-Dcom.sun.management.jmxremote.authenticate=false
wrapper.java.additional.11=-Dcom.sun.management.jmxremote.ssl=false
wrapper.java.additional.12=-Xmx4G
wrapper.java.additional.13=-Xms4G

# Initial Java Heap Size (in MB) 等价于 -Xms3M
#wrapper.java.initmemory=3

# Maximum Java Heap Size (in MB) 等价于 -Xmx64M
#wrapper.java.maxmemory=64

# 程序启动参数，下标从1开始，第1个参数指定wrapper需要包装的Java应用主程序入口，
# 对于Mycat而言，这里指定为MycatStartup，默认即可，不需要修改
wrapper.app.parameter.1=org.opencloudb.MycatStartup
# 默认即可，不需要修改
wrapper.app.parameter.2=start

#********************************************************************
# Wrapper Logging Properties
#********************************************************************
# wrapper 控制台日志输出格式 
# 仅当使用mycat console启动时候，会将log输出到控制台，这个参数是控制这个时候log的输出格式
# 格式详见: https://wrapper.tanukisoftware.com/doc/english/prop-console-format.html
wrapper.console.format=PM

# wrapper 控制台输出日志级别
# 仅当使用mycat console启动时候，会将log输出到控制台，这个参数是控制这个时候log的级别， 默认为INFO即可
wrapper.console.loglevel=INFO

# wrapper 输出日志文件 
# 仅当使用mycat start启动时，会将log输出到这个指定的文件里
wrapper.logfile=logs/wrapper.log

# wrapper 输出到log文件的日志输出格式 
# 控制当使用mycat start启动方式下log输出格式
# 格式参考: https://wrapper.tanukisoftware.com/doc/english/prop-logfile-format.html
wrapper.logfile.format=LPTM

# wrapper 输出到log文件的日志级别 
# 控制当使用mycat start启动方式下log输出级别
wrapper.logfile.loglevel=INFO

# 配置滚动日志大小，默认为0，表示不支持滚动日志，即日志都往一个日志文件里面写，并且不限制文件大小
# May abbreviate with the 'k' (kb) or 'm' (mb) suffix.  For example: 10m = 10 megabytes.
wrapper.logfile.maxsize=0


# 配置滚动日志最大文件个数，默认为0表示不限制个数
wrapper.logfile.maxfiles=0

# 输出到sys/event log的日志级别，默认为NONE表示不输出到sys/event log
wrapper.syslog.loglevel=NONE

#********************************************************************
#********************************************************************
# Title to use when running as a console
wrapper.console.title=Mycat-server

# 以下这些参数在Windows平台下起作用，一般应用都部署在Linux平台，可忽略这些配置
#********************************************************************
# Wrapper Windows NT/2000/XP Service Properties
#********************************************************************
# WARNING - Do not modify any of these properties when an application
#  using this configuration file has been installed as a service.
#  Please uninstall the service before modifying this section.  The
#  service can then be reinstalled.

# Name of the service
wrapper.ntservice.name=mycat

# Display name of the service
wrapper.ntservice.displayname=Mycat-server

# Description of the service
wrapper.ntservice.description=The project of Mycat-server

# Service dependencies.  Add dependencies as needed starting from 1
wrapper.ntservice.dependency.1=

# Mode in which the service is installed.  AUTO_START or DEMAND_START
wrapper.ntservice.starttype=AUTO_START

# Allow the service to interact with the desktop.
wrapper.ntservice.interactive=false

# 重要参数，控制wrapper ping Mycat hung住的超时时间，单位是s，120s = 2min
wrapper.ping.timeout=120
# JSW官网上目前找不到这个参数!
configuration.directory.in.classpath.first=conf
```