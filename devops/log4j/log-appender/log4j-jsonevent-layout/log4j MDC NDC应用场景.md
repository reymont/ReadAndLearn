

log4j MDC NDC应用场景 - CSDN博客 
http://blog.csdn.net/zhongweijian/article/details/7625279


NDC（Nested Diagnostic Context）和MDC（Mapped Diagnostic Context）是log4j种非常有用的两个类，它们用于存储应用程序的上下文信息（context infomation），从而便于在log中使用这些上下文信息。
 
NDC的实现是用hashtable来存储每个线程的stack信息，这个stack是每个线程可以设置当前线程的request的相关信息，然后当前线程在处理过程中只要在log4j配置打印出%x的信息，那么当前线程的整个stack信息就会在log4j打印日志的时候也会都打印出来，这样可以很好的跟踪当前request的用户行为功能。
MDC的实现是使用threadlocal来保存每个线程的Hashtable的类似map的信息，其他功能类似。