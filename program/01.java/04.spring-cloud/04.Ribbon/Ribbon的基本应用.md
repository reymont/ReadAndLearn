Ribbon的基本应用 - 实践求真知 - CSDN博客 https://blog.csdn.net/chengqiuming/article/details/80711168

一 Ribbon简介
Ribbon是Netflix发布的负载均衡器，它有助于控制HTTP和TCP的客户端的行为。为Ribbon配置服务提供者地址后，Ribbon就可基于某种负载均衡算法，自动地帮助服务消费者去请求。Ribbon默认为我们提供了很多负载均衡算法，例如轮询、随机等。当然，我们也可为Ribbon实现自定义的负载均衡算法。
在Spring Cloud中，当Ribbon与Eureka配合使用时，Ribbon可自动从Eureka Server获取服务提供者地址列表，并基于负载均衡算法，请求其中一个服务提供者实例。展示了Ribbon与Eureka配合使用时的架构。


# 二 新建microservice-consumer-movie-ribbon项目

## 2.1 为RestTemplate添加注解@LoadBalanced

```java
package com.itmuch.cloud.study;
 
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;
 
@EnableDiscoveryClient
@SpringBootApplication
public class ConsumerMovieApplication {
  @Bean
  @LoadBalanced
  public RestTemplate restTemplate() {
    return new RestTemplate();
  }
 
  public static void main(String[] args) {
    SpringApplication.run(ConsumerMovieApplication.class, args);
  }
}
```

## 2.2 修改Controller代码

```java
package com.itmuch.cloud.study.user.controller;
 
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.loadbalancer.LoadBalancerClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
 
import com.itmuch.cloud.study.user.entity.User;
 
@RestController
public class MovieController {
  private static final Logger LOGGER = LoggerFactory.getLogger(MovieController.class);
  @Autowired
  private RestTemplate restTemplate;
  @Autowired
  private LoadBalancerClient loadBalancerClient;
 
  @GetMapping("/user/{id}")
  public User findById(@PathVariable Long id) {
    //VIP:virtual IP
    return this.restTemplate.getForObject("http://microservice-provider-user/" + id, User.class);
  }
 
  @GetMapping("/log-user-instance")
  public void logUserInstance() {
    ServiceInstance serviceInstance = this.loadBalancerClient.choose("microservice-provider-user");
    // 打印当前选择的是哪个节点
    MovieController.LOGGER.info("{}:{}:{}", serviceInstance.getServiceId(), serviceInstance.getHost(), serviceInstance.getPort());
  }
}
```

## 2.3 配置文件

```yaml
server:
  port: 8010
spring:
  application:
    name: microservice-consumer-movie
eureka:
  client:
    serviceUrl:
      defaultZone:http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```

# 三 测试
1 启动eureka微服务
2 启动movie-ribbon微服务
3 启动一个user微服务
测试结果


4 启动另外一个user微服务方法

修改user微服务的端口如下：
```yaml
server:
  port: 8001
spring:
  application:
    name: microservice-provider-user
  jpa:
    generate-ddl: false
    show-sql: true
    hibernate:
      ddl-auto: none
  datasource:                           # 指定数据源
    platform: h2                        # 指定数据源类型
    schema: classpath:schema.sql        # 指定h2数据库的建表脚本
    data: classpath:data.sql            # 指定h2数据库的数据脚本
logging:                                # 配置日志级别，让hibernate打印出执行的SQL
  level:
    root: INFO
    org.hibernate: INFO
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
    org.hibernate.type.descriptor.sql.BasicExtractor: TRACE
eureka:
  client:
    healthcheck:
      enabled: true
    serviceUrl:
      defaultZone:http://localhost:8761/eureka/
      #defaultZone: http://user:password123@localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```
启动第两个user微服务后

5 9次访问http://localhost:8010/user/1 ，可以得出ribbon默认采用轮询的方式进行负载均衡
