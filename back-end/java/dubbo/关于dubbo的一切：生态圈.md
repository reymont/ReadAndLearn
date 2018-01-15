http://www.itkeyword.com/doc/2452935282600173206/dubbo

关于dubbo的一切：生态圈
KimmKing 分享于 2017-05-10
推荐：Dubbo分布式服务治理（二）——Dubbo服务运行方式&&监控中心安装（Linux）
一、Dubbo服务运行方式 1、使用servlet容器（tomcat、jetty）发布运行      Dubbo服务可将其发布到web容器中供，注册到ZK，传送消息通知调用；      这种方式不
2018阿里云全部产品优惠券(好东东，强烈推荐)
领取地址：https://promotion.aliyun.com/ntms/act/ambassador/sharetouser.html?userCode=gh9qh5ki&utm_source=gh9qh5ki

dubbo ecosystem

dubbo

Dubbo是一个高性能、可扩展的分布式服务框架，基于RPC，支持多种协议调用、服务监控和治理，同时是去中心化的框架，对应用侵入性小。 

- 官方网站 
- GitHub源码 
- 官方文档
dubbox

https://github.com/dangdangdotcom/dubbox 
来自dangdang网，主要是实现了基于JBoss RestEasy的rest支持，升级了spring、zk、json等依赖库，并且一直在维护。目前已经release的版本到2.8.4了。 
文档资料： 
- 在Dubbo中开发REST风格的远程调用（RESTful Remoting） 
- 在Dubbo中使用高效的Java序列化（Kryo和FST） 
- 使用JavaConfig方式配置dubbox 
- Dubbo Jackson序列化使用说明 
- Demo应用简单运行指南 
- Dubbox@InfoQ 
- Dubbox Wiki （由社区志愿者自由编辑的）
spring-boot-starter-dubbo

已有的可用starter: 
- https://github.com/cyzaoj/spring-boot-dubbo-starter 可以配置protocol、registry、provider 
- https://github.com/linking12/spring-boot-starter-dubbo 可以自动配置、暴露服务 
- https://github.com/tbud/spring-boot-starter-dubbo 加了log
dubbokeeper(dubbo-admin)

https://github.com/dubboclub/dubbokeeper
dubbokeeper是一个开源版本基于spring mvc开发的社区版dubboadmin，同时修复了官方admin存在的一些问题，以及添加了一下必要的功能 例如服务统计，依赖关系等图表展示功能，当前dubbokeeper还属于开发阶段。最终dubbokeeper会集成服务管理以及服务监控一体的DUBBO服务管理系统。注意是增强了配置管理和服务监控。
image
使用说明：http://www.cnblogs.com/yyssyh213/p/6031453.html 
几种工具的配置：http://www.tuicool.com/articles/u6Jzim6
dubbo monitor(bootstrap)

http://git.oschina.net/handu/dubbo-monitor
Dubbo Monitor是针对Dubbo开发的监控系统，基于dubbo-monitor-simple改进而成，可以理解为其演化版本。该系统用关系型数据库（MySQL）记录日志的方式替代了dubbo-monitor-simple写文件的方式。注：亦可改为其他Relational Database（关系型数据库）。 
PS: 项目目前依赖的是dubbox的2.8.4版本，但是dubbox并没有修改过监控相关的代码，因此理论上也可以支持dubbo的最新版本。 
来自韩都衣舍，最新版本已经支持MongoDB了。感觉可以合并到dubbox，作为monitor的基础骨架来发展。
image
dubbox demos

https://github.com/kimmking/dubbox-demos
最简单的例子。
推荐：基于Dubbo框架构建分布式服务(顶)
http://shiyanjun.cn/archives/1075.html
J2EE DEMO APP

http://git.oschina.net/vmaps/dubbo-app
dubbo-app 是J2EE分布式开发基础平台，使用经典技术组合（dubbo、zookeeper、Spring、SpringMVC、MyBatis、Shiro、redis、quartz、activiti、easyui），包括核心模块如：角色用户、权限授权、工作流等。 
对新手来说，是个很好的从quick start到on action。
image
dubbo rest proxy

https://git.oschina.net/wuyu15255872976/dubbo-rpc-proxy
这是一个神奇的小项目，直接把服务转换为rest接口，参数都加到url后面。接口方式太粗暴，for fun。
dubbo-plus

https://git.oschina.net/bieber/dubbo-plus
提供服务降级控制、增强cache等功能，这块东西感觉可以合并到dubbo或dubbox的。
dubbo + zipkin

分布式调用链追踪:dubbo+zipkin: 
https://github.com/jiangmin168168/jim-framework
原理：dubbo+zipkin调用链监控
其他事宜

dubbo 2.5.3以后就没有release了。 
dubbox 目前版本到了2.8.4了。
最近阿里的teaey又在开始维护dubbo相关bug处理，目前还没有发布新的release版本。
梁飞同学这几年一直在提dubbo新一代的计划，不知道大家对这一块有什么想法，一同来brainstorm一下吧。
我的想法： 
1. 重新设计，各块的概念进一步理清，考虑基于springboot，吸收springcloud等框架的部分设计理念，优化架构。 
2. 项目拆分，dubbo的项目结构分成两大类，核心部分一个repo：包括基础概念、提供者、消费者，可扩展的协议支持类型；生态工具类一个或多个repo：admin、monitor这些，单独发展，灵活发展。 
3. 异构支持，着重发展rest或某二进制rpc平台无关协议，然后基于此解决异构系统的集成整合问题，起码加到admin、monitor里一起管控起来，增强管理能力。 
4. 生态扩张，与更多业内常用的框架整合或connect，触角衍生到更多的应用场景，保持活力。
推荐：Dubbo分布式服务治理（一）——Dubbo注册中心&&管理平台安装（Linux）
一、Dubbo介绍      Dubbo是阿里巴巴SOA服务化治理方案的核心框架，每天为2,000+个服务提供3,000,000,000+次访问量支持，并被广泛应用于阿里巴巴集团的各成员站
dubbo ecosystem dubbo Dubbo是一个高性能、可扩展的分布式服务框架，基于RPC，支持多种协议调用、服务监控和治理，同时是去中心化的框架，对应用侵入性小。 - 官方网站 - GitHub源码 - 官方文