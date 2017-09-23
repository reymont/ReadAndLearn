

# 8 使用Zuul构建微服务网关

## 8.1 为什么要使用微服务网关

调用多个服务的接口才能完成一个业务需求

* 客户端直连微服务的问题
  * 客户端多次请求不同微服务
  * 存在跨域请求
  * 认证复杂
  * 难以重构
  * 不友好协议
* 网关
  * 易于监控：网关收集数据后并推送到外部系统
  * 易于认证：网关认证后再转发请求到后端
  * 减少各微服务之间的交互次数

## 8.2 Zuul 简介

* Zuul一系列的过滤器
  * 身份认证与安全
  * 审查与监控
  * 动态路由
  * 压力测试
  * 负载分配
  * 静态响应处理
  * 多区域弹性
* 客户端
  * Apache HTTP Client默认
  * RestClient：ribbon.restclient.enabled=true
  * okhttp3.OkHttpClient：ribbon.okhttp.enabled=true

## 8.3 编写Zuul微服务网关

* 编写
  * mvn: spring-cloud-starter-zuul
  * mvn: spring-cloud-starter-eureka
  * 启动类：@EnableZuulProxy，声明Zuul代理，该代理使用Ribbon来定位注册在Eureka Server中的微服务

## 8.4 Zuul的路由端点

* 路由
  * 当@EnableZuulProxy与Spring Boot Actuator配合使用，Zuul暴露出路由管理端点/routes
  * /routes
    * GET返回当前映射的路由列表
    * POST强制刷新Zuul当前映射的路由列表
  * spring-cloud-starter-zuul已包含spring-boot-starter-actuator

## 8.5 路由配置详解

* 路由配置
  * 自定义微服务的访问路径：zuul.routes.microservice-provider-user: /user/**
  * 忽略指定微服务：zuul.ignored-services: microservice-provider-user
  * 忽略所有微服务，只路由指定微服务：zuul.ignored-service: '*'
  * 同时指定服务的serviceId和对应路径
  * 同时指定path和URL
  * 同时指定path和URL，并且不破坏zuul的Hystrix, Ribbon特性：ribbon.eureka.enabled: false
  * 借助PatternServiceRouteMapper，实现从微服务到映射路由的正则配置
  * 路由前缀：`zuul.prefix和zuul.strip-prefix`
  * 指定忽略的正则：ignoredPatterns
  * 打印Zuul具体细节：logging.level.com.netflix: DEBUG

## 8.6 Zuul 的安全与 Header

### 8.6.1 敏感 Header 的设置

* 防止敏感Header外泄
  * zuul.routes.sensitive-headers: Cookies,Set-Cookie,Authorization
  * 全局敏感：zuul.sensitive-headers: Cookies,Set-Cookie,Authorization
* 丢弃header
  * zuul.ignored-headers: Header1, Header2

## 8.7 使用Zuul上传文件Zuul的过滤器

* 上传文件
  * 小文件无须任何处理
  * 大文件（10M以上），为上传路径添加/zuul前缀，或使用zuul.servlet-path自定义前缀
  * 使用Ribbon负载均衡，对于超大文件（例500M），需提升超时设置
    * hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds: 60000
    * ribbon.ConnectTimeout: 3000 ribbon.ReadTimeout:60000
* 编写
  * mvn: spring-boot-starter-web
  * mvn: spring-cloud-starter-eureka
  * mvn: spring-boot-starter-actuator
  * 启动类：@EnableEurekaClient

## 8.8 Zuul的过滤器

### 8.8.1 过滤器类型与请求生命周期

Zuul大部分功能是通过过滤器来实现的

* 过滤器类型
  * PRE：请求被路由之前调用
  * ROUTING：将请求路由到微服务
  * POST：路由到微服务后执行
  * ERROR：其他阶段发生错误时执行该过滤器
* 自定义过滤器类型

* 编写Zuul过滤器
  * 继承抽象类ZuulFilter
  * 实现的方法
    * filterType: pre, route, post, error
    * filterOrder: 返回int值指定过滤器的执行顺序
    * shouldFilter: 判断该过滤器是否执行
    * run: 过滤器的基本逻辑

* 禁止Zuul过滤器
  * zuul.<FilterClassName>.<FilterType>.disable=true


## 8.9 Zuul的容错与回退

* 回退
  * 实现ZuulFallbackProvider接口
  * 当微服务无法正常响应时，显示回退中内容

## 8.10 Zuul的高可用

* 高可用
  * 多Zuul节点注册到Eureka Server上
  * 未注册到Eureka：Zuul客户端将请求发送到负载均衡器，负载均衡器将请求转发到其代理的一个Zuul节点

## 8.11 使用Sidecar整合非JVM微服务

* Sidecar
  * 非JVM微服务操作Eureka的REST端点，从而实现注册与发现
  * 简单的HTTP API获取指定服务所有实例的信息
  * 通过内嵌的Zuul代理服务
  * 非JVM微服务需要实现健康检查，上报Sidecar的状态

## 8.11.1 编写Node.js微服务

## 8.11.2 编写Sidecar

* 编写
  * mvn: spring-cloud-starter-zuul
  * mvn: spring-cloud-starter-eureka
  * mvn: spring-cloud-netflix-sidecar
  * 启动类：@EnableSideCar，整个三个注解，@EnableCircuitBreaker, @EnableDiscoveryClient, @EnableZuulProxy
  * application.yml: sidecar.port: 8060, sidecar.health-uri: http://localhost:8060/health.json

### 8.11.3 Sidecar的端点

### 8.11.4 Sidecar 与 Node.js 微服务分离部署

* 分离部署
  * eureka.instance.hostname
  * sidecar.hostname, sidecar.ip-address

### 8.11.5 Sidecar原理分析

* 分析
  * 注册到Eureka Server上的微服务可通过名称请求node-service接口
  * 非JVM微服务可通过Sidecar请求其他注册在Eureka Server的微服务
  * 通过Sidecar的/health端点，Eureka Server感知到非JVM微服务的健康状态

## 8.12 使用Zuul聚合微服务

* Zuul聚合微服务
  * 启动类：@EnableZuulProxy
  * Observable<User>
  * Observable.zip
  * toDeferredResult




