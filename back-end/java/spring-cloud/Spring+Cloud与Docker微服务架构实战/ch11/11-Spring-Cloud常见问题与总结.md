
# 11 Spring Cloud常见问题与总结

## 11.1 Eureka常见问题

* Eureka注册慢
  * 服务的注册涉及到周期性心跳，默认30秒一次
  * 3次心跳：实例、服务端和客户端的本地缓存元数据一致，服务才能被其他客户端发现
  * 心跳频率：eureka.instance.leaseRenewalIntervalInSeconds
* 注销服务慢或不注销
  * 清理无效节点长，默认90秒
  * 自我保护模式
  * Eureka Server
    * 关闭自我保护：eureka.server.enable-self-preservation
    * 清理间隔：eureka.server.eviction-interval-time-in-ms
  * Eureka Client
    * 开启健康检查（依赖actuator）：eureka.client.healthcheck.enabled
    * 更新时间：eureka.instance.lease-renewal-interval-in-seconds
    * 续约时间：eureka.instance.lease-expiration-duration-in-seconds
* 自定义Instance ID
  * 默认值：${spring.cloud.client.hostname}:${spring.application.name}:${spring.application.instance_id:${server.port}}
  * eureka.instance.instance-id: ${spring.cloud.client.ipAddress}:${server.port}
* UNKNOWN
  * 应用名称UNKNOWN
    * 未配置spring.application.name或eureka.instance.appname
    * 特定版本SpringFox导致该问题
  * 微服务实例状态UNKNOWN
    * eureka.client.healthcheck.enabled=true必须在application.yml中设置，不能在bootstrap.yml中

## 11.2 Hystrix/Feign整合Hystrix后首次请求失败

* 首次调用Hystrix失败
  * Spring的懒加载机制，首次请求往往会比较慢
  * 延长Hystrix的超时时间：hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds
  * 禁用Hystrix的超时：hystrix.command.default.execution.timeout.enabled: false
  * 为Feign禁用Hystrix：feign.hystrix.enabled: false

## 11.3 Turbine聚合的数据不完整

* Turbine聚合的数据不完整
  * Turbine聚合的微服务部署在同一台主机上，就会出现该问题
  * 为各个微服务配置不同的hostname
  * 设置turbine.combine-host-port = true
  * 