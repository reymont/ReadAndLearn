
# 5 使用Ribbon实现客户端恻负载均衡

## 5.1 Ribbon简介

* Ribbon
  * Netflix发布的负载均衡器
  
## 5.2 为服务消费者整合Ribbon

* Ribbon
  * RestTemplate添加@LoadBalanced注解
  * 当Ribbon和Eureka配合使用时，自动将虚拟主机名映射成微服务的网络地址
  * 可使用配置属性eureka.instance.virtual-host-name或eureka.instance.secure-virtual-host-name指定虚拟机主机名

## 5.3 使用Java代码自定义Ribbon配置

* JAVA配置
  * ZoneAvoidanceRule：根据提供者所在Zone的性能以及服务提供者可用性综合计算
  * 默认配置类：RibbonClientConfiguration

## 5.4 使用属性自定义Ribbon配置

* 属性配置
  * NFLoadBalancerClassName：配置ILoadBalance的实现类
  * NFLoadBalancerRuleClassName：配置IRule的实现类
  * NFLoadBalancerPingClassName：配置IPing的实现类
  * NIWSServerListClassName：配置ServerList的实现类
  * NIWSServerListFilterClassName：配置ServerListFilter的实现类

## 5.5 脱离Eureka使用Ribbon

* application.yml
  * ribbon.listOfServers: localhost:8000,localhost:8001