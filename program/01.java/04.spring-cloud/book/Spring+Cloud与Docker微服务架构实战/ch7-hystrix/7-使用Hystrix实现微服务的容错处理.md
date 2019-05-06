
# 7 使用Hystrix实现微服务的容错处理

* 功能
  * Eureka实现微服务的注册与发现
  * Ribbon实现客户端侧的负载均衡
  * Feign实现声明式的API调用
  * Hystrx实现微服务容错

## 7.1 实现容错的手段

* 容错
  * 服务提供者响应缓慢，请求呗强制等待，直至提供者响应或超时

### 7.1.1 雪崩效应

* 雪崩效应
  * 基础服务故障导致级联故障
  * 提供者不可用导致消费者不可用，并将不可用逐渐放大的过程

### 7.1.2 如何容错

* 容错机制功能
  * 设置超时：响应慢导致无法释放线程，线程越积越多，资源逐步耗尽，导致服务不可用
  * 断路器状态转换
    * 正常情况下，断路器关闭
    * 请求失败率达到一定阈值，断路器打开，不在请求依赖的服务
    * 断路器打开一段时间后，自动进入`半开`状态，运行一个请求访问依赖服务。请求成功则关闭断路器，否则继续打开

## 7.2 使用Hystrix实现容错

### 7.2.1 Hystrix 简介

* Hystrix延迟和容错库，用于隔离访问远程系统、服务或第三方库，防止级联失败
  * 包裹请求：使用HystrixCommand包裹对依赖的调用逻辑，每个命令在独立线程中执行
  * 跳闸机制：服务错误率超过一定阈值，Hystrix自动或手动跳闸，停止请求该服务一段时间
  * 资源隔离：维护线程池，该线程池满，则拒绝依赖请求，加速失败判定
  * 监控：成功、失败、超时、拒绝
  * 回退：当请求失败、超时、被拒绝、或断路器打开，执行回退逻辑
  * 自我修复:断路器打开一段时间后，自动进入`半开`状态，运行一个请求访问依赖服务。请求成功则关闭断路器，否则继续打开

### 7.2.2 通用方式整合 Hystrix

* Spring Cloud
  * mvn：spring-cloud-starter-hystrix
  * 启动类：@EnableCircuitBreaker或@EnableHystrix
  * Controller：@HystrixCommand
    * 使用注解fallbackMethod属性，指定回退方法
    * 使用注解commandProperties属性进行配置

### 7.2.3 Hystrix断路器的状态监控与深入理解

* Spring Cloud
  * mvn：spring-boot-starter-actuator
  * 执行回退逻辑并不代表断路器已经打开
  * 请求失败、超时、被拒绝以及短路器打开时等都会执行回退逻辑

### 7.2.4 Hystrix线程隔离策略与传播上下文

* 隔离策略：线程隔离和信号量隔离
  * THREAD：HystrixCommand将会在单独的线程上执行，请求受`线程池数`b限制
  * SEMAPHORE：HystrixCommand在调用线程上执行，开销小，并发请求受`信号量数`限制
* 特点
  * 默认推荐线程隔离，`有除网络超时以外的额外保护层`
  * 适用于非网络调用的隔离。负载高，达到n*100/秒时，才需要使用`信号量隔离`，此时`线程隔离`开销高。
  * 如果找不到上下文
    * 考虑将隔离策略设置为`信号量隔离`：@HystrixProperty(name"execution.isolation.strategy",value="SEMAPHORE")
    * 还可设置hystrix.shareSecurityContext=true，将securityContext传输到Hystrix

### 7.2.5 Feign 使用 Hystrix

* Hystrix在项目的classpath中，Feign默认就会用短路器包裹
  * @FeignClient(fallback=FeignClientFallback.class)
  * fallbackFactory了解回退原因
  * @FeignClient禁用Hystrix，FeignDisableHystrixConfiguration
  * 全局禁用Hystrix：feign.hystrix.enabled=false

## 7.3 Hystrix 的监控

* 监控
  * spring-boot-starter-actuator
  * spring-boot-starter-hystrix
  * 使用/hystrix.stream端点获得Hystrix的监控信息

## 7.4 使用Hystrix Dashboard可视化监控数据

* Dashboard
  * mvn: spring-cloud-starter-hystrix-dashboard
  * @EnableHystrixDashboard

## 7.5 使用Turbine聚合监控数据

* 监控
  * /hystrix.stream监控单个微服务实例
  * Turbine聚合/hystrix.stream，让集群监控更加方便
* 配置
  * mvn: spring-cloud-starter-turbine
  * @EnableTurbine
  * turbine.appConfig: `microservice-consumer-movice, microservice-consumer-movie-feign-hystrix-fallback-stream`
* rabbitmq client
  * mvn: spring-cloud-netflix-stream
  * mvn: spring-cloud-starter-stream-rabbit
  * application.yml: spring.rabbitmq.{host|port|username|password}
* rabbitmq server
  * mvn: spring-cloud-starter-turbine-stream
  * mvn: spring-cloud-starter-stream-rabbit
* @EnableTurbineStream
* application.yml: spring.rabbitmq.{host|port|username|password}
