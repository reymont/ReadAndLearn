
# 9 使用Spring Cloud Config统一管理微服务配置


## 9.1 为什么要统一管理微服务配置

* 切换服务配置
  * 单体应用：启动应用时制定spring.profiles.active={profile}
* 配置管理需求
  * 集中管理配置
  * 不同环境不同配置
  * 运行时动态调整
  * 配置修改后自动更新

## 9.2 Spring Cloud Config 简介

* Spring Cloud Config为分布式系统提供`外部化`配置
  * Config Server: 默认使用Git存储配置内存，实现配置的版本控制与内容审计
  * Config Client: 操作存储在Config Server中的配置属性

## 9.3 编写Config Server

* 编写
  * mvn: spring-cloud-config
  * 启动类：@EnableConfigServer
  * application.yml: spring.cloud.config.server.git.{uri|username|password}
* Config Server
  * /{lable}/{application}-{profile}.properties：label对应Git仓库分支，默认为master

## 9.4 编写 Config Client

* 编写
  * mvn: spring-boot-starter-web
  * mvn: spring-cloud-starter-config
  * mvn: spring-boot-starter-actuator
  * bootstrap.yml: spring.cloud.config.{uri|profile|label}
  * Controller: @Value("${profile}")绑定Git仓库配置文件profile属性
* 引导上下文
  * 负责从配置服务器加载配置属性
  * 解密外部配置文件的属性
  * 配置在bootstrap.*中的属性有更高的优先级，默认不能被本地配置覆盖
  * 禁用引导过程：spring.cloud.bootstrap.enabled=false

## 9.5 Config Server 的 Git 仓库配置详解

* spring.cloud.config.server.git.uri
  * {application|profile|label}
  * 模式匹配
    * 代理通配符的{application}/{profile}名称的列表
    * 如不匹配任何模式，将使用spring.cloud.config.server.git.uri
  * 搜索目录
    * 在Git仓库根目录、foo子目录和所有以bar开始的子目录查找配置文件：search-paths: foo,bar*
  * 加载配置文件
    * 默认首次请求clone git仓库
    * Config Server启动时就clone git仓库：clone-on-start
    * 全局配置：spring.cloud.config.server.git.clone-on-start = true
  * 打印Config Server请求Git细节
    * logging.level.org.springframework.clloud: DEBUG
    * logging.level.org.springframework.boot: DEBUG

## 9.6 Config Server的健康状况指示器

* 健康
  * spring.cloud.config.server.health.repositories.a-foo.{label|name|profiles}
  * 禁用：spring.cloud.config.server.health.enabled=false

## 9.7 配置内容的加解密

* 加解密
  * 依赖Java Cryptography Extension (JCE)
  * 将JDK/jre/lib/security目录中的两个jar文件替换为JCE中的jar文件
* 端点
  * 加密：/encrypt
  * 解密：/decrypt
* 对称加密
  * application.yml：encrypt.key: foo //设置对称秘钥
* 存储加密的内容
  * 使用{cipher}密文
  * spring.datasource.password
    * yml中必须添加单引号
    * properties不能用单引号
  * Config Server能自动解密配置内容
  * 禁止自动解密：spring.cloud.config.server.encrypt.enabled=false
* 非对称加密
  * keytool生成server.jks
  * application.yml: encrypt.keyStore.{location|password|alias|secret}

## 9.8 使用/refresh端点手动刷新配置

* 编写
  * mvn: spring-boot-starter-actuator
  * Controller: @RefreshScope

## 9.9 使用Spring Cloud Bus自动刷新酉己置

* Spring Cloud Bus实现配置自动刷新
  * 使用`消息代理`连接分布式系统给的节点，广播状态的更改
  * 每个实例订阅配置更新事件
* 编写
  * mvn: spring-cloud-starter-bus-amqp
  * bootstrap.yml: spring.rabbitmq.{host|port|username|password}
  * POST请求/bus/refresh端点
* 局部刷新
  * /bus/refresh端点的destination参数定位应用程序
* 架构改进
  * 问题
    * 破坏了微服务的单一原则
    * 破坏了微服务各节点的对等性
    * 有一定的局限性
  * 将Config Server加入到消息总线中
* 跟踪总线事件
  * 设置spring.cloud.bus.trace.enabled=true
  * 访问/trace端点  

## 9.10 Spring Cloud Config 与 Eureka 酉己合使用

* boostrap.yml
  * 开启`服务发现组件`访问Config Server：spring.cloud.config.discovery.enabled = true
  * 指定Config Server在`服务发现组件`中的serviceId：spring.cloud.config.discovery.service-id

## 9.11 Spring Cloud Config 的用户认证

* Config Server HTTP Basic认证
  * mvn: spring-boot-starter-security
  * application.yml
    * security.basic.enabled
    * security.user.name
    * security.user.password
* Config Client连接
  * spring.cloud.config.uri: http://user:password@localhost:8080/
  * spring.cloud.config.{uri|username|password}

## 9.12 Config Server 的高可用

* git高可用
  * 第三方Git仓库
  * 自建Git仓库管理系统
* RabbitMQ高可用
* Config Server高可用
  * 未注册到Eureka：微服务将请求发送到负载均衡器，负载均衡器将请求转发到其代理的其中一个Config Server节点
  * 注册到Eureka：多个Config Server节点注册到Eureka Server上

