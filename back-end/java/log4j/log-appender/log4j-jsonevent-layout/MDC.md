

Java 日志管理最佳实践 https://www.ibm.com/developerworks/cn/java/j-lo-practicelog/

MDC
`MDC（Mapped Diagnostic Context，映射调试上下文）`是 log4j 和 logback 提供的一种方便`在多线程条件下记录日志的功能`。某些应用程序采用多线程的方式来处理多个用户的请求。在一个用户的使用过程中，可能有多个不同的线程来进行处理。典型的例子是 Web 应用服务器。当用户访问某个页面时，应用服务器可能会创建一个新的线程来处理该请求，也可能从线程池中复用已有的线程。`在一个用户的会话存续期间，可能有多个线程处理过该用户的请求。这使得比较难以区分不同用户所对应的日志。`当需要追踪某个用户在系统中的相关日志记录时，就会变得很麻烦。

MDC 可以看成是一个与当前线程绑定的哈希表，可以往其中添加键值对。MDC 中包含的内容可以被同一线程中执行的代码所访问。当前线程的子线程会继承其父线程中的 MDC 的内容。当需要记录日志时，只需要从 MDC 中获取所需的信息即可。MDC 的内容则由程序在适当的时候保存进去。对于一个 Web 应用来说，通常是在请求被处理的最开始保存这些数据。清单 5 中给出了 MDC 的使用示例。
清单 5. MDC 使用示例

public class MdcSample { 
   private static final Logger LOGGER = Logger.getLogger("mdc"); 
   public void log() { 
       MDC.put("username", "Alex"); 
       if (LOGGER.isInfoEnabled()) { 
           LOGGER.info("This is a message."); 
       } 
   } 
}
清单 5 中，在记录日志前，首先在 MDC 中保存了名称为“username”的数据。其中包含的数据可以在格式化日志记录时直接引用，如清单 6 所示，“%X{username}”表示引用 MDC 中“username”的值。
清单 6. 使用 MDC 中记录的数据
1
log4j.appender.stdout.layout.ConversionPattern=%X{username} %d{yyyy-MM-dd HH:mm:ss} [%p] %c - %m%n