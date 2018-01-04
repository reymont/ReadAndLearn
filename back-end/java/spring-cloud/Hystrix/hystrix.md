

# 雪崩效应

雪崩效应：提供者不可用导致消费者不可用，并将不可用逐渐放大的过程

# 容错机制

容错机制需要实现以下两点：
1. 为网络请求设置超时

正常情况下，一个远程调用一般在几十毫秒内就能得到响应。设置超时时间为1秒
必须为每个网络请求设置超时，让资源尽快释放

2. 使用断路器模式

快速失败：当一段时间内，请求失败率达到一定阈值（例如错误率达到50%，或100次/分钟等），打开断路器，在之后的一段时间内，不再请求所依赖的服务。
自我恢复：断路器打开一段时间后，进入“半开”状态。此时，断路器允许一个请求访问依赖的服务。如果请求成功，则关闭断路器；否则继续保持打开断路器。

# Hystrix

Hystrix特性：

1. 包裹请求：使用“命令模式”包裹对依赖的调用逻辑。
2. 跳闸机制：当某服务的错误率超过一定阈值时，Hystrix可以手动或者自动跳闸，停止请求该服务一段时间。
3. 资源隔离：Hystrix为每个依赖都维护了一个小型的线程池或信号量。如果线程池已满，发往该依赖的请求就被立即拒绝。
4. 监控: Hystrix可以近乎实时的监控运行指标和配置的变化。
5. 回退机制：当请求失败、超时、被拒绝，或断路器打开时，执行回退逻辑。回退逻辑可由开发人员自行提供，例如返回一个缺省值。
6. 自我恢复：断路器打开一段时间后，进入“半开”状态。此时，断路器允许一个请求访问依赖的服务。如果请求成功，则关闭断路器；否则继续保持打开断路器。

Hystrix隔离策略有两种：

1. 线程隔离：在单独线程执行，请求受线程池中的线程数量的限制
2. 信号量隔离：在调用线程上执行，请求受信号量个数的限制，负载非常高时采用，适用于非网络调用的隔离

execution.isolation.strategy属性指定隔离策略

# 代码

采用：

* https://github.com/eacdy/spring-cloud-study


修改本地host

```conf
127.0.0.1       localhost, discovery
```

启动项目

1. microservice-discovery-eureka
2. microservice-provider-user
3. microservice-consumer-movie-ribbon-with-hystrix

访问本地

* eureka
  * http://localhost:8761
* provider-user
  * http://localhost:8000/1
* hystrix
  * http://localhost:8011/ribbon/1

# 问题

* Caused by: java.lang.ClassNotFoundException: com.google.common.base.Function
* com.google.common.reflect.TypeToken class is part of Guava 16.0.1 

添加依赖
```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>16.0.1</version>
</dependency>
<dependency>
    <groupId>com.diffplug.guava</groupId>
    <artifactId>guava-cache</artifactId>
    <version>19.0.0</version>
</dependency>
```

参考

1.  http://blog.csdn.net/pierre_/article/details/76285264
2.  http://blog.csdn.net/liaokailin/article/details/51314001
3.  http://cloud.spring.io/spring-cloud-static/Dalston.SR1/#netflix-eureka-client-starter
4.  https://github.com/itmuch/spring-cloud-docker-microservice-book-code
5.  https://github.com/eacdy/spring-cloud-study
6.  https://stackoverflow.com/questions/31951203/noclassdeffounderror-com-google-common-reflect-typetoken
7.  https://github.com/spring-cloud-samples/hystrix-dashboard
8.  https://github.com/Netflix/Hystrix
9.  https://github.com/Netflix/Hystrix/wiki/Dashboard
10. https://gitee.com/darkranger/spring-cloud-books