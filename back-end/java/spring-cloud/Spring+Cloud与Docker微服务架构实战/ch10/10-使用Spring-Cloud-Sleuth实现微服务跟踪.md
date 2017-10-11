
# 10 使用Spring Cloud Sleuth实现微服务跟踪

## 10.1 为什么要实现微服务跟踪

* 分布式计算的八大误区
  * 网络可靠
  * 延迟为零
  * 带宽无限
  * 网络绝对安全
  * 网络拓扑不会改变
  * 必须有一名管理员
  * 传输成本为零
  * 网络同质化

## 10.2 Spring Cloud Sleuth 简介

* 产品
  * Google Dapper
  * Twitter Zipkin
  * Apache HTrace
  * Spring Cloud Sleuth
* 术语
  * span(跨度)：基本工资单元
  * trace（跟踪）：一组共享“root span”的span组成的树状结构。同一trace中的span有相同的trace ID
  * annotation（标注）：记录事件的存在
    * CS（Client Sent客户端发送）：发起请求
    * SR（Server Received服务器端接收）：服务端收到请求并处理，网络延迟 = CS - SR
    * SS（Server Sent服务器发送）：服务端处理完成，服务端处理时间 = SS - SR
    * CR（Client Received客户端接收）：收到服务端响应，总处理时间 = CR - CS

## 10.3 整合 Spring Cloud Sleuth

* 编写
  * mvn: spring-cloud-starter-sleuth
  * application.yml: logging.level.org.springframework.web.servlet.DispatcherServlet: DEBUG

## 10.4 Spring Cloud Sleuth 与 ELK 配合使用

* 编写
  * mvn: logstash-logback-encoder

## 10.5 Spring Cloud Sleuth 与 Zipkin 配合使用

* Zipkin Server编写
  * mvn: zipkin-autoconfigure-ui
  * mvn: zipkin-server
  * 启动类：@EnableZipkinServer
* 微服务整合 Zipkin
  * mvn: spring-cloud-sleuth-zipkin
  * application.yml
    * spring.zipkin.base-url
    * spring.sleuth.sampler.percentage：采样请求的百分比
* 消息中间件收集数据
  * 优点
    * 微服务与Zipkin Server解耦
    * 隔离网络
  * 改造Zipkin Server
    * mvn: spring-cloud-sleuth-zipkin-stream
    * mvn: spring-cloud-starter-sleuth
    * mvn: spring-cloud-stream-binder-rabbit
    * mvn: zipkin-zutoconfigure-ui
    * 启动类：@EnableZiplinStreamServer
  * 改造微服务
    * mvn: spring-cloud-sleuth-stream
    * mvn: spring-cloud-starter-sleuth
    * mvn: spring-cloud-stream-binder-rabbit
  * 存储跟踪数据
    * 支持多端存储：MySQL, Elasticsearch, Cassandra
    * mvn: spring-cloud-sleuth-zipkin-stream
    * mvn: zipkin-autoconfigure-ui
    * mvn: spring-cloud-stream-binder-rabbit
    * mvn: zipkin-autoconfigure-storage-elasticsearch-http
