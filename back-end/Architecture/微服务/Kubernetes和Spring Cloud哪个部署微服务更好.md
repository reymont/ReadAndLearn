

* [Kubernetes和Spring Cloud哪个部署微服务更好？ - Kubernetes中文社区 - CSDN博客 ](http://blog.csdn.net/qq_34463875/article/details/53816943)
* [Kubernetes和Spring Cloud哪个部署微服务更好？_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1057.html)
* https://dzone.com/articles/microservice-architecture-with-spring-cloud-and-do
* [Microservice Architectures With Spring Cloud and Docker - DZone Java ](https://dzone.com/articles/microservice-architecture-with-spring-cloud-and-do)

* 微服务架构MSA
  * Spring Cloud和Kubernetes是部署和运行微服务的环境，在本质上和解决不同问题上有差异
* 背景
* 微服务故障
* 10个微服务关注点Microservices Concerns
  * Service Discovery & LB
  * Resilience & Fault Tolerance
  * API Management
  * Service Security
  * Centralized Logging
  * Centralized Metrics
  * Distributed Tracing
  * Scheduling & Deployment
  * Auto Scaling & Self Healing
  * Config Managment
* 技术映射

|Microservices Concern|Spring Cloud & Netflix OSS|Kubernetes|
|-|-|-|
|Configuration Management|Config Server, Consul, Netflix Archaius|Kubernetes ConfigMap & Secrets|
|Service Discovery|Netflix Eureka, Hashicorp Consul|Kubernetes Services & Ingress Resources|
|Load Balancing|Netflix Ribbon|Kubernetes Service|
|API Gateway|Netflix Zuul|Kubernetes Service & Ingress Resources|
|Service Security|Spring Cloud Security|-|
|Centralized Logging|ELK Stack(LogStash)|EFK Stack(Fluentd)|
|Centralized Metrics|Netflix Spectator & Atlas|Heapster, Premetheus, Grafana|
|Distributed Tracing|Spring Cloud Sleuth, Zipkin|OpenTracing, Zipkin|
|Resilence & Fault Tolerance|Netflix Hystrix, Turbine & Ribbon|Kubernetes Health Check & Resource Isolation|
|Auto Scaling & Self Healing| - | Kubernetes Health Check, Self Healing, Autoscaling|
|Packaging, Deployment & Scheduling| Spring boot | Docker/Rkt, Kubernetes Scheduler & Deployment|
|Job Management| Spring Batch| Kubernetes Jobs & Schedule Jobs|
|Singleton Application | Spring Cloud Cluster| Kubernetes Pods|

* 结论
  * Spring Cloud
    * JAVA类库来处理所有执行障碍
    * 微服务自身有类库和执行代理来做客户端服务发现负载均衡、配置升级、指标追踪等等
  * Kubernetes
    * 多语言，可以使用任何语言来编写
    * 处理了所有语言用一类方法的分布式计算
    * 在平台层配置管理、服务发现、负载均衡、追踪、指标、单例模式、调度作业提供服务

* 微服务需求

![](https://www.kubernetes.org.cn/img/2016/12/20161220145307.jpg)

* Spring Cloud
  * 在分布式系统中年快速构建
  * 面向Java开发
  * 配置管理、服务发现、短路机制、路由等
  * 优点
    * 统一的编程模式和Spring Boot的快速应用创建能力
  * 缺点
    * 只能使用Java
    * Spring Cloud不能随意交换技术堆栈、类库甚至语言的能力
    * Sidercar模式实现不优雅，non-JVM提供服务
    * 需要补充应用程序平台：Spring Cloud+ Cloud Foundry (或Docker Swarm)
* Kubernetes
  * 优点
    * 是一个多语言和容器管理平台
    * 运行原生云和运行容器化应用程序
    * 服务
      * 环境隔离
      * 资源限制
      * RBAC（Role-Based Access Control）
      * 管理应用程序生命周期
      * 实现自动缩放和自我修复
  * 缺点
    * 多语言的同时，k8s的服务和原语是平台通用的，但对于特定的平台不一定是最佳的
    * 面向DevOps，不是面向开发者
* 总结
  * Spring Cloud方法是试图解决在JVM中每个MSA挑战
  * Kubernetes试图让问题消失，为开发者在平台层解决