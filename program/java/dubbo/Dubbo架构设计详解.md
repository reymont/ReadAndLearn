

# Dubbo架构设计详解

* [简单之美 | Dubbo架构设计详解 ](http://shiyanjun.cn/archives/325.html)

* Dubbo
  * Provider
  * Consumer
  * 注册中心
  * 协议支持
  * 服务监控

* 总体架构

![总体架构](http://shiyanjuncn.b0.upaiyun.com/wp-content/uploads/2013/09/dubbo-architecture.png)

* Dubbo框架设计一共分10层
  * 服务接口层Service：业务设计对应的接口和实现
  * 配置层Config：ServiceConfig、ReferenceConfig
  * 服务代理层Proxy：服务接口透明代理，生成服务的客户端Stub和服务端Skeleton
  * 服务注册层Registry：封装服务地址的注册与发现
  * 集群层Cluster：封装多个提供者的路由及负载均衡，并桥接注册中心
  * 监控层Monitor：RPC调用次数和调用时间监控
  * 远程调用层Protocol：封装RPC调用
  * 信息交换层Exchange：封装请求响应模式，同步转异步
  * 网络传输层Transport
  * 数据序列层Serialize
* 关系
  * RPC，Protocol是核心层。Protocol + Invoker + Exporter完成非透明的RPC调动
  * Provider、Consumer、Registry、Monitor
  * Cluster将多个Invoker伪装成一个Invoker
  * Proxy，将Invoker转换成接口，或将接口实现转成Invoker
  * Remoting
    * Transport传输层
      * 单向消息传输
    * Exchange信息交换层
      * 传输层上封装Request-Response
* 核心要点
  * 服务定义
    * 服务是围绕服务提供方和服务消费方的，服务提供方实现服务，而服务消费方调用服务
  * 服务注册
    * Multicast注册中心
    * Zookeeper注册中心
    * Redis注册中心
    * Simple注册中心
  * 服务监控
  * 远程通信与信息交换
    * Mina
    * Netty
    * Grizzly
  * 服务调用