java Log日志规范 - 阿森丶 - 博客园 https://www.cnblogs.com/Asen0713/p/6456031.html

Overview

一个在生产环境里运行的程序如果没有日志是很让维护者提心吊胆的，有太多杂乱又无意义的日志也是令人伤神。程序出现问题时候，从日志里如果发现不了问题可能的原因是很令人受挫的。本文想讨论的是如何在Java程序里写好日志。

一般来说日志分为两种：业务日志和异常日志，使用日志我们希望能达到以下目标：

1.对程序运行情况的记录和监控；

2.在必要时可详细了解程序内部的运行状态；

3.对系统性能的影响尽量小；

Java日志框架
Java的日志框架太多了。。。

1.Log4j 或 Log4j 2 - Apache的开源项目，通过使用Log4j，我们可以控制日志信息输送的目的地是控制台、文件、GUI组件、甚至是套接口服务器、NT的事件记录器、UNIX Syslog守护进程等；用户也可以控制每一条日志的输出格式；通过定义每一条日志信息的级别，用户能够更加细致地控制日志的生成过程。这些可以通过一个配置文件（XML或Properties文件）来灵活地进行配置，而不需要修改程序代码。Log4j 2则是前任的一个升级，参考了Logback的许多特性；

2.Logback - Logback是由log4j创始人设计的又一个开源日记组件。logback当前分成三个模块：logback-core,logback- classic和logback-access。logback-core是其它两个模块的基础模块。logback-classic是log4j的一个改良版本。此外logback-classic完整实现SLF4J API使你可以很方便地更换成其它日记系统如log4j或JDK14 Logging；

3.java.util.logging - JDK内置的日志接口和实现，功能比较简；

4.Slf4j - SLF4J是为各种Logging API提供一个简单统一的接口），从而使用户能够在部署的时候配置自己希望的Logging API实现；

5.Apache Commons Logging - Apache Commons Logging （JCL）希望解决的问题和Slf4j类似。

选项太多了的后果就是选择困难症，我的看法是没有最好的，只有最合适的。在比较关注性能的地方，选择Logback或自己实现高性能Logging API可能更合适；在已经使用了Log4j的项目中，如果没有发现问题，继续使用可能是更合适的方式；我一般会在项目里选择使用Slf4j, 如果不想有依赖则使用java.util.logging或框架容器已经提供的日志接口。

 

Java日志最佳实践
定义日志变量
日志变量往往不变，最好定义成final static，变量名用大写。

日志分级
Java的日志框架一般会提供以下日志级别，缺省打开info级别，也就是debug，trace级别的日志在生产环境不会输出，在开发和测试环境可以通过不同的日志配置文件打开debug级别。

1.fatal - 严重的，造成服务中断的错误；

2.error - 其他错误运行期错误；

3.warn - 警告信息，如程序调用了一个即将作废的接口，接口的不当使用，运行状态不是期望的但仍可继续处理等；

4.info - 有意义的事件信息，如程序启动，关闭事件，收到请求事件等；

5.debug - 调试信息，可记录详细的业务处理到哪一步了，以及当前的变量状态；

6.trace - 更详细的跟踪信息；

在程序里要合理使用日志分级


 

基本的Logger编码规范

1.在一个对象中通常只使用一个Logger对象，Logger应该是static final的，只有在少数需要在构造函数中传递logger的情况下才使用private final。



 

2.输出Exceptions的全部Throwable信息，因为logger.error(msg)和logger.error(msg,e.getMessage())这样的日志输出方法会丢失掉最重要的StackTrace信息。



 

3.不允许记录日志后又抛出异常，因为这样会多次记录日志，只允许记录一次日志。



 

4.不允许出现System print(包括System.out.println和System.error.println)语句。


 

5.不允许出现printStackTrace。



 

6.日志性能的考虑，如果代码为核心代码，执行频率非常高，则输出日志建议增加判断，尤其是低级别的输出<debug、info、warn>。

debug日志太多后可能会影响性能，有一种改进方法是：


 

但更好的方法是Slf4j提供的最佳实践:



一方面可以减少参数构造的开销，另一方面也不用多写两行代码。

 

7.有意义的日志

通常情况下在程序日志里记录一些比较有意义的状态数据：程序启动，退出的时间点；程序运行消耗时间；耗时程序的执行进度；重要变量的状态变化。

初次之外，在公共的日志里规避打印程序的调试或者提示信息。

 

 

 

转载自：http://www.cnblogs.com/kofxxf/p/3713472.html